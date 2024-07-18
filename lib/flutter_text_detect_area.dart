/*
* Flutter Text Detect Area
*
* The easy way to use this package for text recognition by selecting area over the images and live camera in Flutter.
* Flutter Text Detect Area's text recognition can recognize/detect text from image's particular area by dragging/moving/panning area selector.
* They can also be used to recognise text once and more by passing value of detect once as true/false
* and also can set enable/disable image interactions by passing value of enableImageInteractions.
* Developed by Techvoot Solutions
*
*/

///FlutterTextDetectArea
library flutter_text_detect_area;

///SelectImageAreaTextDetect
export 'src/Screens/SelectImageAreaTextDetect/select_image_area_text_detect.dart';

///CustomRippleButton
export 'src/Widgets/ripple_button.dart';

///LiveTextRecognizerView
export 'src/Screens/camera/live_text_recognizer_view.dart';

export 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
