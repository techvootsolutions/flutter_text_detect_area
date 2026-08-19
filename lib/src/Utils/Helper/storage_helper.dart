import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as im;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class StorageHelper {
  /// Gets the local gallery/cache directory for temporary processing
  static Future<String> getGalleryDirectory() async {
    final Directory? directory;
    if (!kIsWeb && Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = (await getApplicationDocumentsDirectory());
    }
    final myImagePath = '${directory!.path}/MyGallery';
    return myImagePath;
  }

  static Future<File> saveFileToDirectory(String fileName, File file) async {
    final myGalleryPath = await getGalleryDirectory();
    final filePath = '$myGalleryPath/$fileName';
    if (!await Directory(myGalleryPath).exists()) {
      await Directory(myGalleryPath).create(recursive: true);
    }
    File fileDef = File(filePath);
    await fileDef.create(recursive: true);
    Uint8List bytes = await file.readAsBytes();
    await fileDef.writeAsBytes(bytes);
    return File(filePath);
  }

  static bool isImageFile(File file) {
    final ext = path.extension(file.path).toLowerCase();
    return ext == '.jpg' ||
        ext == '.jpeg' ||
        ext == '.png' ||
        ext == '.webp' ||
        ext == '.bmp';
  }

  static Future<File?> compressImageAndVideo(File file) async {
    bool isImage = isImageFile(file);
    final bytes = (await file.readAsBytes()).lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (isImage && mb > 1 || !isImage && mb > 2) {
      if (isImage) {
        int rand = math.Random().nextInt(10000);
        final fileBytes = await file.readAsBytes();
        im.Image? image = im.decodeImage(fileBytes);
        if (image == null) return file;
        im.Image smallerImage = im.copyResize(image,
            width: image.width,
            height: image
                .height); // choose the size here, it will maintain aspect ratio
        final galleryDir = await getGalleryDirectory();
        final compressedFile = File("$galleryDir/img_$rand.jpg");
        await compressedFile
            .writeAsBytes(im.encodeJpg(smallerImage, quality: 73));
        return compressedFile;
      }
    } else {
      return file;
    }
    return null;
  }
}
