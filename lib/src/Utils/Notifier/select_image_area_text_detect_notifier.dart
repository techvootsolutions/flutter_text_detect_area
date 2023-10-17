import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_text_detect_by_area/src/Utils/Helper/storage_helper.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

typedef SelectAreaCallBack = void Function(dynamic p1);

class SelectImageAreaTextDetectNotifier extends ChangeNotifier{
  String fileName = '/TEMP_IMG.jpg';
  String tempPath = "";
  String selectedImagePath = "";
  final cropController = CropController();
  var itemProcessIndex = -1;//0 for confirm,1 for item,2 for price,3 for one more highlight
  final TextRecognizer recognizer = GoogleVision.instance.textRecognizer();
  var isProcessing = false;
  SelectAreaCallBack? onSelectArea;
  set isSetProcessing(bool value) {
      isProcessing = value;
      notifyListeners();
  }
  
  Uint8List? croppedData;
  
  set setCroppedData(Uint8List? value) {
      croppedData = value;
      notifyListeners();
  }

  void initState(String imagePath,SelectAreaCallBack onSelectArea ){
    this.onSelectArea = onSelectArea;
    this.selectedImagePath = imagePath;
    initTempImage();
  }

  void onCropped(BuildContext context,Uint8List cropped) async {
    setCroppedData = cropped;
    await File(tempPath).writeAsBytes(croppedData!);
    final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(File(tempPath));
    var value;
    try {
      var results = await recognizer.processImage(visionImage);
      value = results.text!.replaceAll("\n", " ");

    }catch(e){
      value = "GoogleVisionImage Exception : $e";
      print(value);
    }
    onSelectArea?.call(value);
    await Future.delayed(const Duration(milliseconds: 1500));
    isSetProcessing = false;
    Navigator.of(context).pop();

  }

  void navigateBackScreen(BuildContext context) {
    Navigator.pop(context);
  }

  void initTempImage()async{
    tempPath = await StorageHelper.getGalleryDirectory()+fileName;
    StorageHelper.saveFileToDirectory(fileName,File(selectedImagePath));
    notifyListeners();
  }

  void cropImageFor(){
    isSetProcessing = true;
    cropController.crop();
    croppedData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    File(tempPath).deleteSync();
    super.dispose();
  }


}