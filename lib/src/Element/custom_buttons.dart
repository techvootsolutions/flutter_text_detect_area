import 'package:flutter/material.dart';

///CustomButton
Widget CustomButton({double top = 0,double height=50, Color bgColor = Colors.white, Color borderColor=Colors.transparent,
  double borderWidth=0, double buttonWidth=double.infinity,Function()? onTap,Widget? child}) {
  return Container(
    height: height,
    width: buttonWidth,
    margin: EdgeInsets.only(top: top),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          )),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: child,
          )),
    ),
  );
  // return Container(
  //   height: 50,
  //   width: buttonWidth,
  //   padding: EdgeInsets.only(left: 10, right: 10, top: top),
  //   child: Material(
  //     borderRadius: BorderRadius.circular(10),
  //     color: Colors.transparent,
  //     child: Container(
  //         height: 50,
  //         width: buttonWidth,
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(10),
  //             color: bgColor,
  //             border: Border.all(
  //               color: borderColor,
  //               width: width,
  //             )),
  //         child: Center(child: child,)),
  //   ),
  // );
}

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