import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

class ContactDataSource extends DataTableSource {
  final List<ContactPb> messages;

  ContactDataSource(this.messages);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= messages.length) return const DataRow(cells: []);

    final message = messages[index];
    final descriptor = message.info_;
    List<DataCell> cells = [];

    for (var field in descriptor.byName.values) {
      final fieldValue = message.getField(field.tagNumber);
      cells.add(DataCell(Text(fieldValue.toString())));
    }

    return DataRow.byIndex(index: index, cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => messages.length;

  @override
  int get selectedRowCount => 0;
}

class ProtoMessagesTable extends StatelessWidget {
  final List<ContactPb> messages;
  final String header;
  const ProtoMessagesTable(
      {required this.header, required this.messages, super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = ContactDataSource(messages);
    final descriptor = messages.isNotEmpty ? messages[0].info_ : null;

    return PaginatedDataTable(
      header: Text(header),
      columns: descriptor != null
          ? descriptor.byName.values
              .map((field) => DataColumn(label: Text(field.name)))
              .toList()
          : [],
      source: dataSource,
      rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
    );
  }
}

List<Widget> fieldWidgets(ContactPb message) {
  List<Widget> fieldWidgets = [];

  final descriptor = message.info_;
  for (var field in descriptor.byName.values) {
    final fieldName = field.name;
    final fieldValue = message.getField(field.tagNumber);

    if (field.isRepeated) {
      for (var value in fieldValue) {
        // Handle repeated fields
        fieldWidgets.add(_buildFieldWidget(fieldName, value));
      }
    } else {
      // Handle singular fields
      fieldWidgets.add(_buildFieldWidget(fieldName, fieldValue));
    }
  }
  return fieldWidgets;
}

Widget _buildFieldWidget(String fieldName, dynamic fieldValue) {
  switch (fieldValue.runtimeType) {
    case const (int):
      return ListTile(
        title: Text(fieldName),
        subtitle: Text(fieldValue == 0 ? '' : fieldValue.toString()),
      );
    case const (String):
      return ListTile(
        title: Text(fieldName),
        subtitle: Text(fieldValue),
      );
    case const (bool):
      return ListTile(
        title: Text(fieldName),
        subtitle: Text(fieldValue ? 'True' : 'False'),
      );
    case const (List<int>):
      return ListTile(
        title: Text(fieldName),
        subtitle: Text((fieldValue as List<int>).join(', ')),
      );
    case const (List<String>):
      return ListTile(
        title: Text(fieldName),
        subtitle: Text((fieldValue as List<String>).join(', ')),
      );
    default:
      return ListTile(
        title: Text(fieldName),
        subtitle: const Text('Unsupported field type'),
      );
  }
}
