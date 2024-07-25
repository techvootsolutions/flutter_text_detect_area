import 'package:flutter/material.dart';
import 'package:flutter_text_detect_area/flutter_text_detect_area.dart';

class CustomScriptDropdown extends StatefulWidget {
  CustomScriptDropdown({super.key, this.onChanged, this.selectedScript});

  TextRecognitionScript? selectedScript;
  Function(TextRecognitionScript?)? onChanged;

  @override
  _CustomScriptDropdownState createState() => _CustomScriptDropdownState();
}

class _CustomScriptDropdownState extends State<CustomScriptDropdown> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: 150,
      width: 600,
      padding: EdgeInsets.only(top: 40,left: size.width * 0.3, right: size.width * 0.3),
      child: DropdownButtonFormField<TextRecognitionScript>(
        value: widget.selectedScript,
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
                widget.selectedScript = newValue;
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
