import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_detect_area/src/Screens/camera/camera.dart';
import 'package:flutter_text_detect_area/src/Screens/camera/coordinates_translator.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

enum LiveDetectorViewMode { liveFeed, gallery }

class DetectedTextInfo {
  final String text;
  final Offset position;

  DetectedTextInfo({
    required this.text,
    required this.position,
  });
}

class LiveTextRecognizerView extends StatefulWidget {
  LiveTextRecognizerView({
    super.key,
    this.initialDetectionMode = LiveDetectorViewMode.liveFeed,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  });

  final LiveDetectorViewMode initialDetectionMode;
  final CameraLensDirection initialCameraLensDirection;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final Function(LiveDetectorViewMode mode)? onDetectorViewModeChanged;

  @override
  State<LiveTextRecognizerView> createState() => _LiveTextRecognizerViewState();
}

class _LiveTextRecognizerViewState extends State<LiveTextRecognizerView> {
  late LiveDetectorViewMode _mode;
  var _script = TextRecognitionScript.latin;
  var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final _cameraLensDirection = CameraLensDirection.back;
  List<DetectedTextInfo> detectedTexts = [];

  @override
  void initState() {
    _mode = widget.initialDetectionMode;
    // selectedTexts.clear();
    super.initState();
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        if (v) {
          return;
        }
        Navigator.pop(context, detectedTexts);
      },
      child: Scaffold(
        body: Stack(children: [
          _mode == LiveDetectorViewMode.liveFeed
              ? CameraView(
                  customPaint: _customPaint,
                  onImage: _processImage,
                  onDetectorViewModeChanged: _onDetectorViewModeChanged,
                  initialCameraLensDirection: widget.initialCameraLensDirection,
                  onCameraLensDirectionChanged:
                      widget.onCameraLensDirectionChanged,
                  detectedTexts: detectedTexts,
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("LIVE FEED MODE OFF!!")],
                ),

          // Positioned(
          //     top: 30,
          //     left: 100,
          //     right: 100,
          //     child: Row(
          //       children: [
          //         Spacer(),
          //         Container(
          //             decoration: BoxDecoration(
          //               color: Colors.black54,
          //               borderRadius: BorderRadius.circular(10.0),
          //             ),
          //             child: Padding(
          //               padding: const EdgeInsets.all(4.0),
          //               child: _buildDropdown(),
          //             )),
          //         Spacer(),
          //       ],
          //     )),
        ]),
      ),
    );
  }

  void _onDetectorViewModeChanged() {
    if (_mode == LiveDetectorViewMode.liveFeed) {
      _mode = LiveDetectorViewMode.gallery;
    } else {
      _mode = LiveDetectorViewMode.liveFeed;
    }
    if (widget.onDetectorViewModeChanged != null) {
      widget.onDetectorViewModeChanged!(_mode);
    }
    setState(() {});
  }

  Widget _buildDropdown() => DropdownButton<TextRecognitionScript>(
        value: _script,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (TextRecognitionScript? script) {
          if (script != null) {
            setState(() {
              _script = script;
              _textRecognizer.close();
              _textRecognizer = TextRecognizer(script: _script);
            });
          }
        },
        items: TextRecognitionScript.values
            .map<DropdownMenuItem<TextRecognitionScript>>((script) {
          return DropdownMenuItem<TextRecognitionScript>(
            value: script,
            child: Text(script.name),
          );
        }).toList(),
      );

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    _textRecognizer.processImage(inputImage).then((recognizedText) {
      // setState(() {
      //
      // });
      // if (inputImage.metadata?.size != null &&
      //     inputImage.metadata?.rotation != null) {
      //   final painter = TextRecognizerPainter(
      //       tapPosition,
      //       recognizedText,
      //       inputImage.metadata!.size,
      //       inputImage.metadata!.rotation,
      //       _cameraLensDirection);
      //   _customPaint = CustomPaint(painter: painter);
      // } else {
      //   // TODO: set _customPaint to draw boundingRect on top of image
      //   _customPaint = null;
      // }
      _isBusy = false;

      // Clear previous detected texts
      detectedTexts.clear();

      // Store detected text information
      for (final textBlock in recognizedText.blocks) {
        // Calculate positions based on your logic
        // Example: Use translateX and translateY functions as per your requirements
        Size size = MediaQuery.of(context).size;
        final left = translateX(
          textBlock.boundingBox.left,
          size,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final top = translateY(
          textBlock.boundingBox.top,
          size,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final right = translateX(
          textBlock.boundingBox.right,
          size,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final bottom = translateY(
          textBlock.boundingBox.bottom,
          size,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final Offset position = Offset(
          left, // Calculate X position
          top, // Calculate Y position
        );

        detectedTexts.add(
          DetectedTextInfo(
            text: textBlock.text,
            position: position,
          ),
        );
      }

      if (mounted) {
        setState(() {});
      }
    });
  }
}
