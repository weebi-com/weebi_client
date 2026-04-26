// Flutter imports:
import 'package:design_weebi/design_weebi.dart' show TextStyleWeebi;
import 'package:flutter/material.dart';

// Project imports:

class TitleChartWidget extends StatelessWidget {
  final String title;
  const TitleChartWidget(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyleWeebi.blackBoldBig,
      ),
    );
  }
}
