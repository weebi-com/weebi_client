import 'package:models_weebi/models.dart' show TicketWeebi;
import 'package:protos_weebi/protos_weebi_io.dart' show ItemCartPb, TicketPb;

/// Converts [TicketPb] to [TicketWeebi] for use with models_weebi extensions.
/// Uses the proto-compatible map format expected by TicketWeebi.fromMap(isProto: true).
TicketWeebi ticketPbToWeebi(TicketPb pb) {
  final items = pb.items.map((item) => _itemToMap(item)).toList();

  final map = <String, dynamic>{
    'id': pb.nonUniqueId,
    'date': pb.date.isNotEmpty ? pb.date : pb.creationDate,
    'creationDate': pb.creationDate,
    'statusUpdateDate': pb.statusUpdateDate,
    'status': pb.status,
    'items': items,
    'ticketType': pb.ticketType.name,
    'paymentType': pb.paymentType.name,
    'contactId': pb.contactId,
    'taxe': {
      'id': pb.taxe.id,
      'name': pb.taxe.name,
      'percentage': pb.taxe.percentage,
    },
    'promo': pb.promo,
    'received': pb.received,
    'discountAmount': pb.discountAmount,
    'comment': pb.comment,
    'contactFirstName': pb.contactFirstName,
    'contactLastName': pb.contactLastName,
    'contactPhone': pb.contactPhone,
    'contactMail': pb.contactMail,
  };

  return TicketWeebi.fromMap(map, isProto: true);
}

Map<String, dynamic> _itemToMap(ItemCartPb item) {
  final result = <String, dynamic>{
    'quantity': item.quantity,
  };
  if (item.inventoryAbsoluteQt != 0) {
    result['inventoryAbsoluteQt'] = item.inventoryAbsoluteQt;
  }

  if (item.hasArticleRetail()) {
    final a = item.articleRetail;
    result['articleRetail'] = {
      'calibreId': a.calibreId,
      'id': a.id,
      'designation': a.designation,
      'price': a.price,
      'cost': a.cost,
      'unitsInOnePiece': a.unitsInOnePiece,
    };
    return result;
  }
  if (item.hasArticleUncountable()) {
    final a = item.articleUncountable;
    result['articleUncountable'] = {
      'calibreId': a.calibreId,
      'id': a.id,
      'designation': a.designation,
      'price': a.price,
      'cost': a.cost,
    };
    return result;
  }
  if (item.hasArticleBasket()) {
    final a = item.articleBasket;
    result['articleBasket'] = {
      'calibreId': a.calibreId,
      'id': a.id,
      'designation': a.designation,
      'proxies': a.proxies.map((p) => {
            'calibreId': p.calibreId,
            'articleId': p.articleId,
            'id': p.id,
            'status': p.status,
            'proxyCalibreId': p.proxyCalibreId,
            'proxyArticleId': p.proxyArticleId,
            'minimumUnitPerBasket': p.minimumUnitPerBasket,
            'articleWeight': p.articleWeight,
          }).toList(),
      'discountAmount': a.discountAmount,
      'markupAmount': a.markupAmount,
    };
    return result;
  }
  // Fallback: empty uncountable for malformed items
  result['articleUncountable'] = {
    'calibreId': 0,
    'id': 0,
    'designation': '',
    'price': 0.0,
    'cost': 0.0,
  };
  return result;
}
