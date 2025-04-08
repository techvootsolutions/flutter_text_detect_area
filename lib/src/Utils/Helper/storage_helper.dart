import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as im;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class StorageHelper {
  /// /storage/emulated/0/Android/data/com.example.snapshop/files/MyGallery
  static Future<String> getGalleryDirectory() async {
    final Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = (await getApplicationDocumentsDirectory());
    }
    // final directory = await getExternalStorageDirectory();
    final myImagePath = '${directory!.path}/MyGallery';
    return myImagePath;
  }

  static Future<File> saveFileToDirectory(String fileName, File file) async {
    final myGalleryPath = await getGalleryDirectory();
    final filePath = '$myGalleryPath/$fileName';
    if (!await Directory(myGalleryPath).exists()) {
      await Directory(myGalleryPath).create();
    }
    File fileDef = File(filePath);
    await fileDef.create(recursive: true);
    Uint8List bytes = await file.readAsBytes();
    await fileDef.writeAsBytes(bytes);
    return File(filePath);
  }

  static bool isImageFile(File file) =>
      path.extension(file.path).endsWith(".jpg") ||
              path.extension(file.path).endsWith(".jpeg")
          ? true
          : false;

  static Future<File?> compressImageAndVideo(File file) async {
    // if (file == null) {
    //   return null;
    // }
    bool isImage = isImageFile(file);
    final bytes = file.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (isImage && mb > 1 || !isImage && mb > 2) {
      if (isImage) {
        int rand = math.Random().nextInt(10000);
        im.Image image = im.decodeImage(file.readAsBytesSync())!;
        im.Image smallerImage = im.copyResize(image,
            width: image.width,
            height: image
                .height); // choose the size here, it will maintain aspect ratio
        return File("${await getGalleryDirectory()}/img_$rand.jpg")
          ..writeAsBytesSync(im.encodeJpg(smallerImage, quality: 73));
      } else {}
    } else {
      return file;
    }
    return null;
  }
}
