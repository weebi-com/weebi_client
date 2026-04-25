import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';
import 'package:models_weebi/models.dart' show TicketType;
import 'package:protobuf/protobuf.dart' show ProtobufEnum;
import 'package:protos_weebi/protos_weebi_io.dart'
    show
        GeneratedMessage,
        PbList,
        Timestamp,
        Counterfoil,
        TaxPb,
        ItemCartPb;

/// Dynamic display for Ticket protobuf and related types.
/// Extends the pattern used in boutiques/users dynamic_body.
class TicketDynamicBody<T extends GeneratedMessage> extends StatelessWidget {
  final T pbObject;
  final List<String> skipFieldNames;

  const TicketDynamicBody({
    super.key,
    required this.pbObject,
    this.skipFieldNames = const [],
  });

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[];

    for (int index = 0; index < pbObject.info_.fieldInfo.length; index++) {
      final fieldInfo = pbObject.info_.fieldInfo[index];
      final fieldName = fieldInfo?.name ?? '';
      final fieldValue =
          fieldInfo == null ? null : pbObject.getField(fieldInfo.tagNumber);

      if (_shouldSkipField(fieldName, fieldValue, skipFieldNames)) {
        continue;
      }

      fields.add(_TicketProtobufFieldWidget(
        fieldName: fieldName,
        fieldValue: fieldValue,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }
}

class _TicketProtobufFieldWidget extends StatelessWidget {
  final String fieldName;
  final dynamic fieldValue;

  const _TicketProtobufFieldWidget({
    required this.fieldName,
    required this.fieldValue,
  });

  @override
  Widget build(BuildContext context) {
    return _buildTicketField(fieldName, fieldValue);
  }
}

String _formatFieldName(String fieldName) {
  return fieldName
      .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
}

bool _shouldSkipField(
    String fieldName, dynamic fieldValue, List<String> skipFieldNames) {
  if (fieldValue == null) return true;

  final technicalFields = ['info_', 'unknownFields'];
  if (technicalFields.contains(fieldName)) return true;
  if (skipFieldNames.contains(fieldName)) return true;

  return false;
}


Widget _buildTicketField(String fieldName, dynamic fieldValue) {
  if (fieldValue == null) return const SizedBox.shrink();

  switch (fieldValue.runtimeType) {
    case const (String):
      if (fieldValue.isEmpty) return const SizedBox.shrink();
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue),
      );

    case const (int) || const (double):
      return ListTile(
        leading: const Icon(Icons.numbers),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue.toString()),
      );

    case const (bool):
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(_formatFieldName(fieldName)),
        trailing: Icon(
          fieldValue ? Icons.check_circle : Icons.cancel,
          color: fieldValue ? Colors.green : Colors.red,
        ),
      );

    case const (Timestamp):
      final dateTime = fieldValue.toDateTime();
      return ListTile(
        leading: const Icon(Icons.schedule),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        ),
      );

    case const (Counterfoil):
      final cf = fieldValue as Counterfoil;
      return ExpansionTile(
        leading: const Icon(Icons.business),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(
          [cf.firmName, cf.boutiqueName, cf.userName]
              .where((s) => s.isNotEmpty)
              .join(' • '),
        ),
        children: [
          if (cf.firmId.isNotEmpty)
            ListTile(
              title: const Text('Firm ID'),
              subtitle: SelectableText(cf.firmId),
            ),
          if (cf.chainId.isNotEmpty)
            ListTile(
              title: const Text('Chain ID'),
              subtitle: SelectableText(cf.chainId),
            ),
          if (cf.boutiqueId.isNotEmpty)
            ListTile(
              title: const Text('Boutique ID'),
              subtitle: SelectableText(cf.boutiqueId),
            ),
          if (cf.userId.isNotEmpty)
            ListTile(
              title: const Text('User ID'),
              subtitle: SelectableText(cf.userId),
            ),
        ],
      );

    case const (TaxPb):
      final tax = fieldValue as TaxPb;
      return ExpansionTile(
        leading: const Icon(Icons.percent),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text('${tax.name} (${tax.percentage}%)'),
        children: [
          ListTile(title: const Text('Name'), subtitle: Text(tax.name)),
          ListTile(
              title: const Text('Percentage'),
              subtitle: Text(tax.percentage.toString())),
        ],
      );

    case const (ItemCartPb):
      final item = fieldValue as ItemCartPb;
      return ExpansionTile(
        leading: const Icon(Icons.shopping_basket),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text('Qty: ${item.quantity}'),
        children: [
          ListTile(
              title: const Text('Quantity'),
              subtitle: Text(item.quantity.toString())),
          if (item.hasArticleRetail())
            ListTile(
                title: const Text('Article'),
                subtitle: Text(item.articleRetail.toString())),
          if (item.hasArticleBasket())
            ListTile(
                title: const Text('Basket'),
                subtitle: Text(item.articleBasket.toString())),
        ],
      );

    case const (PbList):
      final list = fieldValue as PbList;
      if (list.isEmpty) return const SizedBox.shrink();

      return ExpansionTile(
        leading: const Icon(Icons.list),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text('${list.length} items'),
        children: list.asMap().entries.map<Widget>((entry) {
          final item = entry.value;
          if (item is ItemCartPb) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ListTile(
                leading: const Icon(Icons.shopping_basket, size: 20),
                title: Text('Item ${entry.key + 1}'),
                subtitle: Text('Qty: ${item.quantity}'),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ListTile(
              title: Text('Item ${entry.key + 1}'),
              subtitle: Text(item.toString()),
            ),
          );
        }).toList(),
      );

    default:
      if (fieldValue is ProtobufEnum) {
        final ticketType = TicketType.tryParse(fieldValue.name);
        return ListTile(
          leading: Icon(
            ticketType.iconData,
            color: ticketType.iconColor,
          ),
          title: Text(_formatFieldName(fieldName)),
          subtitle: Text(fieldValue.name),
        );
      }
      if (fieldValue.toString().isEmpty || fieldValue.toString() == '[]') {
        return const SizedBox.shrink();
      }
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue.toString()),
      );
  }
}
