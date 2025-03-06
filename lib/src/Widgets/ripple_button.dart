import 'package:flutter/material.dart';

///RippleButton
class RippleButton extends StatelessWidget {
  const RippleButton(
      {super.key,
      this.height,
      this.margin,
      this.padding,
      this.isDisable,
      required this.child,
      this.bgColor,
      this.shadowColor,
      this.borderColor,
      this.borderWidth,
      this.buttonWidth,
      this.shadowBlurRadius,
      this.shadowSpreadRadius,
      this.shadowOffset,
      this.onTap});

  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? borderWidth;
  final VoidCallback? onTap;
  final double? buttonWidth;
  final double? shadowBlurRadius;
  final double? shadowSpreadRadius;
  final Offset? shadowOffset;
  final Widget? child;
  final bool? isDisable;
  final Color? bgColor;
  final Color? shadowColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50,
      width: buttonWidth ?? double.infinity,
      margin: margin,
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: shadowColor ?? Colors.black.withValues(alpha: 0.25),
                  blurRadius: shadowBlurRadius ?? 10,
                  spreadRadius: shadowSpreadRadius ?? 0,
                  offset: shadowOffset ?? const Offset(0, 5))
            ],
            borderRadius: BorderRadius.circular(10),
            color: bgColor,
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 0,
            )),
        child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: isDisable == true ? null : onTap,
              radius: 10,
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
