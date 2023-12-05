# Flutter Text Detect Area
The easy way to use this package for text recognition by selecting area over the images and live camera in Flutter. Flutter Text Detect Area's text recognition can recognize/detect text from image's particular area by dragging/moving/panning area selector. They can also be used to recognise text once and more by passing value of detect once as true/false and also can set enable/disable image interactions by passing value of enableImageInteractions.

### Installing

1.  Add dependency to `pubspec.yaml`

    *Get the latest version in the 'Installing' tab on [pub.dev](https://pub.dev/packages/flutter_text_detect_area)*

```dart
  dependencies:
      flutter_text_detect_area: <latest-version>
```

2.  Import the package
```dart
import 'package:flutter_text_detect_area/flutter_text_detect_area.dart';
```

## Screenshot
<img src="https://raw.githubusercontent.com/techvootsolutions/flutter_text_detect_area/main/images/android.gif" width="280"> <img src="https://raw.githubusercontent.com/techvootsolutions/flutter_text_detect_area/main/images/camera.gif" width="280">

### Pick Image
You can use <a src="https://pub.dev/packages/image_picker">`Image Picker`</a> for pick image from gallery/camera to pass the image for text `recognition/detection` by it's `particular areas`

```dart
import 'package:image_picker/image_picker.dart';

final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
```

### Text Recognition/Detection Through Select area over image

After getting the picked image, we can start doing text recognition by navigate to detection screen.

```dart
​
Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SelectImageAreaTextDetect(
                                detectOnce: isDetectOnce,
                                enableImageInteractions: enableImageInteractions,
                                imagePath: pickedFile?.path ?? '',
                                onDetectText: (v) {
                                  setState(() {
                                    ///For single detection
                                    if (v is String) {
                                      detectedValue = v;
                                    }
                                    ///For multiple area's detections
                                    if (v is List) {
                                      int counter = 0;
                                      v.forEach((element) {
                                        detectedValue += "$counter. \t\t $element \n\n";
                                        counter++;
                                      });
                                    }
                                  });
                                }, onDetectError: (error) {
                                  print(error);
                                  ///This error will occurred in Android only while user will try to crop image at max zoom level then ml kit will throw max 32 height/width exception
                                  if(error is PlatformException && (error.message?.contains("InputImage width and height should be at least 32!") ?? false)) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selected area should be able to crop image with at least 32 width and height.")));
                              }
},)));
```

### Output
If you'll pass detect once as true then the result of `Single Text Detection` is single dynamic value. 

Screenshot
-----------
<img src="https://raw.githubusercontent.com/techvootsolutions/flutter_text_detect_area/main/images/3.png" width="280">

### Output
If you'll pass detect once as false then the result of `Multiple Text Detection Through Particular Image's Area` list of dynamic values.

Screenshot
-----------
<img src="https://raw.githubusercontent.com/techvootsolutions/flutter_text_detect_area/main/images/6.png" width="280">

## Example Project
You can learn more from example project [here](https://github.com/techvootsolutions/flutter_text_detect_area/tree/main/example).

### Changelog
<p>Please see <a href="https://github.com/techvootsolutions/flutter_text_detect_area/blob/tvPrincy/CHANGELOG.md"><b>CHANGELOG </b></a>for more information what has changed recently.</p>

### Main Contributors
<ul>
  <li><a href="https://github.com/tvTushar">Tushar Chovatiya</a></li>
  <li><a href="https://github.com/tvPrincy">Princy Varsani</a></li>
  <li><a href="https://github.com/techkevin">Kevin Baldha</a></li>
</ul>
