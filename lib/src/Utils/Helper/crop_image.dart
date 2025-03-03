import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CropImage {
  static Future cropArea(String srcFilePath, String destFilePath, bool flip,
      int left, int top, int w, int h) async {
    var bytes = await File(srcFilePath).readAsBytes();
    img.Image src = img.decodeImage(bytes)!;
    int offsetX = left * 2;
    int offsetY = top * 2;
    img.Image destImage = img.copyCrop(src,
        x: offsetX, y: offsetY, width: w - left, height: h - top);
    if (flip) {
      destImage = img.flipVertical(destImage);
    }
    var jpg = img.encodeJpg(destImage);
    await File(destFilePath).writeAsBytes(jpg);
  }

  static Future<ui.Image> getCroppedImage(ui.Image image, Rect src, Rect dst) {
    var pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);

    //First test with this painting
    Paint paint = Paint();
    paint.color = Colors.red;
    Paint paint1 = Paint();
    paint1.color = Colors.blue;
    canvas.drawRect(src, paint);
    canvas.drawRect(dst, paint1);
    /*return pictureRecorder
        .endRecording()
        .toImage(src.width.floor(), src.height.floor());*/
    canvas.clipPath(Path()..addRect(dst));
    //paintImage(canvas: canvas, rect: src, image: image, fit: BoxFit.fitHeight);
    paintImage(canvas: canvas, rect: dst, image: image, fit: BoxFit.fitHeight);
    //canvas.drawImageRect(image, src, dst, Paint());
    return pictureRecorder
        .endRecording()
        .toImage(src.width.floor(), src.height.floor());
  }

  static Future<File> cropImage(double height, double width, double left,
      double top, var imagedata) async {
    ui.Image? image = await getImageFromPath(imagedata, false);
    Rect src =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    Rect dst = Rect.fromLTWH(left, top, width * 2, height * 2);
    // Convert canvas to image
    final ui.Image markerAsImage = await getCroppedImage(image, src, dst);

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(
        format: ui.ImageByteFormat.png) as ByteData;
    final Uint8List uint8List = byteData.buffer.asUint8List();
    return File(imagedata).writeAsBytes(uint8List);
  }

  static Future<File> getCropImage(
      Size size, double left, double top, var imagedata) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    Paint paint = Paint();
    paint.color = Colors.red;
    Rect rect1 = Rect.fromLTWH(left, top, size.width, size.height);
    canvas.drawRect(rect1, paint);
    // Add image
    ui.Image? image = await getImageFromPath(imagedata, false);
    // Add path for crop image
    canvas.clipPath(Path()..addRect(rect1));
    // Add image
    paintImage(
        canvas: canvas, image: image, rect: rect1, alignment: Alignment.center);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(
        format: ui.ImageByteFormat.png) as ByteData;
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return File(imagedata).writeAsBytes(uint8List);
  }

  static Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);
    final file = File('${(await getTemporaryDirectory()).path}/temp.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  static Future<ui.Image> getImageFromPath(
      String imagePath, bool isFromAssets) async {
    File imageFile = isFromAssets == true
        ? await getImageFileFromAssets(imagePath)
        : File(imagePath);
    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  static Future<ui.Image> getImageFromBytes(Uint8List bytes) async {
    Uint8List imageBytes = bytes.buffer.asUint8List();

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }
}
