// Flutter imports:
import 'package:design_weebi/design_weebi.dart' show ColorsWeebi, TextStyleWeebi;
import 'package:flutter/material.dart';

// Project imports:

class ColumnHeader extends StatelessWidget {
  final String title;
  const ColumnHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsWeebi.expTablePrimaryColor,
      margin: EdgeInsets.all(1),
      child: Center(
        child: Text(
          title,
          style: TextStyleWeebi.white,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}
