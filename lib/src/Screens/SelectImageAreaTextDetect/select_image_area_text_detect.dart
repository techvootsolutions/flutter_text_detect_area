import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_detect_by_area/src/Element/padding_class.dart';
import 'package:flutter_text_detect_by_area/src/Style/text_style.dart';
import 'package:flutter_text_detect_by_area/src/Utils/Notifier/select_image_area_text_detect_notifier.dart';
import 'package:flutter_text_detect_by_area/src/Widgets/ripple_button.dart';
import 'package:provider/provider.dart';

class SelectImageAreaTextDetect extends StatelessWidget{
  const SelectImageAreaTextDetect({super.key,required this.imagePath,required this.onDetectText,required this.onDetectError,this.detectOnce = true,this.enableImageInteractions = true});
      // : assert(imagePath != "", 'Require Image Path for detect text $imagePath');
  final String imagePath;
  ///Pass detectOnce as true if you want to detect multiple text on image
  ///after detection done press done for get detected text's as List ['text1','text2',.....'textN']
  final bool detectOnce;
  ///Pass enableImageInteractions as false if you don't want to enable users to interaction with selected image ex. zoom etc.
  final bool enableImageInteractions;
  final SelectAreaCallBack onDetectText;
  final OnDetectErrorCallBack onDetectError;
  @override
  Widget build(BuildContext context) {
    print("Image path For detect texts:: $imagePath");
    if(imagePath.isEmpty){
      Navigator.of(context).pop();
      return Container();
    }
   return ChangeNotifierProvider(
       create: (_) => SelectImageAreaTextDetectNotifier(),
      child: SelectImageAreaTextDetectProvider(imagePath: imagePath, onSelectArea: onDetectText,onDetectError: onDetectError,detectOnce: detectOnce,enableImageInteractions: enableImageInteractions),
   );
  }

}

class SelectImageAreaTextDetectProvider extends StatefulWidget {
  const SelectImageAreaTextDetectProvider({super.key, required this.imagePath,required this.onSelectArea,required this.onDetectError, this.detectOnce = true, this.enableImageInteractions = true});
      // : assert(imagePath != "", 'Require Image Path for detect text $imagePath');
  final String imagePath;
  final SelectAreaCallBack onSelectArea;
  final OnDetectErrorCallBack onDetectError;
  final bool detectOnce;
  final bool enableImageInteractions;

  @override
  _SelectImageAreaTextDetectProviderState createState() =>
      _SelectImageAreaTextDetectProviderState();
}

class _SelectImageAreaTextDetectProviderState extends State<SelectImageAreaTextDetectProvider> {
  Uint8List? imageData;
  @override
  void initState() {
    super.initState();
    imageData = File(widget.imagePath).readAsBytesSync();
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     var state  = Provider.of<SelectImageAreaTextDetectNotifier>(context,listen: false);
     state.initState(widget.imagePath,widget.onSelectArea,widget.onDetectError, widget.detectOnce ?? true);
   });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Consumer<SelectImageAreaTextDetectNotifier>(
      builder: (context, state, child) {

        Widget loader = const Flexible(child: Center(child: CircularProgressIndicator(color: Colors.white)));

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
                  state.isProcessing ? loader :
                  RippleButton(
                    isDisable: state.isProcessing || state.isImageLoading,
                    bgColor: Colors.blue, onTap: () { state.cropImageFor(); }, buttonWidth: size.width * 0.4, child: Center(child: Text("Detect", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),
                  ),
                ],
              )
            ],
          );
        }

        Widget buildHighLightMoreButtons(Size size) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // InkWell(
              //   onTap: state.isProcessing || state.isImageLoading? null :(){ state.itemProcessIndex = 0; state.notifyListeners(); },
              // ),
              RippleButton(
                isDisable: state.isProcessing || state.isImageLoading,
                bgColor:Colors.blueAccent,
                onTap: state.isProcessing || state.isImageLoading? null :(){ state.itemProcessIndex = 0; state.notifyListeners(); },
                buttonWidth: size.width * 0.56,
                child: Center(child: Text("High Light More Text", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),),
                state.isProcessing ? loader
                    : RippleButton(
                isDisable: state.isProcessing || state.isImageLoading,
                bgColor: Colors.lightBlueAccent, onTap: () { state.onTapDone(context); },
                buttonWidth: size.width * 0.3,
                child: Center(child: Text("Done", style: TextStyleTheme.customTextStyle(Colors.white, 16, FontWeight.w500))),)
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
                            // state.isProcessing == false ?
                            Crop(
                              interactive: widget.enableImageInteractions,
                              onStatusChanged: state.onCropStatusChanged,
                              baseColor: Colors.transparent,
                              maskColor: state.isImageLoading || state.isProcessing || state.itemProcessIndex == 1 ? Colors.transparent : null,
                              controller: state.cropController,
                              // initialArea: const Rect.fromLTWH(0, 0, 100, 50),
                              initialSize: 0.215,
                              image:imageData ?? File(widget.imagePath).readAsBytesSync(),
                              cornerDotBuilder: (size, cornerIndex) {return DotControl(color: state.isImageLoading || state.isProcessing || state.itemProcessIndex == 1 ? Colors.transparent : Colors.black,);},
                              onCropped: (v){ state.onCropped(context,v); },
                            ),
                            state.isImageLoading ? const Center(child: CircularProgressIndicator(color: Colors.white)) : Container(),
                          ]
                        )),
                    Container(
                      height: size.height * 0.18,
                      width: size.width,
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Center(child: state.itemProcessIndex == 1 && widget.detectOnce == false
                            ? buildHighLightMoreButtons(size)
                            : buildInstruct(size)),
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
