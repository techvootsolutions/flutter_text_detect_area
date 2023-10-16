import 'package:flutter/material.dart';

///Padding Top
Widget paddingTop(double top) {
  return Padding(
    padding: EdgeInsets.only(top: top),
  );
}

///Padding Left
Widget paddingLeft(double left) {
  return Padding(
    padding: EdgeInsets.only(left: left),
  );
}

///Padding Right
Widget paddingRight(double right) {
  return Padding(
    padding: EdgeInsets.only(right: right),
  );
}

///Padding Bottom
Widget paddingBottom(double bottom) {
  return Padding(
    padding: EdgeInsets.only(bottom: bottom),
  );
}

///Padding set All Side Different
Widget paddingAllDifferent(double top,double right, double bottom, double left) {
  return Padding(
      padding: EdgeInsets.only(top: top, right: right, bottom: bottom, left: left)
  );
}

///Padding All
Widget paddingAll(double all) {
  return Padding(
    padding: EdgeInsets.all(all),
  );
}
