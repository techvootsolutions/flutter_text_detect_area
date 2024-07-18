import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_detect_area/src/Screens/camera/camera.dart';
import 'package:flutter_text_detect_area/src/Screens/camera/coordinates_translator.dart';
import 'package:flutter_text_detect_area/src/Widgets/custom_script_dropdown.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

enum LiveDetectorViewMode { liveFeed, gallery }

///This class will collect the recognised text and it's position in the text blocks
class DetectedTextInfo {
  ///Detected Text will store into text variable and x,y position will be in position as offset with x,y
  ///ex. detect text is 'Hello' and its position is x = 1.0 ,y = 2.0
  ///then this class with values will looks like
  ///DetectedTextInfo(text : 'Hello', position : Offset(1.0,2.0)

  final String text;
  final Offset position;

  DetectedTextInfo({
    required this.text,
    required this.position,
  });
}

class LiveTextRecognizerView extends StatefulWidget {
  const LiveTextRecognizerView({
    super.key,
    this.showLangScriptDropDown = false,
    this.initialRecognitionScript,
    this.initialDetectionMode = LiveDetectorViewMode.liveFeed,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  });

  // : assert(
  //     dropDownLangScriptWidget == null || initialRecognitionScript != null,
  //     'If dropDownLangScriptWidget is provided, recognitionScript must also be provided.',
  //     // Additional assertion message for clarity
  //     // You can customize the error message as per your requirement
  //   );

  final LiveDetectorViewMode initialDetectionMode;
  final TextRecognitionScript? initialRecognitionScript;
  final bool showLangScriptDropDown;
  final CameraLensDirection initialCameraLensDirection;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final Function(LiveDetectorViewMode mode)? onDetectorViewModeChanged;

  @override
  State<LiveTextRecognizerView> createState() => _LiveTextRecognizerViewState();
}

class _LiveTextRecognizerViewState extends State<LiveTextRecognizerView> {
  LiveDetectorViewMode? _mode = LiveDetectorViewMode.liveFeed;
  TextRecognitionScript? _script = TextRecognitionScript.latin;
  TextRecognizer? _textRecognizer = TextRecognizer(script:TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final _cameraLensDirection = CameraLensDirection.back;
  List<DetectedTextInfo> detectedTexts = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _mode = widget.initialDetectionMode;
      print("HEHEHEH:: ${widget.initialRecognitionScript?.name}");
      _script = widget.initialRecognitionScript ?? TextRecognitionScript.latin;
      print("HEHEHEH:: ${_script?.name}");
      _textRecognizer = TextRecognizer(script: _script ?? TextRecognitionScript.latin);
      setState(() {});
    });
    // selectedTexts.clear();
    super.initState();
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer?.close();
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
          widget.showLangScriptDropDown == true
              ? CustomScriptDropdown(
                  selectedScript: _script,
                  onChanged: (TextRecognitionScript? script) {
                    if (script != null) {
                      setState(() {
                        _script = script;
                        _textRecognizer?.close();
                        _textRecognizer = TextRecognizer(script: _script ?? TextRecognitionScript.latin);
                        detectedTexts.clear();
                        _isBusy = false;
                      });
                    }
                  })
              : Container(),
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
      widget.onDetectorViewModeChanged!(_mode ?? LiveDetectorViewMode.liveFeed);
    }
    setState(() {});
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    try {
      _textRecognizer?.processImage(inputImage).then((recognizedText) {
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
          // final right = translateX(
          //   textBlock.boundingBox.right,
          //   size,
          //   inputImage.metadata!.size,
          //   inputImage.metadata!.rotation,
          //   _cameraLensDirection,
          // );
          // final bottom = translateY(
          //   textBlock.boundingBox.bottom,
          //   size,
          //   inputImage.metadata!.size,
          //   inputImage.metadata!.rotation,
          //   _cameraLensDirection,
          // );
          final Offset position = Offset(
              left, // Calculate X position
              top // Calculate Y position
              );

          detectedTexts
              .add(DetectedTextInfo(text: textBlock.text, position: position));
        }

        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
