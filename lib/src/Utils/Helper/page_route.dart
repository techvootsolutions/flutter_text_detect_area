import 'package:flutter/material.dart';

Route createFadeRoute(Widget widget, {int duration = 500}) {
  return PageRouteBuilder(
    pageBuilder: (_, a1, a2) => FadeTransition(opacity: a1, child: widget),
    transitionDuration: Duration(milliseconds: duration),
  );
}

Route createRoute(Widget widget, {int duration = 0}) {
  return PageRouteBuilder(
    pageBuilder: (_, a1, a2) => widget,
    transitionDuration: Duration(milliseconds: duration),
  );
}

pushReplacement(BuildContext context, Widget destination,
    {bool isAnimate = false}) {
  Navigator.of(context).pushReplacement(isAnimate
      ? createRoute(destination)
      : MaterialPageRoute(builder: (context) => destination));
}

push(BuildContext context, Widget destination, {bool isAnimate = false}) {
  Navigator.of(context).push(isAnimate
      ? createRoute(destination)
      : MaterialPageRoute(builder: (context) => destination));
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict,
    {bool isAnimate = false}) {
  Navigator.of(context).pushAndRemoveUntil(
      isAnimate
          ? createRoute(destination)
          : MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => predict);
}
