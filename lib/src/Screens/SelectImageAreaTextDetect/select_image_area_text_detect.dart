import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_detect_by_area/src/Element/padding_class.dart';
import 'package:flutter_text_detect_by_area/src/Style/text_style.dart';
import 'package:flutter_text_detect_by_area/src/Utils/Notifier/select_image_area_text_detect_notifier.dart';
import 'package:flutter_text_detect_by_area/src/Widgets/ripple_button.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class SelectImageAreaTextDetect extends StatelessWidget{
  const SelectImageAreaTextDetect({super.key,required this.imagePath,required this.onSelectArea});
  final String imagePath;
  final void Function(dynamic) onSelectArea;
  @override
  Widget build(BuildContext context) {
   return ChangeNotifierProvider(
       create: (_) => SelectImageAreaTextDetectNotifier(),
      child: SelectImageAreaTextDetectProvider(imagePath: imagePath, onSelectArea: onSelectArea,),
   );
  }

}

class SelectImageAreaTextDetectProvider extends StatefulWidget {
  const SelectImageAreaTextDetectProvider({Key? key, required this.imagePath,required this.onSelectArea}) : super(key: key);
  final String imagePath;
  final SelectAreaCallBack onSelectArea;

  @override
  _SelectImageAreaTextDetectProviderState createState() =>
      _SelectImageAreaTextDetectProviderState();
}

class _SelectImageAreaTextDetectProviderState extends State<SelectImageAreaTextDetectProvider> {

  @override
  void initState() {
    super.initState();
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     var state  = Provider.of<SelectImageAreaTextDetectNotifier>(context,listen: false);
     state.initState(widget.imagePath,widget.onSelectArea);
   });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Consumer<SelectImageAreaTextDetectNotifier>(
      builder: (context, state, child) {
        Widget buildInstruct(Size size) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.back_hand, size: 22,color: Colors.white,),
                  paddingRight(10),
                  Text("Drag the rectangle to the", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w900)),
                  paddingRight(5),
                  Text("text", style: TextStyleTheme.customTextStyle(Colors.blue, 16, FontWeight.w900).apply(decoration: TextDecoration.underline))
                ],
              ),
              paddingTop(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RippleButton(
                    bgColor: Colors.red,
                    onTap: (){ state.navigateBackScreen(context); },
                    buttonWidth: size.width * 0.4,
                    child: Center(child: Text("Nah! Retake!", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),),
                  RippleButton(bgColor: Colors.blue, onTap: () { state.cropImageFor(); }, buttonWidth: size.width * 0.4, child: Center(child: Text("Detect", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),
                  ),
                ],
              )
            ],
          );
        }

        Widget buildConfirmButtons(Size size) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RippleButton(
                  bgColor: Colors.red,
                  onTap: (){ state.navigateBackScreen(context); },
                  buttonWidth: size.width * 0.4,
                  child: Center(child: Text("Nah! Retake!", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),),
              RippleButton(
                  bgColor: Colors.blueAccent,
                  onTap: () { state.itemProcessIndex = 1; state.notifyListeners(); },
                  buttonWidth: size.width * 0.4,
                  child: Center(child: Text("That's Good!", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))))
            ],
          );
        }

        Widget buildLastButtons(Size size) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RippleButton(
                bgColor:Colors.blueAccent,
                onTap: (){ state.itemProcessIndex = 1; state.notifyListeners(); },
                buttonWidth: size.width * 0.56,
                child: Center(child: Text("High Light More Text", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),),
              RippleButton(
                bgColor: Colors.lightBlueAccent, onTap: () {
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
              },
                buttonWidth: size.width * 0.3,
                child: Center(child: Text("Next", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),)
            ],
          );
        }

        return WillPopScope(
            onWillPop: () async {
              state.navigateBackScreen(context);
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
                            Center(child: state.isProcessing == true ? const CircularProgressIndicator(color: Colors.white) : state.itemProcessIndex == -1 || state.itemProcessIndex == 3 ?
                            PhotoView(imageProvider: FileImage(File(widget.imagePath)))
                                :Crop(
                              key: UniqueKey(),
                              baseColor: Colors.black,
                              controller: state.cropController,
                              initialSize: 0.25,
                              image:File(widget.imagePath).readAsBytesSync(),
                              cornerDotBuilder: (size, cornerIndex) {return const DotControl(color: Colors.black,);},
                              onCropped: (v){ state.onCropped(context,v); },
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
                            state.itemProcessIndex == -1
                                ? buildConfirmButtons(size)
                                : state.itemProcessIndex == 3 ? buildLastButtons(size) : buildInstruct(size)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
      }
    );
  }
}
