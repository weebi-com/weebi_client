import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/views/mirror.dart';

void main() {
  final contact = {
    'id': 1,
    'firstName': 'John',
    'lastName': 'Doe',
    'mail': 'john@doe.com',
  };
  // Example usage
  var myMessages = [
    ContactPb.create()..mergeFromProto3Json(contact, ignoreUnknownFields: true),
    ContactPb.create()..mergeFromProto3Json(contact, ignoreUnknownFields: true),
  ];
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Proto Messages Viewer')),
      body: ProtoMessagesTable(header: 'Contacts', messages: myMessages),
    ),
  ));
}
