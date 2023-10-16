import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_detect_by_area/src/Element/custom_buttons.dart';
import 'package:flutter_text_detect_by_area/src/Element/padding_class.dart';
import 'package:flutter_text_detect_by_area/src/Style/text_style.dart';
import 'package:flutter_text_detect_by_area/src/Utils/Helper/storage_helper.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:photo_view/photo_view.dart';

class SelectImageAreaTextDetect extends StatefulWidget {
  const SelectImageAreaTextDetect({Key? key, required this.imagePath,required this.onSelectArea}) : super(key: key);
  final String imagePath;
  final void Function(dynamic) onSelectArea;

  @override
  _SelectImageAreaTextDetectState createState() =>
      _SelectImageAreaTextDetectState();
}

class _SelectImageAreaTextDetectState extends State<SelectImageAreaTextDetect> {

  late File image;
  String fileName = '/TEMP_IMG.jpg';
  String tempPath = "";
  final _controller = CropController();
  var itemProcessIndex = -1;//0 for confirm,1 for item,2 for price,3 for one more highlight
  final TextRecognizer _recognizer = GoogleVision.instance.textRecognizer();
  var _isProcessing = false;
  set isProcessing(bool value) {
    setState(() {
      _isProcessing = value;
    });
  }
  Uint8List? _croppedData;
  set croppedData(Uint8List? value) {
    setState(() {
      _croppedData = value;
    });
  }
  void navigateBackScreen() {
    Navigator.pop(context);
  }

  void initTempImage()async{
    tempPath = await StorageHelper.getGalleryDirectory()+fileName;
    StorageHelper.saveFileToDirectory(fileName,File(image.path));
  }

  @override
  void initState() {
    super.initState();
    image = File(widget.imagePath);
    initTempImage();
  }
  @override
  void dispose() {
    File(tempPath).deleteSync();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          navigateBackScreen();
          return false;
        },
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              children: [
                Expanded(
                    child: Stack(
                      children: [
                        Center(child: _isProcessing==true?CircularProgressIndicator(color: Colors.black,):itemProcessIndex==-1||itemProcessIndex==3?
                        PhotoView(imageProvider: FileImage(image))
                            :Crop(
                          baseColor: Colors.black,
                          controller: _controller,
                          initialSize: 0.25,
                          image:image.readAsBytesSync(),
                          cornerDotBuilder: (size, cornerIndex) {return const DotControl(color: Colors.black,);},
                          onCropped: (cropped) async{
                            croppedData = cropped;
                            await File(tempPath).writeAsBytes(_croppedData!);
                            final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(File(tempPath));
                            var results = await _recognizer.processImage(visionImage);
                            var value = results.text!.replaceAll("\n", " ");
                            widget.onSelectArea(value);
                            isProcessing = false;
                          },
                        ),
                        )
                      ],
                    )),
                Container(
                  height: size.height * 0.18,
                  width: size.width,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        itemProcessIndex==-1
                            ? buildConfirmButtons(size)
                            :itemProcessIndex==3?buildLastButtons(size):buildInstruct(size)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
  void cropImageFor(var itemPrice)async{
    isProcessing = true;
    setState(() {});
    _controller.crop();
    if(itemPrice=="item") {
      itemProcessIndex=2;
    } else if(itemPrice=="price") {
      //itemProcessIndex=1;
      itemProcessIndex=3;setState(() {});
    }
    croppedData = null;
    setState(() {});
  }
  Widget buildInstruct(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.back_hand, size: 22,color: Colors.white,),
            paddingRight(10),
            Text("1. Drag the rectangle to the", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w900)),
            paddingRight(5),
            Text("imaage text area", style: TextStyleTheme.customTextStyle(Colors.blue, 16, FontWeight.w900).apply(decoration: TextDecoration.underline))
          ],
        ),
        paddingTop(20),
        CustomButton(bgColor: Colors.blue, onTap: ()async { cropImageFor("item"); }, buttonWidth: size.width * 0.4, child: Center(child: Text("Next", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),
        )
      ],
    );
  }

  Widget buildConfirmButtons(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomButton(bgColor: Colors.red, onTap: navigateBackScreen, buttonWidth: size.width * 0.4, child: Center(child: Text("Nah! Retake!", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),),
        CustomButton(bgColor: Colors.blueAccent, onTap: () {itemProcessIndex=1;setState(() {});}, buttonWidth: size.width * 0.4, child: Center(child: Text("That's Good!", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))))
      ],
    );
  }

  Widget buildLastButtons(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomButton(bgColor:Colors.blueAccent, onTap: (){itemProcessIndex=1;setState(() {});}, buttonWidth: size.width * 0.56, child: Center(child: Text("High Light More Text", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),),
        CustomButton(bgColor: Colors.lightBlueAccent, onTap: () {
          // showGeneralDialog(
          //     context: context,
          //     barrierColor: Colors.black45,
          //     transitionDuration: const Duration(milliseconds: 0),
          //     pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
          //       return AlertMyProductList(items: items,image: image,);
          //     }).then((value) => null);
          // for(var v in items){
          //   print("item : ${v.item} , price : ${v.price}");
          // }
          //push(context, UploadProductDetailsScreen(img: image,),isAnimate: true);
        },buttonWidth: size.width * 0.3, child: Center(child: Text("Next", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),)
      ],
    );
  }
}
