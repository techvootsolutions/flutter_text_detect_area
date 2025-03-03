import 'package:flutter/material.dart';
import 'package:flutter_text_detect_area/flutter_text_detect_area.dart';

class CustomScriptDropdown extends StatefulWidget {
  const CustomScriptDropdown({super.key, this.onChanged, this.selectedScript});

  final TextRecognitionScript? selectedScript;
  final Function(TextRecognitionScript?)? onChanged;

  @override
  CustomScriptDropdownState createState() => CustomScriptDropdownState();
}

class CustomScriptDropdownState extends State<CustomScriptDropdown> {
  TextRecognitionScript? selectedScript;
  @override
  void initState() {
    selectedScript = widget.selectedScript;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: 150,
      width: 600,
      padding: EdgeInsets.only(top: 40,left: size.width * 0.3, right: size.width * 0.3),
      child: DropdownButtonFormField<TextRecognitionScript>(
        value: selectedScript,
        // icon: Icon(Icons.arrow_downward),
        iconEnabledColor: Colors.black,
        iconDisabledColor: Colors.black,
        iconSize: 24,
        elevation: 16,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          // labelText: 'Select Your Script',
          // labelStyle: TextStyle(color: Colors.black),
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: widget.onChanged ??
            (TextRecognitionScript? newValue) {
              setState(() {
                selectedScript = newValue;
                // Additional actions when the value changes
              });
            },
        items: TextRecognitionScript.values
            .map<DropdownMenuItem<TextRecognitionScript>>(
                (TextRecognitionScript script) {
          return DropdownMenuItem<TextRecognitionScript>(
            value: script,
            child: Text(script.name),
          );
        }).toList(),
      ),
    );
  }
}
