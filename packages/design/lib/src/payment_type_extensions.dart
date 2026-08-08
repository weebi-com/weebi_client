import 'package:design_weebi/src/ticket_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:models_weebi/models.dart';

extension PaiementTypeIcon on PaymentType {
  Widget get paymentTypeIcon {
    if (this == PaymentType.cash) {
      return const Icon(Icons.payments, size: 18);
    } else if (this == PaymentType.mobileMoney) {
      return const Icon(Icons.phone_android);
    } else if (this == PaymentType.goods) {
      return const Icon(Icons.widgets);
    } else if (this == PaymentType.cheque) {
      return const Icon(Icons.note);
    } else if (this == PaymentType.creditCard) {
      return const Icon(Icons.payment);
    } else if (this == PaymentType.nope) {
      return const Icon(Icons.record_voice_over);
    } else {
      return const Icon(Icons.device_unknown);
    }
  }
}

extension TicketPaiementTypeIcon on TicketWeebi {
  Widget get paymentTypeColoredIcon {
    final color = ticketType.iconColor;
    if (paymentType == PaymentType.cash) {
      return Icon(Icons.payments, size: 18, color: color);
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
