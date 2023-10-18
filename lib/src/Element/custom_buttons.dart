import 'package:flutter/material.dart';


///CustomIconButton
Widget customIconButton({Widget? icon,VoidCallback? onTap,double buttonWidth=40}){
  return Container(
    height: 50,
    width: buttonWidth,
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20)),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: icon,
          )),
    ),
  );
}