import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_text_detect_by_area/src/Utils/Helper/storage_helper.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

typedef SelectAreaCallBack = void Function(dynamic p1);

class CustomException implements Exception {
  final message;
  final prefix;

  CustomException([this.message, this.prefix]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class TextDetectException extends CustomException {
  TextDetectException([String? message])
      : super(message, "Unable to detect text");
}

class SelectImageAreaTextDetectNotifier extends ChangeNotifier{
  String fileName = '/TEMP_IMG.jpg';
  String tempPath = "";
  String selectedImagePath = "";
  final cropController = CropController();
  var itemProcessIndex = 0;/// 0 for detect text once,1 for detect text more
  final TextRecognizer recognizer = GoogleVision.instance.textRecognizer();

  var isProcessing = false;
  var isImageLoading = true;
  var detectOneTime = false;

  bool isDisposed = false;///To prevent Unhandled Exception: A ChangeNotifier was used after being disposed.

  List detectedValues = [];

  SelectAreaCallBack? onSelectArea;

  set setProcessing(bool value) {
      isProcessing = value;
      print("isProcessing $value");
      notifyListeners();
  }
  set setImageLoading(bool value) {
      isImageLoading = value;
      notifyListeners();
  }
  
  Uint8List? croppedData;
  
  set setCroppedData(Uint8List? value) {
      croppedData = value;
      notifyListeners();
  }

  void initState(String imagePath,SelectAreaCallBack onSelectArea, bool isDetectOnce){
    this.onSelectArea = onSelectArea;
    selectedImagePath = imagePath;
    detectOneTime = isDetectOnce;
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
    } catch(e) {
      print("TextDetectException : $e");
      throw TextDetectException(e.toString());
    }
    setProcessing = false;
    print("detectOneTime $detectOneTime :: itemProcessIndex $itemProcessIndex");
    if(detectOneTime && itemProcessIndex == 0){
      onSelectArea?.call(detectOneTime ? value : detectedValues);
      Navigator.of(context).pop();
    } else {
      itemProcessIndex = 1;
      detectedValues.add(value);
      notifyListeners();
    }
  }

  void navigateBackScreen(BuildContext context) {
    Navigator.pop(context);
  }

  void onCropStatusChanged(CropStatus status) {
    if(status == CropStatus.ready){
      setImageLoading = false;
    }
  }

  void initTempImage()async{
    tempPath = await StorageHelper.getGalleryDirectory()+fileName;
    StorageHelper.saveFileToDirectory(fileName,File(selectedImagePath));
    notifyListeners();
  }

  void onTapDone(BuildContext context){
    onSelectArea?.call(detectedValues);
    Navigator.of(context).pop();
  }

  void cropImageFor(){
    cropController.crop();
    croppedData = null;
    setProcessing = true;
  }

  @override
  void notifyListeners() {
    if(!isDisposed) {
      super.notifyListeners();
    }
  }
  @override
  void dispose() {
    File(tempPath).deleteSync();
    isDisposed = true;
    super.dispose();
  }



}