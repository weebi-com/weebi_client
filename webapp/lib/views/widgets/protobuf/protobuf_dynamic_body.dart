import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Walks [GeneratedMessage.info_.fieldInfo] and renders fields by type so
/// new proto fields appear without a dedicated widget.
class ProtobufDynamicBody<T extends GeneratedMessage> extends StatelessWidget {
  const ProtobufDynamicBody({
    super.key,
    required this.pbObject,
    this.skipFieldNames = const [],
    this.leadingFieldNames = const [],
    this.trailingFieldNames = const [],
  });

  final T pbObject;
  final List<String> skipFieldNames;

  /// Rendered first, in this order, when present (e.g. id, title, price).
  final List<String> leadingFieldNames;

  /// Rendered last, in this order (e.g. creationDate, status).
  final List<String> trailingFieldNames;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[];
    for (final fieldInfo in orderedProtoFields(
      pbObject,
      leadingFieldNames: leadingFieldNames,
      trailingFieldNames: trailingFieldNames,
    )) {
      final fieldName = fieldInfo.name;
      final fieldValue = pbObject.getField(fieldInfo.tagNumber);
      if (_shouldSkipField(fieldName, fieldValue, skipFieldNames)) {
        continue;
      }
      fields.add(ProtobufFieldWidget(
        fieldName: fieldName,
        fieldValue: fieldValue,
        skipFieldNames: skipFieldNames,
        leadingFieldNames: leadingFieldNames,
        trailingFieldNames: trailingFieldNames,
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }
}

class ProtobufFieldWidget extends StatelessWidget {
  const ProtobufFieldWidget({
    super.key,
    required this.fieldName,
    required this.fieldValue,
    this.skipFieldNames = const [],
    this.leadingFieldNames = const [],
    this.trailingFieldNames = const [],
  });

  final String fieldName;
  final dynamic fieldValue;
  final List<String> skipFieldNames;
  final List<String> leadingFieldNames;
  final List<String> trailingFieldNames;

  @override
  Widget build(BuildContext context) {
    return _buildField(
      context,
      fieldName,
      fieldValue,
      skipFieldNames,
      leadingFieldNames,
      trailingFieldNames,
    );
  }
}

/// Proto declaration order, with optional business-first / technical-last.
List<({String name, int tagNumber})> orderedProtoFields(
  GeneratedMessage pbObject, {
  List<String> leadingFieldNames = const [],
  List<String> trailingFieldNames = const [],
}) {
  final all = pbObject.info_.fieldInfo.values.toList();
  ({String name, int tagNumber})? named(String name) {
    for (final field in all) {
      if (field.name == name) {
        return (name: field.name, tagNumber: field.tagNumber);
      }
    }
    return null;
  }

  final seen = <int>{};
  final ordered = <({String name, int tagNumber})>[];
  for (final name in leadingFieldNames) {
    final field = named(name);
    if (field == null || seen.contains(field.tagNumber)) continue;
    ordered.add(field);
    seen.add(field.tagNumber);
  }
  for (final field in all) {
    if (seen.contains(field.tagNumber)) continue;
    if (trailingFieldNames.contains(field.name)) continue;
    ordered.add((name: field.name, tagNumber: field.tagNumber));
    seen.add(field.tagNumber);
  }
  for (final name in trailingFieldNames) {
    final field = named(name);
    if (field == null || seen.contains(field.tagNumber)) continue;
    ordered.add(field);
    seen.add(field.tagNumber);
  }
  return ordered;
}

String formatProtoFieldName(String fieldName) {
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
  const technicalFields = ['info_', 'unknownFields'];
  if (technicalFields.contains(fieldName)) return true;
  if (skipFieldNames.contains(fieldName)) return true;
  if (fieldValue is String && fieldValue.isEmpty) return true;
  if (fieldValue is PbList && fieldValue.isEmpty) return true;
  // Retail is the default article kind; only basket is worth showing.
  if (fieldValue is ArticleKindPb && fieldValue != ArticleKindPb.basket) {
    return true;
  }
  return false;
}

Widget _buildField(
  BuildContext context,
  String fieldName,
  dynamic fieldValue,
  List<String> skipFieldNames,
  List<String> leadingFieldNames,
  List<String> trailingFieldNames,
) {
  if (fieldValue == null) return const SizedBox.shrink();

  if (fieldValue is String) {
    if (fieldValue.isEmpty) return const SizedBox.shrink();
    return ListTile(
      title: Text(formatProtoFieldName(fieldName)),
      subtitle: SelectableText(fieldValue),
    );
  }
  if (fieldValue is int || fieldValue is double) {
    return ListTile(
      title: Text(formatProtoFieldName(fieldName)),
      subtitle: Text(fieldValue.toString()),
    );
  }
  if (fieldValue is bool) {
    return ListTile(
      title: Text(formatProtoFieldName(fieldName)),
      trailing: Icon(
        fieldValue ? Icons.check_circle : Icons.cancel,
        color: fieldValue ? Colors.green : Colors.red,
      ),
    );
  }
  if (fieldValue is Timestamp) {
    return ListTile(
      title: Text(formatProtoFieldName(fieldName)),
      subtitle: Text(fieldValue.toDateTime().toIso8601String()),
    );
  }
  if (fieldValue is Phone) {
    if (fieldValue.number.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(formatProtoFieldName(fieldName)),
      subtitle: Text(
        fieldValue.hasCountryCode()
            ? '+${fieldValue.countryCode} ${fieldValue.number}'
            : fieldValue.number,
      ),
      children: [
        if (fieldValue.hasCountryCode())
          ListTile(
            title: const Text('Country Code'),
            subtitle: Text('+${fieldValue.countryCode}'),
          ),
        ListTile(
          title: const Text('Number'),
          subtitle: Text(fieldValue.number),
        ),
      ],
    );
  }
  if (fieldValue is Address) {
    if (fieldValue.street.isEmpty && fieldValue.city.isEmpty) {
      return const SizedBox.shrink();
    }
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(formatProtoFieldName(fieldName)),
      subtitle: Text(
        [fieldValue.street, fieldValue.city, fieldValue.code]
            .where((s) => s.isNotEmpty)
            .join(', '),
      ),
      children: [
        ProtobufDynamicBody(
          pbObject: fieldValue,
          skipFieldNames: skipFieldNames,
          leadingFieldNames: leadingFieldNames,
          trailingFieldNames: trailingFieldNames,
        ),
      ],
    );
  }
  if (fieldValue is PbList) {
    if (fieldValue.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(formatProtoFieldName(fieldName)),
      subtitle: Text('${fieldValue.length} items'),
      children: [
        for (var i = 0; i < fieldValue.length; i++)
          if (fieldValue[i] is GeneratedMessage)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ProtobufDynamicBody(
                pbObject: fieldValue[i] as GeneratedMessage,
                skipFieldNames: skipFieldNames,
                leadingFieldNames: leadingFieldNames,
                trailingFieldNames: trailingFieldNames,
              ),
            )
          else
            ProtobufFieldWidget(
              fieldName: '${formatProtoFieldName(fieldName)} ${i + 1}',
              fieldValue: fieldValue[i],
              skipFieldNames: skipFieldNames,
              leadingFieldNames: leadingFieldNames,
              trailingFieldNames: trailingFieldNames,
            ),
      ],
    );
  }
  if (fieldValue is ProtobufEnum) {
    return ListTile(
      title: Text(formatProtoFieldName(fieldName)),
      subtitle: Text(fieldValue.name),
    );
  }
  if (fieldValue is GeneratedMessage) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(formatProtoFieldName(fieldName)),
      children: [
        ProtobufDynamicBody(
          pbObject: fieldValue,
          skipFieldNames: skipFieldNames,
          leadingFieldNames: leadingFieldNames,
          trailingFieldNames: trailingFieldNames,
        ),
      ],
    );
  }
  final asString = fieldValue.toString();
  if (asString.isEmpty || asString == '[]') {
    return const SizedBox.shrink();
  }
  return ListTile(
    title: Text(formatProtoFieldName(fieldName)),
    subtitle: Text(asString),
  );
}

