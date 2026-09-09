import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/provider/contacts_provider.dart';
import 'package:web_admin/core/chain/resolve_chain_id.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/views/widgets/protobuf/protobuf_dynamic_body.dart';

class ContactViewScreen extends StatefulWidget {
  const ContactViewScreen({super.key, required this.contactId});

  final int contactId;

  @override
  State<ContactViewScreen> createState() => _ContactViewScreenState();
}

class _ContactViewScreenState extends State<ContactViewScreen> {
  ContactPb? _contact;
  bool _loading = true;
  String? _error;
  String _chainId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final boutiqueProvider = context.read<BoutiqueProvider>();
    final contactProvider = context.read<ContactServiceClientProvider>();
    try {
      _chainId =
          await resolveSelectedChainId(boutiqueProvider) ?? '';
      if (!mounted) return;
      final api = GrpcDirectoryApi(contactProvider.contactServiceClient);
      final contact = await api.readOne(
        ReadContactRequest(
          contactChainId: _chainId,
          contactId: widget.contactId,
        ),
      );
      if (!mounted) return;
      setState(() {
        _contact = contact;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final lang = Lang.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(lang.entityConfirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang.entityDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _contact == null) return;
    final api = GrpcDirectoryApi(
      context.read<ContactServiceClientProvider>().contactServiceClient,
    );
    await api.deleteOne(
      ContactRequest(chainId: _chainId, contact: _contact),
    );
    if (!mounted) return;
    context.go(RouteUri.contacts);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final contact = _contact;
    return PortalMasterLayout(
      selectedMenuUri: RouteUri.contacts,
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Text(_error!)
                : ListView(
                    children: [
                      EntityViewHeader(
                        title:
                            '${contact?.firstName ?? ''} ${contact?.lastName ?? ''}'
                                .trim(),
                        editLabel: lang.entityEdit,
                        deleteLabel: lang.entityDelete,
                        onEdit: () => context.push(
                          RouteUri.contactsEditFor(widget.contactId),
                        ),
                        onDelete: _delete,
                      ),
                      const SizedBox(height: kDefaultPadding),
                      if (contact != null)
                        ProtobufDynamicBody(pbObject: contact),
                    ],
                  ),
      ),
    );
  }
}
