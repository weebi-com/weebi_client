// Flutter imports:
import 'package:flutter/material.dart';

/// Widget for displaying a permission with checkbox
class PermissionWidget extends StatelessWidget {
  final Icon icon;
  final Icon permissionIcon;
  final Text permissionName;
  final bool hasPermission;
  
  const PermissionWidget({
    super.key,
    required this.icon,
    required this.permissionIcon,
    required this.permissionName,
    required this.hasPermission,
  });

  @override
  Widget build(BuildContext context) {
    const paddingVerticalLine = EdgeInsets.symmetric(vertical: 4.0);
    
    return Padding(
      padding: paddingVerticalLine,
      child: Row(
        children: <Widget>[
          Flexible(flex: 1, fit: FlexFit.tight, child: icon),
          Flexible(flex: 1, fit: FlexFit.tight, child: permissionIcon),
          const SizedBox(width: 20),
          Flexible(flex: 4, fit: FlexFit.tight, child: permissionName),
          Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Checkbox(
                value: hasPermission,
                onChanged: null,
              )),
        ],
      ),
    );
  }
} 