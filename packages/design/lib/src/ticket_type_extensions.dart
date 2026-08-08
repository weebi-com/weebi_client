import 'package:flutter/material.dart';
import 'package:models_weebi/models.dart' show TicketType;

import 'colors.dart';

/// Extension on [TicketType] for icons and colors.
extension GetTicketTypeIcon on TicketType {
  Widget get icon {
    if (this == TicketType.sell) {
      return Icon(Icons.point_of_sale, color: iconColor, size: 20);
    } else if (this == TicketType.sellDeferred) {
      return Icon(Icons.record_voice_over, color: iconColor);
    } else if (this == TicketType.sellCovered) {
      return Icon(Icons.playlist_add, color: iconColor);
    } else if (this == TicketType.spend) {
      return Icon(Icons.shopping_cart, color: iconColor);
    } else if (this == TicketType.spendDeferred) {
      return Icon(Icons.record_voice_over, color: iconColor);
    } else if (this == TicketType.spendCovered) {
      return Icon(Icons.playlist_add, color: iconColor);
    } else if (this == TicketType.stockIn) {
      return Icon(Icons.layers, color: iconColor);
    } else if (this == TicketType.stockOut) {
      return Icon(Icons.layers, color: iconColor);
    } else if (this == TicketType.inventory) {
      return Icon(Icons.inventory_rounded, color: iconColor);
/*     } else if (this == TicketType.rebalance) {
      return Icon(Icons.swap_horiz, color: iconColor);
    } else if (this == TicketType.inventoryClosingValue) {
      return Icon(Icons.warehouse_outlined, color: iconColor); */
    } else {
      return const Icon(Icons.device_unknown);
    }
  }

  IconData get iconData {
    if (this == TicketType.sell) {
      return Icons.shopping_basket;
    } else if (this == TicketType.sellDeferred) {
      return Icons.record_voice_over;
    } else if (this == TicketType.sellCovered) {
      return Icons.playlist_add;
    } else if (this == TicketType.spend) {
      return Icons.shopping_cart;
    } else if (this == TicketType.spendDeferred) {
      return Icons.record_voice_over;
    } else if (this == TicketType.spendCovered) {
      return Icons.playlist_add;
    } else if (this == TicketType.stockIn) {
      return Icons.layers;
    } else if (this == TicketType.stockOut) {
      return Icons.layers;
    } else if (this == TicketType.inventory) {
      return Icons.inventory_rounded;
/*     } else if (this == TicketType.rebalance) {
      return Icons.swap_horiz;
    } else if (this == TicketType.inventoryClosingValue) {
      return Icons.warehouse_outlined; */
    } else {
      return Icons.device_unknown;
    }
  }

  Color get iconColor {
    if (this == TicketType.sell) {
      return ColorsWeebi.tealSell;
    } else if (this == TicketType.sellDeferred) {
      return ColorsWeebi.tealSell;
    } else if (this == TicketType.sellCovered) {
      return ColorsWeebi.blueSellCovered;
    } else if (this == TicketType.spend) {
      return ColorsWeebi.redSpend;
    } else if (this == TicketType.spendDeferred) {
      return ColorsWeebi.redSpend;
    } else if (this == TicketType.spendCovered) {
      return ColorsWeebi.orangeSpendCover;
    } else if (this == TicketType.stockIn) {
      return ColorsWeebi.pinkStockEntry;
    } else if (this == TicketType.stockOut) {
      return ColorsWeebi.pinkStockExit;
    } else if (this == TicketType.inventory) {
      return ColorsWeebi.blueInventory;
/*     } else if (this == TicketType.rebalance) {
      return ColorsWeebi.ohadaBlue;
    } else if (this == TicketType.inventoryClosingValue) {
      return ColorsWeebi.blueInventory; */
    } else {
      return Colors.grey;
    }
  }

  Widget get getTicketContactIcon {
    if (this == TicketType.sell ||
        this == TicketType.sellDeferred ||
        this == TicketType.sellCovered) {
      return Icon(Icons.face, color: iconColor);
    } else if (this == TicketType.spend ||
        this == TicketType.spendDeferred ||
        this == TicketType.spendCovered) {
      return Icon(Icons.face_retouching_off, color: iconColor);
    } else {
      return const Icon(Icons.device_unknown);
    }
  }
}
