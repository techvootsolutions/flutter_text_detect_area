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
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
      ),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF2A2D3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                const Text(
                  "Flutter Text Detect Area",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Detection Mode",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 10),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(10),
                        isSelected: [isDetectOnce, !isDetectOnce],
                        selectedColor: Colors.white,
                        fillColor: Colors.blueAccent,
                        color: Colors.grey,
                        borderColor: Colors.grey,
                        borderWidth: 0.5,
                        selectedBorderColor: Colors.blueAccent,
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        dense: true,
                        onTap: () {
                          setState(() {
                            enableImageInteractions = !enableImageInteractions;
                          });
                        },
                        title: Text(
                            "${enableImageInteractions ? "Disable" : "Enable"} User Interactions Over Image",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey)),
                        trailing: Switch(
                          activeTrackColor: Colors.blueAccent,
                          value: enableImageInteractions,
                          onChanged: (v) {
                            setState(() {
                              enableImageInteractions = v;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildButton("Pick Image And Detect Text", () async {
                  setState(() {
                    detectedValue = cameraDetectedValue = "";
                  });
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (!context.mounted) return;
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SelectImageAreaTextDetect(
                      showLangScriptDropDown: true,
                      detectOnce: isDetectOnce,
                      enableImageInteractions: enableImageInteractions,
                      imagePath: pickedFile?.path ?? '',
                      onDetectText: (v) {
                        setState(() {
                          if (v is String) {
                            detectedValue = v;
                          }
                          if (v is List) {
                            int counter = 0;
                            for (var element in v) {
                              detectedValue += "$counter. \t\t $element \n\n";
                              counter++;
                            }
                          }
                        });
                      },
                      onDetectError: (error) {
                        if (error is PlatformException &&
                            (error.message?.contains(
                                    "InputImage width and height should be at least 32!") ??
                                false)) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                "Selected area should be at least 32x32 pixels."),
                          ));
                        }
                      },
                    ),
                  ));
                }),
                const SizedBox(height: 15),
                _buildButton("Live Text Detect Camera", () async {
                  setState(() {
                    detectedValue = cameraDetectedValue = "";
                  });
                  var values =
                      await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Stack(
                      children: [
                        LiveTextRecognizerView(
                            initialRecognitionScript: initialRecognitionScript,
                            showLangScriptDropDown: true),
                      ],
                    ),
                  ));
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
                }),
                const SizedBox(height: 20),
                Text(
                    '${cameraDetectedValue.isNotEmpty || !isDetectOnce ? "Multiple" : "Single"} Detected Text :',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white)),
                const SizedBox(height: 10),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    color: Colors.white.withOpacity(0.1),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Text(
                            detectedValue.isNotEmpty ||
                                    cameraDetectedValue.isNotEmpty
                                ? (cameraDetectedValue.isNotEmpty
                                    ? cameraDetectedValue
                                    : detectedValue)
                                : "Please pick an image and detect text or use Live Camera",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
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
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white.withOpacity(0.1),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, // Makes the button take full width
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
