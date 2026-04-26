import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/provider/provider.dart';
import 'package:web_admin/contacts/widgets/contacts_body.dart';

/// {@template contacts_page}
/// A description for ContactsPage
/// {@endtemplate}
class ContactsPage extends StatelessWidget {
  final String chainId;

  /// {@macro contacts_page}
  const ContactsPage(this.chainId, {super.key});

  /// The static route for ContactsPage
  static Route<dynamic> route(String chainId) {
    return MaterialPageRoute<dynamic>(builder: (_) => ContactsPage(chainId));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ContactsNotifier(context.read<ContactServiceClient>(), chainId),
      child: const Scaffold(
        body: ContactsView(),
      ),
    );
  }
}

/// {@template contacts_view}
/// Displays the Body of ContactsView
/// {@endtemplate}
class ContactsView extends StatelessWidget {
  /// {@macro contacts_view}
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContactsBody();
  }
}
