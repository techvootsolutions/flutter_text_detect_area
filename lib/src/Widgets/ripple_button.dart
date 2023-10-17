import 'package:flutter/material.dart';

///RippleButton
class RippleButton extends StatelessWidget {
  RippleButton({
    super.key,
    this.height,
    this.top,
    required this.child,
    this.bgColor,
    this.borderColor,
    this.borderWidth,
    this.buttonWidth,
    this.onTap
  });

  double? height = 50;
  double? top = 0;
  double? borderWidth = 0;
  VoidCallback? onTap;
  double? buttonWidth = double.infinity;
  Widget? child;
  Color? bgColor = Colors.white;
  Color? borderColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
      return Container(
        height: height ?? 50,
        width: buttonWidth ?? double.infinity,
        margin: EdgeInsets.only(top: top ?? 0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bgColor,
              border: Border.all(
                color: borderColor ?? Colors.transparent,
                width: borderWidth ?? 0,
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
}
