import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

extension TicketTypePbUI on TicketTypePb {
  Icon get icon {
    switch (this) {
      case TicketTypePb.sell:
        return Icon(FontAwesomeIcons.cashRegister,
            color: iconColor, size: 20);
      case TicketTypePb.sellDeferred:
        return Icon(Icons.record_voice_over, color: iconColor);
      case TicketTypePb.sellCovered:
        return Icon(Icons.playlist_add, color: iconColor);
      case TicketTypePb.spend:
        return Icon(Icons.shopping_cart, color: iconColor);
      case TicketTypePb.spendDeferred:
        return Icon(Icons.record_voice_over, color: iconColor);
      case TicketTypePb.spendCovered:
        return Icon(Icons.playlist_add, color: iconColor);
      case TicketTypePb.stockIn:
      case TicketTypePb.stockOut:
        return Icon(Icons.layers, color: iconColor);
      case TicketTypePb.wage:
        return Icon(Icons.attach_money, color: iconColor);
      case TicketTypePb.inventory:
        return Icon(Icons.inventory_rounded, color: iconColor);
      default:
        return const Icon(Icons.device_unknown);
    }
  }

  IconData get iconData {
    switch (this) {
      case TicketTypePb.sell:
        return FontAwesomeIcons.cashRegister;
      case TicketTypePb.sellDeferred:
        return Icons.record_voice_over;
      case TicketTypePb.sellCovered:
        return Icons.playlist_add;
      case TicketTypePb.spend:
        return Icons.shopping_cart;
      case TicketTypePb.spendDeferred:
        return Icons.record_voice_over;
      case TicketTypePb.spendCovered:
        return Icons.playlist_add;
      case TicketTypePb.stockIn:
      case TicketTypePb.stockOut:
        return Icons.layers;
      case TicketTypePb.wage:
        return Icons.attach_money;
      case TicketTypePb.inventory:
        return Icons.inventory_rounded;
      default:
        return Icons.device_unknown;
    }
  }

  Color get iconColor {
    switch (this) {
      case TicketTypePb.sell:
      case TicketTypePb.sellDeferred:
        return ColorsWeebi.tealSell;
      case TicketTypePb.sellCovered:
        return ColorsWeebi.blueSellCovered;
      case TicketTypePb.spend:
      case TicketTypePb.spendDeferred:
        return ColorsWeebi.redSpend;
      case TicketTypePb.spendCovered:
        return ColorsWeebi.orangeSpendCover;
      case TicketTypePb.stockIn:
        return ColorsWeebi.pinkStockEntry;
      case TicketTypePb.stockOut:
        return ColorsWeebi.pinkStockExit;
      case TicketTypePb.wage:
        return Colors.red;
      case TicketTypePb.inventory:
        return ColorsWeebi.blueInventory;
      default:
        return Colors.grey;
    }
  }

  Icon get getTicketContactIcon {
    switch (this) {
      case TicketTypePb.sell:
      case TicketTypePb.sellDeferred:
      case TicketTypePb.sellCovered:
        return Icon(FontAwesomeIcons.faceSmile);
      case TicketTypePb.spend:
      case TicketTypePb.spendDeferred:
      case TicketTypePb.spendCovered:
        return Icon(FontAwesomeIcons.faceGrimace);
      default:
        return const Icon(Icons.device_unknown);
    }
  }
}
