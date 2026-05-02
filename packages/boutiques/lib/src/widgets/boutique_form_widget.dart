import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:provider/provider.dart';
import 'package:fl_country_code_picker_weebi/fl_country_code_picker.dart';
import '../../boutique.dart';
import '../l10n/boutique_ui_strings.dart';
import '../providers/boutique_provider.dart';
import '../utils/drc_secondary_currency.dart';
import '../utils/email_validator.dart';
import 'billing_currency_field.dart';
import 'secondary_display_currency_fields.dart';

/// Widget for editing a boutique or chain in a dialog/modal, similar to UserFormWidget
class BoutiqueFormWidget extends StatefulWidget {
  final BoutiqueMongo? boutique;
  final Chain? chain;
  final VoidCallback? onSaved;

  const BoutiqueFormWidget({
    super.key,
    this.boutique,
    this.chain,
    this.onSaved,
  })  : assert(boutique != null || chain != null,
            'Either boutique or chain must be provided'),
        assert(boutique == null || chain == null,
            'Cannot provide both boutique and chain');

  @override
  State<BoutiqueFormWidget> createState() => _BoutiqueFormWidgetState();
}

class _BoutiqueFormWidgetState extends State<BoutiqueFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressStreetController;
  late TextEditingController _addressCityController;
  late TextEditingController _addressCodeController;
  late TextEditingController _addressCountryController;
  late TextEditingController _phoneController;
  final _billingCurrencyController = TextEditingController();
  final _secondaryDisplayCurrencyController = TextEditingController();
  final _recentTicketEditWindowMinutesController = TextEditingController();
  bool _dualCurrencyEnabled = false;
  bool _negativeStockGuardEnabled = false;
  bool _recentTicketEditEnabled = false;
  bool _isSaving = false;
  String? _error;

  // Country selection for address
  CountryCode? _selectedAddressCountry;
  String _selectedPhoneCountryCode = '+1'; // Default to US

  bool get _isEditingChain => widget.chain != null;

  Chain? _parentChain(BoutiqueProvider provider, BoutiqueMongo b) {
    for (final c in provider.chains) {
      if (c.chainId == b.chainId) return c;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _billingCurrencyController.addListener(_onBillingCurrencyChanged);
  }

  void _initializeControllers() {
    if (_isEditingChain) {
      final chain = widget.chain!;
      _nameController = TextEditingController(text: chain.name);
      _emailController = TextEditingController();
      _addressStreetController = TextEditingController();
      _addressCityController = TextEditingController();
      _addressCodeController = TextEditingController();
      _addressCountryController = TextEditingController();
      _phoneController = TextEditingController();
      if (chain.hasCurrency() && chain.currency.trim().isNotEmpty) {
        _billingCurrencyController.text = chain.currency.trim().toUpperCase();
      }
      if (chain.hasIsDualCurrencyEnabled() && chain.isDualCurrencyEnabled) {
        _dualCurrencyEnabled = true;
      }
      if (chain.hasSecondaryDisplayCurrency() &&
          chain.secondaryDisplayCurrency.trim().isNotEmpty) {
        _secondaryDisplayCurrencyController.text =
            chain.secondaryDisplayCurrency.trim().toUpperCase();
      } else if (_dualCurrencyEnabled) {
        _secondaryDisplayCurrencyController.text =
            kDefaultSecondaryDisplayCurrencyUsd;
      }
      if (chain.hasBusinessRules()) {
        _applyBusinessRules(chain.businessRules);
      }
    } else {
      final boutique = widget.boutique!;
      _nameController = TextEditingController(text: boutique.displayName);
      _emailController = TextEditingController(
          text: boutique.boutique.hasMail()
              ? boutique.boutique.mail
              : boutique.additionalAttributes['email'] ?? '');
      _addressStreetController =
          TextEditingController(text: boutique.boutique.addressFull.street);
      _addressCityController =
          TextEditingController(text: boutique.boutique.addressFull.city);
      _addressCodeController =
          TextEditingController(text: boutique.boutique.addressFull.code);
      // Initialize country data first
      String countryText = '';
      if (boutique.boutique.hasAddressFull() &&
          boutique.boutique.addressFull.hasCountry()) {
        final address = boutique.boutique.addressFull;
        final selectedCountry =
            CountryCode.fromCode(address.country.code2Letters);
        _selectedAddressCountry = selectedCountry;
        countryText = address.country.namel10n.trim().isNotEmpty
            ? address.country.namel10n
            : (selectedCountry?.name ?? address.country.code2Letters);
        // print('BoutiqueForm: Initializing country field with: "$countryText" (code: ${address.country.code2Letters})');
      }
      _addressCountryController = TextEditingController(text: countryText);
      _phoneController =
          TextEditingController(text: boutique.boutique.phone.number);

      // Initialize phone country code
      if (boutique.boutique.hasPhone() &&
          boutique.boutique.phone.hasCountryCode()) {
        _selectedPhoneCountryCode = '+${boutique.boutique.phone.countryCode}';
      }

      if (boutique.boutique.hasCurrency() &&
          boutique.boutique.currency.trim().isNotEmpty) {
        _billingCurrencyController.text =
            boutique.boutique.currency.trim().toUpperCase();
      }

      final dual = readDualCurrencyFromBoutiquePb(boutique.boutique);
      _dualCurrencyEnabled = dual.dualEnabled;
      final sec = dual.secondaryUpper;
      if (sec.isNotEmpty) {
        _secondaryDisplayCurrencyController.text = sec;
      } else if (_dualCurrencyEnabled) {
        _secondaryDisplayCurrencyController.text =
            kDefaultSecondaryDisplayCurrencyUsd;
      }
      if (boutique.boutique.hasBusinessRules()) {
        _applyBusinessRules(boutique.boutique.businessRules);
      }
    }
  }

  void _onBillingCurrencyChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressStreetController.dispose();
    _addressCityController.dispose();
    _addressCodeController.dispose();
    _addressCountryController.dispose();
    _phoneController.dispose();
    _billingCurrencyController.removeListener(_onBillingCurrencyChanged);
    _billingCurrencyController.dispose();
    _secondaryDisplayCurrencyController.dispose();
    _recentTicketEditWindowMinutesController.dispose();
    super.dispose();
  }

  void _applyBusinessRules(BusinessRules rules) {
    _negativeStockGuardEnabled = rules.isNegativeStockGuardEnabled;
    _recentTicketEditEnabled = rules.isRecentTicketEditEnabled;
    final minutes = rules.recentTicketEditWindowMinutes;
    _recentTicketEditWindowMinutesController.text =
        minutes > 0 ? minutes.toString() : '';
    if (_recentTicketEditEnabled &&
        _recentTicketEditWindowMinutesController.text.isEmpty) {
      _recentTicketEditWindowMinutesController.text = '5';
    }
  }

  BusinessRules _buildBusinessRules() {
    final minutes =
        int.tryParse(_recentTicketEditWindowMinutesController.text.trim()) ?? 0;
    return BusinessRules()
      ..isNegativeStockGuardEnabled = _negativeStockGuardEnabled
      ..isRecentTicketEditEnabled = _recentTicketEditEnabled
      ..recentTicketEditWindowMinutes = minutes;
  }

  void _setRecentTicketEditEnabled(bool value) {
    setState(() {
      _recentTicketEditEnabled = value;
      if (value && _recentTicketEditWindowMinutesController.text.isEmpty) {
        _recentTicketEditWindowMinutesController.text = '5';
      }
    });
  }

  Widget _addressCountryPrefixIcon() {
    if (_selectedAddressCountry != null) {
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: _selectedAddressCountry!.flagImage(
            width: 24,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return const Icon(Icons.flag);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditingChain
          ? BoutiqueUiStrings.editChainDialogTitle
          : BoutiqueUiStrings.editBoutiqueDialogTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Name field (required for both)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _isEditingChain
                        ? BoutiqueUiStrings.chainNameLabel
                        : BoutiqueUiStrings.boutiqueNameLabel,
                    hintText: _isEditingChain
                        ? BoutiqueUiStrings.hintChainNameExample
                        : BoutiqueUiStrings.hintBoutiqueNameExample,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                        _isEditingChain ? Icons.account_tree : Icons.store),
                    suffixIcon: _nameController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _nameController.clear()),
                          ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return BoutiqueUiStrings.nameRequired;
                    }
                    if (!_isEditingChain && value.trim().length < 2) {
                      return BoutiqueUiStrings.nameMinLength;
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                if (_isEditingChain) ...[
                  BillingCurrencyField(controller: _billingCurrencyController),
                  const SizedBox(height: 16),
                  SecondaryDisplayCurrencyFields(
                    eligible: shouldShowSecondaryCurrencyForChain(
                        _billingCurrencyController.text),
                    dualEnabled: _dualCurrencyEnabled,
                    onDualChanged: (v) =>
                        setState(() => _dualCurrencyEnabled = v),
                    secondaryController: _secondaryDisplayCurrencyController,
                  ),
                  const SizedBox(height: 16),
                  _buildBusinessRulesSection(),
                ] else ...[
                  // Boutique-specific fields (aligned with BoutiqueCreateView)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: BoutiqueUiStrings.emailAddressLabel,
                      hintText: BoutiqueUiStrings.enterBoutiqueEmailHint,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return EmailValidator.validate(value.trim());
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: BoutiqueUiStrings.phoneLabel,
                      hintText: BoutiqueUiStrings.enterPhoneHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      prefix: GestureDetector(
                        onTap: () async {
                          final countryPicker = const FlCountryCodePicker();
                          final code = await countryPicker.showPicker(
                              context: context, pickerMaxHeight: 800);
                          if (code != null) {
                            setState(() {
                              _selectedPhoneCountryCode = code.dialCode;
                              if (_selectedAddressCountry == null) {
                                _selectedAddressCountry = code;
                                _addressCountryController.text =
                                    code.localize(context).name ==
                                            'Unknown Country'
                                        ? code.name
                                        : code.localize(context).name;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedPhoneCountryCode.startsWith('+')
                                ? _selectedPhoneCountryCode
                                : '+$_selectedPhoneCountryCode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      suffixIcon: _phoneController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _phoneController.clear()),
                            ),
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return BoutiqueUiStrings.phoneNumbersOnly;
                        }
                        if (value.length < 7 || value.length > 15) {
                          return BoutiqueUiStrings.phoneLengthRange;
                        }
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressStreetController,
                    decoration: InputDecoration(
                      labelText: BoutiqueUiStrings.streetAddressStar,
                      hintText: BoutiqueUiStrings.enterStreetHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: _addressStreetController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(
                                  () => _addressStreetController.clear()),
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _addressCityController,
                          decoration: const InputDecoration(
                            labelText: BoutiqueUiStrings.cityStar,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _addressCodeController,
                          decoration: const InputDecoration(
                            labelText: BoutiqueUiStrings.postalCodeLabel,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.markunread_mailbox),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    controller: _addressCountryController,
                    onTap: () async {
                      final countryPicker = const FlCountryCodePicker();
                      final code = await countryPicker.showPicker(
                          context: context, pickerMaxHeight: 800);
                      if (code != null) {
                        setState(() {
                          _selectedAddressCountry = code;
                          _addressCountryController.text =
                              code.localize(context).name == 'Unknown Country'
                                  ? code.name
                                  : code.localize(context).name;
                          _selectedPhoneCountryCode = code.dialCode;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: BoutiqueUiStrings.countryLabel,
                      hintText: BoutiqueUiStrings.selectCountryHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: _addressCountryPrefixIcon(),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return BoutiqueUiStrings.selectCountryError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  BillingCurrencyField(controller: _billingCurrencyController),
                  const SizedBox(height: 16),
                  Consumer<BoutiqueProvider>(
                    builder: (context, provider, _) {
                      final b = widget.boutique!;
                      final iso = billingIsoForBoutiqueDualEligibility(
                        billingFieldText: _billingCurrencyController.text,
                        existingNestedBoutique: b.boutique,
                        parentChain: _parentChain(provider, b),
                      );
                      return SecondaryDisplayCurrencyFields(
                        eligible: shouldShowSecondaryCurrencyForBoutique(
                          addressCountry: _selectedAddressCountry,
                          billingCurrencyIso: iso,
                        ),
                        dualEnabled: _dualCurrencyEnabled,
                        onDualChanged: (v) =>
                            setState(() => _dualCurrencyEnabled = v),
                        secondaryController:
                            _secondaryDisplayCurrencyController,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildBusinessRulesSection(),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text(BoutiqueUiStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveForm,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(BoutiqueUiStrings.save),
        ),
      ],
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final provider = context.read<BoutiqueProvider>();
      bool success = false;

      if (_isEditingChain) {
        final request = ChainRequest()
          ..chainId = widget.chain!.chainId
          ..name = _nameController.text.trim();
        final cur = _billingCurrencyController.text.trim().toUpperCase();
        if (cur.isNotEmpty) {
          request.currency = cur;
        } else {
          request.clearCurrency();
        }
        applyDualCurrencyToChainRequest(
          request,
          billingCurrencyIso: _billingCurrencyController.text,
          dualEnabled: _dualCurrencyEnabled,
          secondaryTrimmedUpper:
              _secondaryDisplayCurrencyController.text.trim().toUpperCase(),
        );
        request.businessRules = _buildBusinessRules();
        success = await provider.updateChain(request);
      } else {
        // Update boutique
        final boutique = widget.boutique!;
        final updatedBoutique = BoutiquePb()
          ..mergeFromMessage(boutique.boutique)
          ..boutiqueId =
              boutique.boutiqueId // Ensure boutiqueId is explicitly set
          ..name = _nameController.text.trim();

        // Update address if provided
        if (_addressStreetController.text.isNotEmpty ||
            _addressCityController.text.isNotEmpty ||
            _addressCodeController.text.isNotEmpty ||
            _addressCountryController.text.isNotEmpty) {
          updatedBoutique.addressFull = Address()
            ..street = _addressStreetController.text.trim()
            ..city = _addressCityController.text.trim()
            ..code = _addressCodeController.text.trim();

          // Add country if selected
          if (_selectedAddressCountry != null) {
            updatedBoutique.addressFull.country = Country()
              ..code2Letters = _selectedAddressCountry!.code
              ..namel10n = _addressCountryController.text.trim();
          }
        }

        // Update phone if provided
        if (_phoneController.text.isNotEmpty) {
          updatedBoutique.phone = Phone()
            ..number = _phoneController.text.trim();

          if (_selectedPhoneCountryCode.isNotEmpty) {
            updatedBoutique.phone.countryCode =
                int.tryParse(_selectedPhoneCountryCode.replaceAll('+', '')) ??
                    33;
          }
        }

        // Update email if provided
        if (_emailController.text.isNotEmpty) {
          updatedBoutique.mail = _emailController.text.trim();
        }

        final cur = _billingCurrencyController.text.trim().toUpperCase();
        if (cur.isNotEmpty) {
          updatedBoutique.currency = cur;
        } else {
          updatedBoutique.clearCurrency();
        }

        final billingIso = billingIsoForBoutiqueDualEligibility(
          billingFieldText: _billingCurrencyController.text,
          existingNestedBoutique: boutique.boutique,
          parentChain: _parentChain(provider, boutique),
        );
        applyDualCurrencyToBoutiquePb(
          updatedBoutique,
          eligible: shouldShowSecondaryCurrencyForBoutique(
            addressCountry: _selectedAddressCountry,
            billingCurrencyIso: billingIso,
          ),
          dualEnabled: _dualCurrencyEnabled,
          secondaryTrimmedUpper:
              _secondaryDisplayCurrencyController.text.trim().toUpperCase(),
        );
        updatedBoutique.businessRules = _buildBusinessRules();

        success = await provider.updateBoutique(
            boutique.chainId, boutique.boutiqueId, updatedBoutique);
      }

      if (success) {
        if (mounted) {
          // Call the callback first
          widget.onSaved?.call();
          // Then close the dialog
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _error = provider.error ?? 'Failed to save changes';
        });
      }
    } on GrpcError catch (e) {
      setState(() {
        _error = '${e.code} ${e.message}';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to save: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildBusinessRulesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BoutiqueUiStrings.businessRulesSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const ValueKey('negative-stock-guard-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text(BoutiqueUiStrings.negativeStockGuardTitle),
              subtitle:
                  const Text(BoutiqueUiStrings.negativeStockGuardSubtitle),
              value: _negativeStockGuardEnabled,
              onChanged: (value) =>
                  setState(() => _negativeStockGuardEnabled = value),
            ),
       /*      const Divider(height: 16),
            SwitchListTile(
              key: const ValueKey('recent-ticket-edit-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text(BoutiqueUiStrings.recentTicketEditTitle),
              subtitle: const Text(BoutiqueUiStrings.recentTicketEditSubtitle),
              value: _recentTicketEditEnabled,
              onChanged: _setRecentTicketEditEnabled,
            ), */
            if (_recentTicketEditEnabled) ...[
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('recent-ticket-edit-window-field'),
                controller: _recentTicketEditWindowMinutesController,
                decoration: const InputDecoration(
                  labelText:
                      BoutiqueUiStrings.recentTicketEditWindowMinutesLabel,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (!_recentTicketEditEnabled) return null;
                  final minutes = int.tryParse((value ?? '').trim());
                  if (minutes == null || minutes <= 0) {
                    return BoutiqueUiStrings.recentTicketEditWindowInvalid;
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
