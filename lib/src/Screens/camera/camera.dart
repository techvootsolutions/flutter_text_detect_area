import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_detect_area/flutter_text_detect_area.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.customPaint,
    required this.onImage,
    required this.detectedTexts,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.onSelectionChanged,
    required this.isFrozen,
    required this.onFreezeToggle,
    required this.interactionDisabled,
    required this.onInteractionToggle,
    this.initialCameraLensDirection = CameraLensDirection.back,
  });

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final Function(bool isSelectionActive)? onSelectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  final List<DetectedTextInfo> detectedTexts;
  final bool isFrozen;
  final Function(bool frozen) onFreezeToggle;
  final bool interactionDisabled;
  final Function(bool disabled) onInteractionToggle;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;
  bool _isSelectionActive = false;
  int _manualRotation = 0; // 0, 90, 180, 270

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? const Center(
                    child: Text('Changing camera lens'),
                  )
                : CameraPreview(
                    _controller!,
                    child: widget.customPaint,
                  ),
          ),
          AbsorbPointer(
            absorbing: widget.interactionDisabled,
            child: SelectionArea(
                onSelectionChanged: (v) {
                  final isActive = v?.plainText.isNotEmpty ?? false;
                  if (_isSelectionActive != isActive) {
                    setState(() {
                      _isSelectionActive = isActive;
                    });
                    if (widget.onSelectionChanged != null) {
                      widget.onSelectionChanged!(isActive);
                    }
                  }
                },
                child: Stack(
                    children: widget.detectedTexts.map((detectedText) {
                  return Positioned(
                    key: ValueKey(
                        detectedText.text + detectedText.position.toString()),
                    left: detectedText.position.dx,
                    top: detectedText.position.dy,
                    child: RotatedBox(
                      quarterTurns: _manualRotation ~/ 90,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.5 * 255).toInt()),
                        ),
                        child: Text(
                          detectedText.text,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  );
                }).toList())),
          ),
          // _zoomControl(),
          _backButton(),
          // _changingSelection ? _doneButton() : Container(),
          _switchLiveCameraToggle(),
          _rotateDetectionButton(),
          _freezeDetectionToggle(),
          _interactionToggle(),
          if (widget.isFrozen) _frozenIndicator(),
          // _exposureControl(),
        ],
      ),
    );
  }

  Widget _frozenIndicator() => Positioned(
        top: 40,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(200),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "STATIC MODE (FROZEN)",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );

  Widget _backButton() => Positioned(
        top: 40,
        left: 8,
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(widget.detectedTexts),
            backgroundColor: Colors.black54,
            child: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            ),
          ),
        ),
      );

  Widget _freezeDetectionToggle() => Positioned(
        top: 140,
        right: 8,
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => widget.onFreezeToggle(!widget.isFrozen),
            backgroundColor:
                widget.isFrozen ? Colors.redAccent : Colors.black54,
            child: Icon(
              widget.isFrozen
                  ? Icons.play_arrow_outlined
                  : Icons.pause_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget _interactionToggle() => Positioned(
        top: 190,
        right: 8,
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () =>
                widget.onInteractionToggle(!widget.interactionDisabled),
            backgroundColor:
                widget.interactionDisabled ? Colors.redAccent : Colors.black54,
            child: Icon(
              widget.interactionDisabled
                  ? Icons.lock_outlined
                  : Icons.lock_open_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget doneButton() => Positioned(
        top: 85,
        right: 8,
        child: SizedBox(
          width: 60.0,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return Colors.black54; // Use the component's default.
                },
              ),
            ),
            onPressed: () => Navigator.of(context).pop(widget.detectedTexts),
            child: const Text(
              "Done",
            ),
          ),
        ),
      );

  Widget _rotateDetectionButton() => Positioned(
        top: 90,
        right: 8,
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () {
              setState(() {
                _manualRotation = (_manualRotation + 90) % 360;
              });
            },
            backgroundColor: Colors.black54,
            child: RotationTransition(
              turns: AlwaysStoppedAnimation(_manualRotation / 360),
              child: const Icon(
                Icons.screen_rotation_outlined,
                size: 25,
              ),
            ),
          ),
        ),
      );

  Widget _switchLiveCameraToggle() => Positioned(
        top: 40,
        // bottom: 8,
        right: 8,
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: _switchLiveCamera,
            backgroundColor: Colors.black54,
            child: Icon(
              Platform.isIOS
                  ? Icons.flip_camera_ios_outlined
                  : Icons.flip_camera_android_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget zoomControl() => Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.black,
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Slider(
                      value: _currentZoomLevel,
                      min: _minAvailableZoom,
                      max: _maxAvailableZoom,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      onChanged: (value) async {
                        setState(() {
                          _currentZoomLevel = value;
                        });
                        await _controller?.setZoomLevel(value);
                      },
                    ),
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          '${_currentZoomLevel.toStringAsFixed(1)}x',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget exposureControl() => Positioned(
        top: 40,
        right: 8,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 250,
          ),
          child: Column(children: [
            Container(
              width: 55,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_currentExposureOffset.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await _controller?.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            )
          ]),
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    if (_isSelectionActive || widget.isFrozen) return;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    var camera = _cameras[_cameraIndex];

    // Determine sensor orientation
    final sensorOrientation = camera.sensorOrientation;

    // Determine rotation compensation based on platform
    InputImageRotation rotation;
    var rotationCompensation =
        _orientations[_controller!.value.deviceOrientation];
    if (rotationCompensation == null) return null;

    if (camera.lensDirection == CameraLensDirection.front) {
      // Front-facing camera
      rotationCompensation = (rotationCompensation + sensorOrientation) % 360;
    } else {
      // Back-facing camera
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }

    // Apply manual rotation offset for physical rotation when system lock is ON
    rotationCompensation = (rotationCompensation + _manualRotation) % 360;

    // Convert rotation compensation to InputImageRotation
    switch (rotationCompensation) {
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      case 0:
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    // Determine image format based on platform
    InputImageFormat format;
    if (Platform.isAndroid) {
      format = InputImageFormat.nv21;
    } else {
      format = InputImageFormat.bgra8888;
    }

    if (image.planes.isEmpty) return null;

    // Convert planes to bytes
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    // Create InputImage using bytes and metadata
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: image.planes[0].bytesPerRow, // used only in iOS
      ),
    );
  }
}
