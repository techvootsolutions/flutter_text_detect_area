// import 'dart:io';
// import 'dart:math';
// import 'dart:ui' as ui;
// import 'dart:ui';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
//
// import 'coordinates_translator.dart';
//
// List<TextBlock> selectedTexts = [];
//
// class TextRecognizerPainter extends CustomPainter {
//   TextRecognizerPainter(
//     this.lastTapPosition,
//     this.recognizedText,
//     this.imageSize,
//     this.rotation,
//     this.cameraLensDirection,
//   );
//
//   final Offset? lastTapPosition;
//   final RecognizedText recognizedText;
//   final Size imageSize;
//   final InputImageRotation rotation;
//   final CameraLensDirection cameraLensDirection;
//
//   var colorsList = [
//     Colors.lightGreenAccent,
//     Colors.lightBlueAccent,
//     Colors.deepOrangeAccent,
//     Colors.limeAccent,
//     Colors.pinkAccent
//   ];
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     print("size $size");
//     for (final textBlock in recognizedText.blocks) {
//       final left = translateX(
//         textBlock.boundingBox.left,
//         size,
//         imageSize,
//         rotation,
//         cameraLensDirection,
//       );
//       final top = translateY(
//         textBlock.boundingBox.top,
//         size,
//         imageSize,
//         rotation,
//         cameraLensDirection,
//       );
//       final right = translateX(
//         textBlock.boundingBox.right,
//         size,
//         imageSize,
//         rotation,
//         cameraLensDirection,
//       );
//       final bottom = translateY(
//         textBlock.boundingBox.bottom,
//         size,
//         imageSize,
//         rotation,
//         cameraLensDirection,
//       );
//       //
//       // canvas.drawRect(
//       //   Rect.fromLTRB(left, top, right, bottom),
//       //   paint,
//       // );
//
//       // Rest of logic for positioning and drawing text
//       final List<Offset> cornerPoints = <Offset>[];
//
//       for (final point in textBlock.cornerPoints) {
//         double x = translateX(
//           point.x.toDouble(),
//           size,
//           imageSize,
//           rotation,
//           cameraLensDirection,
//         );
//         double y = translateY(
//           point.y.toDouble(),
//           size,
//           imageSize,
//           rotation,
//           cameraLensDirection,
//         );
//
//         if (Platform.isAndroid) {
//           switch (cameraLensDirection) {
//             case CameraLensDirection.front:
//               switch (rotation) {
//                 case InputImageRotation.rotation0deg:
//                 case InputImageRotation.rotation90deg:
//                   break;
//                 case InputImageRotation.rotation180deg:
//                   x = size.width - x;
//                   y = size.height - y;
//                   break;
//                 case InputImageRotation.rotation270deg:
//                   x = translateX(
//                     point.y.toDouble(),
//                     size,
//                     imageSize,
//                     rotation,
//                     cameraLensDirection,
//                   );
//                   y = size.height -
//                       translateY(
//                         point.x.toDouble(),
//                         size,
//                         imageSize,
//                         rotation,
//                         cameraLensDirection,
//                       );
//                   break;
//               }
//               break;
//             case CameraLensDirection.back:
//               switch (rotation) {
//                 case InputImageRotation.rotation0deg:
//                 case InputImageRotation.rotation270deg:
//                   break;
//                 case InputImageRotation.rotation180deg:
//                   x = size.width - x;
//                   y = size.height - y;
//                   break;
//                 case InputImageRotation.rotation90deg:
//                   x = size.width -
//                       translateX(
//                         point.y.toDouble(),
//                         size,
//                         imageSize,
//                         rotation,
//                         cameraLensDirection,
//                       );
//                   y = translateY(
//                     point.x.toDouble(),
//                     size,
//                     imageSize,
//                     rotation,
//                     cameraLensDirection,
//                   );
//                   break;
//               }
//               break;
//             case CameraLensDirection.external:
//               break;
//           }
//         }
//
//         cornerPoints.add(Offset(x, y));
//       }
//
//       bool isInsideSquare(double x, double y, double left, double top,
//           double right, double bottom) {
//         return x >= left && x <= right && y - 60 >= top && y - 60 <= bottom;
//       }
//
//       bool isTapInsidePolygon = isInsideSquare(
//           lastTapPosition!.dx, lastTapPosition!.dy, left, top, right, bottom);
//       int index = selectedTexts
//           .indexWhere((element) => element.text.contains(textBlock.text));
//       if (isTapInsidePolygon && index < 0) {
//         selectedTexts.add(textBlock);
//       }
//
//       final Paint paint = Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 3.0
//         // ..color = Colors.lightGreenAccent;
//         ..color = index >= 0
//             ? Colors.white
//             : colorsList[Random().nextInt(colorsList.length)];
//
//       final Paint textBackground = Paint()..color = const Color(0x99000000);
//
//       Paint highLightPainter = Paint()
//         ..style = PaintingStyle.fill
//         ..color = Colors.black.withOpacity(0.3);
//
//       // Add the first point to close the polygon
//       cornerPoints.add(cornerPoints.first);
//       canvas.drawPoints(PointMode.polygon, cornerPoints, paint);
//       if (index >= 0) {
//         final path = Path();
//         path.moveTo(cornerPoints.first.dx, cornerPoints.first.dy);
//         for (int i = 1; i < cornerPoints.length; i++) {
//           path.lineTo(cornerPoints[i].dx, cornerPoints[i].dy);
//         }
//         canvas.drawPath(path, highLightPainter);
//         path.close();
//         // canvas.drawPoints(PointMode.polygon, cornerPoints, filledPainter);
//       }
//       // textTapWithPosition.forEach((element) {
//       //   if(element.textBlock == null){
//       //     textTapWithPosition.remove(element);
//       //   }
//       // });
//       // bool isTapInsideBlock = textTapWithPosition.any((textTapWithPosition) {
//       //   bool isTapBlock = (textTapWithPosition.position?.dx ?? 0) >= left &&
//       //       (textTapWithPosition.position?.dx ?? 0) <= right &&
//       //       (textTapWithPosition.position?.dy ?? 0) >= top &&
//       //       (textTapWithPosition.position?.dy ?? 0) <= bottom;
//       //   if(isTapBlock){
//       //     print("TAP ADD TRUE");
//       //     textTapWithPosition.textBlock = TextBlock(text: textBlock.text, lines: textBlock.lines, boundingBox: textBlock.boundingBox, recognizedLanguages: textBlock.recognizedLanguages, cornerPoints: textBlock.cornerPoints);
//       //   }
//       //   // print("${textTapWithPosition.textBlock?.text} ${textTapWithPosition.textBlock == textBlock}");
//       //   return isTapBlock || (textTapWithPosition.textBlock?.boundingBox == textBlock.boundingBox);
//       // });
//       // if(isTapInsideBlock) {
//       //   // print("TAG TAP: ${textTapWithPosition.where((element) => element.textBlock!=null).first.textBlock?.text}");
//       // }
//       // if (isTapInsideBlock) {
//       //   canvas.drawRect(
//       //     Rect.fromLTRB(left, top, right, bottom),
//       //     highlightBackground,
//       //   );
//       // }
//       final ParagraphBuilder builder = ParagraphBuilder(
//         ParagraphStyle(
//             textAlign: TextAlign.left,
//             // maxLines: 1,
//             fontSize: 16,
//             textDirection: TextDirection.ltr),
//       );
//       builder.pushStyle(
//           // ui.TextStyle(color: Colors.lightGreenAccent, background: background));
//           ui.TextStyle(
//               fontSize: 17,
//               color: index >= 0
//                   ? Colors.white
//                   : colorsList[Random().nextInt(colorsList.length)],
//               background: textBackground));
//       builder.addText(textBlock.text);
//
//       builder.pop();
//       canvas.drawParagraph(
//         builder.build()
//           ..layout(ParagraphConstraints(
//             width: ((right - left) + 31).abs(),
//           )),
//         Offset(
//             Platform.isAndroid &&
//                     cameraLensDirection == CameraLensDirection.front
//                 ? right
//                 : left,
//             top),
//       );
//
//       // final TextPainter textPainter = TextPainter(
//       //   text: TextSpan(
//       //     text: textBlock.text,
//       //     recognizer: TapGestureRecognizer()
//       //       ..onTap = () {
//       //         // Handle tap event here
//       //         print('Text tapped! ${textBlock.text}');
//       //         Clipboard.setData(ClipboardData(text: textBlock.text));
//       //       },
//       //     style: TextStyle(
//       //       fontSize: 25,
//       //       color: colorsList[Random().nextInt(colorsList.length)],
//       //     ),
//       //   ),
//       //   textDirection: TextDirection.ltr,
//       //   maxLines: 1,
//       // );
//       // textPainter.layout();
//       // textPainter.paint(
//       //   canvas,
//       //   Offset(
//       //     Platform.isAndroid &&
//       //         cameraLensDirection == CameraLensDirection.front
//       //         ? right
//       //         : left,
//       //     top,
//       //   ),
//       // );
//     }
//   }
//
//   @override
//   bool shouldRepaint(TextRecognizerPainter oldDelegate) {
//     // return false;
//     return oldDelegate.recognizedText != recognizedText;
//   }
// }
