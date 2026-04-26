import 'package:flutter/material.dart';
// import 'package:protobuf/protobuf.dart' show GeneratedMessage, PbList;
import 'package:protos_weebi/protos_weebi_io.dart'
    show
        Address,GeneratedMessage, PbList,
        Phone,
        Timestamp,
        UserPermissions;

class DynamicBody<T extends GeneratedMessage> extends StatelessWidget {
  final T pbObject;

  /// Optional list of field names to skip (e.g. ['permissions'] to hide in profile).
  final List<String> skipFieldNames;

  const DynamicBody({
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

      fields.add(ProtobufFieldWidget(
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

class ProtobufFieldWidget extends StatelessWidget {
  final String fieldName;
  final dynamic fieldValue;

  const ProtobufFieldWidget(
      {super.key, required this.fieldName, required this.fieldValue});

  @override
  Widget build(BuildContext context) {
    return _buildField(fieldName, fieldValue);
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

  final technicalFields = [
    'info_',
    'unknownFields',
  ];
  if (technicalFields.contains(fieldName)) return true;
  if (skipFieldNames.contains(fieldName)) return true;

  return false;
}

Widget _buildField(String fieldName, dynamic fieldValue) {
  if (fieldValue == null) return const SizedBox.shrink();

  switch (fieldValue.runtimeType) {
    case const (String):
      if (fieldValue.isEmpty) return const SizedBox.shrink();
      return ListTile(
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue),
      );
    case const (int) || const (double):
      return ListTile(
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue.toString()),
      );

    case const (bool):
      return ListTile(
        title: Text(_formatFieldName(fieldName)),
        trailing: Icon(
          fieldValue ? Icons.check_circle : Icons.cancel,
          color: fieldValue ? Colors.green : Colors.red,
        ),
      );

    case const (Timestamp):
      return ListTile(
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(
          fieldValue.toDateTime().toIso8601String(),
        ),
      );
    case const (Phone):
      if (fieldValue.number.isEmpty) {
        return const SizedBox.shrink();
      }
      return ExpansionTile(
        title: Text(_formatFieldName(fieldName)),
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
    case const (UserPermissions):
      return ExpansionTile(
        title: Text(_formatFieldName(fieldName)),
        children: [
          ListTile(
            title: const Text('User ID'),
            subtitle: SelectableText(fieldValue.userId),
          ),
          ListTile(
            title: const Text('Firm ID'),
            subtitle: Text(fieldValue.firmId),
          ),
          // TODO Handle other fields and oneof access
        ],
      );
    case const (PbList):
      final list = fieldValue as PbList;
      if (list.isEmpty) return const SizedBox.shrink();
      return ExpansionTile(
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text('${list.length} items'),
        children: list.map<Widget>((item) {
          return ProtobufFieldWidget(
            fieldName: fieldName,
            fieldValue: item,
          );
        }).toList(),
      );
    case const (Address):
      if (!fieldValue.hasStreet() || fieldValue.street.isEmpty) {
        return const SizedBox.shrink();
      }
      return ExpansionTile(
        title: Text(_formatFieldName(fieldName)),
        children: [
          if (fieldValue.street.isNotEmpty)
            ListTile(
              title: const Text('Street'),
              subtitle: Text(fieldValue.street),
            ),
          if (fieldValue.hasCode() && fieldValue.code.isNotEmpty)
            ListTile(
              title: const Text('Code'),
              subtitle: Text(fieldValue.code),
            ),
          if (fieldValue.hasCity() && fieldValue.city.isNotEmpty)
            ListTile(
              title: const Text('City'),
              subtitle: Text(fieldValue.city),
            ),
          if (fieldValue.hasCountry())
            ListTile(
              title: const Text('Country'),
              subtitle: Text(fieldValue.country.toString()),
            ),
          if (fieldValue.hasLatitude())
            ListTile(
              title: const Text('Latitude'),
              subtitle: Text(fieldValue.latitude.toString()),
            ),
          if (fieldValue.hasLongitude())
            ListTile(
              title: const Text('Longitude'),
              subtitle: Text(fieldValue.longitude.toString()),
            ),
        ],
      );
    default:
      if (fieldValue.toString().isEmpty || fieldValue.toString() == '[]') {
        return const SizedBox.shrink();
      }
      return ListTile(
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue.toString()),
      );
  }
}
