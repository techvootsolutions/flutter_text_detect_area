import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_detect_area/flutter_text_detect_area.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Detect Area',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Ensures blue is the default theme color
          brightness: Brightness.light,
        ),
      ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.blue,
      //     brightness: Brightness.dark,
      //   ),
      // ),
      home: const MyHomePage(title: 'Flutter Text Detect Area'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String detectedValue = "";
  String cameraDetectedValue = "";
  bool isDetectOnce = true;
  bool enableImageInteractions = true;
  TextRecognitionScript initialRecognitionScript = TextRecognitionScript.latin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(widget.title),
        // ),
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2C).withValues(alpha: 0.2),
            const Color(0xFF2A2D3E)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              // Title
              const Text(
                "Flutter Text Detect Area",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                color: Colors.white.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Detection Mode",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(10),
                        isSelected: [isDetectOnce, !isDetectOnce],
                        selectedColor: Colors.white,
                        fillColor: Colors.blueAccent,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.38,
                              child: const Text("Detect Once")),
                          Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.38,
                              child: const Text("Detect More")),
                        ],
                        onPressed: (index) {
                          setState(() {
                            detectedValue = "";
                            isDetectOnce = index == 0;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                          dense: true,
                          onTap: () {
                            setState(() {
                              enableImageInteractions =
                                  !enableImageInteractions;
                            });
                          },
                          title: Text(
                              "${enableImageInteractions ? "Disable" : "Enable"} User Interactions Over Image"),
                          leading: Switch(
                              value: enableImageInteractions,
                              onChanged: (v) {
                                setState(() {
                                  enableImageInteractions = v;
                                });
                              })),
                      RippleButton(
                          bgColor: Colors.blueAccent,
                          shadowOffset: Offset.zero,
                          shadowBlurRadius: 2,
                          shadowSpreadRadius: 0,
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                detectedValue = cameraDetectedValue = "";
                              });
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (!context.mounted) return;
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      SelectImageAreaTextDetect(
                                        showLangScriptDropDown: true,
                                        detectOnce: isDetectOnce,
                                        enableImageInteractions:
                                            enableImageInteractions,
                                        imagePath: pickedFile?.path ?? '',
                                        onDetectText: (v) {
                                          setState(() {
                                            if (v is String) {
                                              detectedValue = v;
                                            }
                                            if (v is List) {
                                              int counter = 0;
                                              for (var element in v) {
                                                detectedValue +=
                                                    "$counter. \t\t $element \n\n";
                                                counter++;
                                              }
                                            }
                                          });
                                        },
                                        onDetectError: (error) {
                                          // print(error);

                                          ///This error will occurred in Android only while user will try to crop image at max zoom level then ml kit will throw max 32 height/width exception
                                          if (error is PlatformException &&
                                              (error.message?.contains(
                                                      "InputImage width and height should be at least 32!") ??
                                                  false)) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Selected area should be able to crop image with at least 32 width and height.")));
                                          }
                                        },
                                      )));
                            },
                            child: const Center(
                                child: Text(
                              "Pick Image And Detect Text",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )),
                          )),
                      const SizedBox(height: 20),
                      RippleButton(
                          bgColor: Colors.blueAccent,
                          shadowOffset: Offset.zero,
                          shadowBlurRadius: 2,
                          shadowSpreadRadius: 0,
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                detectedValue = cameraDetectedValue = "";
                              });
                              var values = await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => Stack(
                                            children: [
                                              LiveTextRecognizerView(
                                                  initialRecognitionScript:
                                                      initialRecognitionScript,
                                                  showLangScriptDropDown: true),
                                            ],
                                          )));

                              // cameraDetectedValue = (await Clipboard.getData(Clipboard.kTextPlain))
                              //             ?.text ??
                              //         '';
                              setState(() {
                                if (values is List) {
                                  int counter = 0;
                                  for (var element in values) {
                                    cameraDetectedValue +=
                                        "$counter. \t\t ${(element as DetectedTextInfo).text} \n\n";
                                    counter++;
                                  }
                                }
                                // print("cameraDetectedValue $cameraDetectedValue");
                              });
                            },
                            child: const Center(
                                child: Text(
                              "Live Text Detect Camera",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                  '${isDetectOnce || cameraDetectedValue.isEmpty ? "Single" : "Multiple"} Detected values :',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Flexible(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                        child: Text(
                            detectedValue.isEmpty && cameraDetectedValue.isEmpty
                                ? "Please pick Image and Detect Text From Particular Image Area Or Detect From Live Camera And Select/Copy over detected texts"
                                : cameraDetectedValue.isNotEmpty
                                    ? cameraDetectedValue
                                    : detectedValue,
                            style: Theme.of(context).textTheme.bodyMedium)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
