import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_detect_by_area/flutter_text_detect_by_area.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Text Detect By Area'),
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
  bool isDetectOnce = true;
  bool enableImageInteractions = true;

  @override
  Widget build(BuildContext context) {
    void setDetectOnce(_isDetectOnce) {
      setState(() {
        detectedValue = "";
        isDetectOnce = _isDetectOnce;
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  title: const Text('Detect Once'),
                  leading: Radio(
                      value: true,
                      groupValue: isDetectOnce,
                      onChanged: setDetectOnce),
                ),
                ListTile(
                    title: const Text('Detect More'),
                    leading: Radio(
                        value: false,
                        groupValue: isDetectOnce,
                        onChanged: setDetectOnce)
                ),
                ListTile(
                    title: Text("${enableImageInteractions?"Disable":"Enable"} User Interactions Over Image"),
                    leading: Switch(
                        value: enableImageInteractions,
                        onChanged: (v){
                          setState(() {
                            enableImageInteractions = v;
                          });
                        })
                ),
                RippleButton(
                    margin: const EdgeInsets.all(20),
                    bgColor: Colors.lightBlue,
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          detectedValue = "";
                        });
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SelectImageAreaTextDetect(
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
                      },
                      child: const Center(
                          child: Text("Pick Image And Detect Text", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),)
                      ),
                    )),
                const SizedBox(height: 20),
                Text('${isDetectOnce ? "Single" : "Multiple"} Detected values :', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                Flexible(
                    child: SingleChildScrollView(
                        child: Text(detectedValue.isEmpty
                                ? "Please pick Image and Detect Text From Particular Image Area."
                                : detectedValue,
                            style: Theme.of(context).textTheme.bodyMedium)))
              ],
            ),
          ),
        ));
  }
}
