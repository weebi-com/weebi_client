import 'package:flutter/material.dart'
    show Colors, FontWeight, TextDecoration, TextStyle;

import 'colors.dart';

class TextStyleWeebi {
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  static const cartRecap = TextStyle(fontSize: 18);
  static const white = TextStyle(color: Colors.white);
  static const whiteBold =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  static const greyLight = TextStyle(color: ColorsWeebi.greyLight);
  static const grey = TextStyle(color: Colors.grey);
  static const blackAndBold =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

  static const blackBoldBig = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    color: Colors.black,
  );
  static const supportBig =
      TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold);

  static const whiteBoldBig = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    color: Colors.white,
  );

  static const whiteBoldBigQuicksand = TextStyle(
    fontFamily: 'Quicksand',
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    color: Colors.white,
  );

  static const supportBlack = TextStyle(fontSize: 16.0, color: Colors.black);

  static const supportSmall = TextStyle(fontSize: 14.0);

  static const supportSmallUnderline =
      TextStyle(fontSize: 14.0, decoration: TextDecoration.underline);

  static const chartLeftLegend = TextStyle(
    color: ColorsWeebi.greyChart,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const chartBottomLegend = TextStyle(
    color: ColorsWeebi.greyChart,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );
}
