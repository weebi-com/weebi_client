import 'package:flutter/material.dart';
import 'package:web_admin/contacts/provider/provider.dart';
import 'package:web_admin/views/mirror.dart';

/// {@template contacts_body}
/// Body of the ContactsPage.
///
/// Add what it does
/// {@endtemplate}
class ContactsBody extends StatelessWidget {
  /// {@macro contacts_body}
  const ContactsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactsNotifier>(
      builder: (context, state, child) {
        return ProtoMessagesTable(header: 'Contacts', messages: state.contacts);
      },
    );
  }
}
