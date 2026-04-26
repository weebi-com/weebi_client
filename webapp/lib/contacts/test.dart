import 'package:flutter/material.dart';
import 'package:models_weebi/models.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/views/mirror.dart';

void main() {
  // Example usage
  var myMessages = [
    ContactPb.create()
      ..mergeFromProto3Json(ContactWeebi.dummy.toMap(),
          ignoreUnknownFields: true),
    ContactPb.create()
      ..mergeFromProto3Json(ContactWeebi.dummy2.toMap(),
          ignoreUnknownFields: true),
  ];
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Proto Messages Viewer')),
      body: ProtoMessagesTable(header: 'Contacts', messages: myMessages),
    ),
  ));
}
