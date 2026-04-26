
import 'dart:ui' show Color;

import 'package:flutter/material.dart' show Colors;
import 'package:models_weebi/models.dart' show TicketWeebi;

extension TicketIconColor on TicketWeebi {
  Color get iconColor => status ? Colors.black : Colors.grey;
}
