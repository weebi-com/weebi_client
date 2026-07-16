import 'package:design_weebi/src/ticket_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:models_weebi/models.dart';

extension PaiementTypeIcon on PaymentType {
  Icon get paymentTypeIcon {
    if (this == PaymentType.cash) {
      return Icon(FontAwesomeIcons.moneyBill1Wave.data, size: 18);
    } else if (this == PaymentType.mobileMoney) {
      return Icon(Icons.phone_android);
    } else if (this == PaymentType.goods) {
      return Icon(Icons.widgets);
    } else if (this == PaymentType.cheque) {
      return Icon(Icons.note);
    } else if (this == PaymentType.creditCard) {
      return Icon(Icons.payment);
    } else if (this == PaymentType.nope) {
      return Icon(Icons.record_voice_over);
    } else {
      return Icon(Icons.device_unknown);
    }
  }
}

extension TicketPaiementTypeIcon on TicketWeebi {
  Icon get paymentTypeColoredIcon {
    final color = ticketType.iconColor;
    if (paymentType == PaymentType.cash) {
      return Icon(FontAwesomeIcons.moneyBill1Wave.data, size: 18, color: color);
    } else if (paymentType == PaymentType.mobileMoney) {
      return Icon(Icons.phone_android, color: color);
    } else if (paymentType == PaymentType.goods) {
      return Icon(Icons.local_shipping, color: color);
    } else if (paymentType == PaymentType.cheque) {
      return Icon(Icons.note, color: color);
    } else if (paymentType == PaymentType.creditCard) {
      return Icon(Icons.payment, color: color);
    } else if (paymentType == PaymentType.nope) {
      return Icon(Icons.record_voice_over, color: color);
    } else {
      return Icon(Icons.device_unknown, color: color);
    }
  }
}
