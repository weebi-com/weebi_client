import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:fixnum/fixnum.dart';
import 'package:fl_country_code_picker_weebi/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/contact_form_validator.dart';
import 'package:web_admin/contacts/provider/contacts_provider.dart';
import 'package:web_admin/core/chain/resolve_chain_id.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/screens/contacts/contact_edit_form.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class ContactEditScreen extends StatefulWidget {
  const ContactEditScreen({super.key, this.contactId});

  final int? contactId;
  bool get isNew => contactId == null;

  @override
  State<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _mail = TextEditingController();
  final _phone = TextEditingController();
  final _overdraft = TextEditingController();
  final _street = TextEditingController();
  final _code = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  bool _isClient = true;
  bool _isSupplier = false;
  CountryCode? _countryCodePhone;
  ContactPb? _draft;
  late final ContactsNotifier _notifier;
  ContactFormValidator? _formValidator;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _notifier = ContactsNotifier(
      api: GrpcDirectoryApi(
        context.read<ContactServiceClientProvider>().contactServiceClient,
      ),
      chainId: '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final chainId =
        await resolveSelectedChainId(context.read<BoutiqueProvider>());
    if (!mounted) return;
    if (chainId != null) {
      await _notifier.setChainId(chainId);
    }
    _formValidator = ContactFormValidator(
      messages: ContactFormMessages.fromLang(Lang.of(context)),
    );
    if (widget.isNew) {
      final id = await _notifier.nextContactId();
      _draft = newContactDraft(id: id);
      _countryCodePhone = CountryCode.fromDialCode('+221');
    } else {
      try {
        _draft = await _notifier.readOne(widget.contactId!);
      } catch (e) {
        _loadError = e.toString();
      }
    }
    if (_draft != null) _bind(_draft!);
    if (mounted) setState(() => _loading = false);
  }

  void _bind(ContactPb contact) {
    _firstName.text = contact.firstName;
    _lastName.text = contact.lastName;
    _mail.text = contact.mail;
    _isClient = contact.isClient;
    _isSupplier = contact.isSupplier;
    _overdraft.text =
        contact.overdraft.toInt() == 0 ? '' : contact.overdraft.toString();
    if (contact.hasPhone() && contact.phone.countryCode != 0) {
      _countryCodePhone =
          CountryCode.fromDialCode('+${contact.phone.countryCode}');
      _phone.text = contact.phone.number;
    } else {
      _countryCodePhone ??= CountryCode.fromDialCode('+221');
      if (contact.hasPhone()) {
        _phone.text = contact.phone.number;
      }
    }
    if (contact.hasAddressFull()) {
      _street.text = contact.addressFull.street;
      _code.text = contact.addressFull.code;
      _city.text = contact.addressFull.city;
      _country.text = contact.addressFull.country.namel10n.isNotEmpty
          ? contact.addressFull.country.namel10n
          : contact.addressFull.country.code2Letters;
    }
  }

  int get _countryCodeInt {
    final dial = _countryCodePhone?.dialCode ?? '+221';
    return int.tryParse(dial.replaceFirst('+', '')) ?? 221;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mail.dispose();
    _phone.dispose();
    _overdraft.dispose();
    _street.dispose();
    _code.dispose();
    _city.dispose();
    _country.dispose();
    _formValidator?.dispose();
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final validator = _formValidator;
    if (validator == null) return;
    final ok = validator.validateAll(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _mail.text,
      phone: _phone.text,
    );
    if (!ok) {
      setState(() {});
      return;
    }
    final draft = _draft!;
    draft
      ..firstName = _firstName.text.trim()
      ..lastName = _lastName.text.trim()
      ..mail = _mail.text.trim()
      ..isClient = _isClient
      ..isSupplier = _isSupplier
      ..overdraft = Int64(int.tryParse(_overdraft.text) ?? 0)
      ..updateDate = DateTime.now().toUtc().toIso8601String()
      ..phone = (Phone.create()
        ..countryCode = _countryCodeInt
        ..number = _phone.text.trim())
      ..addressFull = (Address.create()
        ..street = _street.text.trim()
        ..code = _code.text.trim()
        ..city = _city.text.trim()
        ..country = Country(
          code2Letters: _country.text.trim().length == 2
              ? _country.text.trim().toUpperCase()
              : '',
          namel10n: _country.text.trim(),
        ));
    final saved = await _notifier.save(draft, isNew: widget.isNew);
    if (!mounted) return;
    if (saved) context.go(RouteUri.contactsViewFor(draft.id));
  }

  @override
  Widget build(BuildContext context) {
    final validator = _formValidator;
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        return PortalMasterLayout(
          selectedMenuUri: RouteUri.contacts,
          body: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                    ? Text(_loadError!)
                    : validator == null
                        ? const SizedBox.shrink()
                        : ChangeNotifierProvider<ContactFormValidator>.value(
                            value: validator,
                            child: ContactEditForm(
                              formKey: _formKey,
                              isNew: widget.isNew,
                              firstNameController: _firstName,
                              lastNameController: _lastName,
                              mailController: _mail,
                              phoneController: _phone,
                              overdraftController: _overdraft,
                              streetController: _street,
                              codeController: _code,
                              cityController: _city,
                              countryController: _country,
                              isClient: _isClient,
                              isSupplier: _isSupplier,
                              onIsClientChanged: (v) =>
                                  setState(() => _isClient = v),
                              onIsSupplierChanged: (v) =>
                                  setState(() => _isSupplier = v),
                              dialCode: _countryCodePhone?.dialCode ?? '+221',
                              onDialCodeChanged: (code) =>
                                  setState(() => _countryCodePhone = code),
                              onSave: _save,
                              onCancel: () => context.go(RouteUri.contacts),
                              isSaving: _notifier.isLoading,
                              error: _notifier.error,
                              onFieldsChanged: () => setState(() {}),
                            ),
                          ),
          ),
        );
      },
    );
  }
}
