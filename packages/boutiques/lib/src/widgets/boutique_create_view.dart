import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_country_code_picker_weebi/fl_country_code_picker.dart';
import 'package:protos_weebi/grpc.dart';

import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:provider/provider.dart';
import '../../boutique.dart';
import '../l10n/boutique_ui_strings.dart';
import '../providers/boutique_provider.dart';
import 'billing_currency_field.dart';
import 'secondary_display_currency_fields.dart';
import '../utils/drc_secondary_currency.dart';
import '../utils/email_validator.dart';

/// Widget for creating/editing boutiques and chains
class BoutiqueCreateView extends StatefulWidget {
  final BoutiqueMongo? boutique; // For editing existing boutique
  final Chain? chain; // For editing existing chain
  final String? initialChainId; // For creating boutique in specific chain
  final bool isEditing;

  const BoutiqueCreateView({
    super.key,
    this.boutique,
    this.chain,
    this.initialChainId,
  }) : isEditing = boutique != null || chain != null;

  /// Create a new chain
  const BoutiqueCreateView.createChain({super.key})
      : boutique = null,
        chain = null,
        initialChainId = null,
        isEditing = false;

  /// Create a new boutique in a specific chain
  const BoutiqueCreateView.createBoutique({
    super.key,
    required String chainId,
  })  : boutique = null,
        chain = null,
        initialChainId = chainId,
        isEditing = false;

  /// Edit an existing boutique
  const BoutiqueCreateView.editBoutique({
    super.key,
    required BoutiqueMongo this.boutique,
  })  : chain = null,
        initialChainId = null,
        isEditing = true;

  /// Edit an existing chain
  const BoutiqueCreateView.editChain({
    super.key,
    required Chain this.chain,
  })  : boutique = null,
        initialChainId = null,
        isEditing = true;

  @override
  State<BoutiqueCreateView> createState() => _BoutiqueCreateViewState();
}

class _BoutiqueCreateViewState extends State<BoutiqueCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Common controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Boutique-specific controllers
  final _addressStreetController = TextEditingController();
  final _addressCityController = TextEditingController();
  final _addressCodeController = TextEditingController();
  final _addressCountryController = TextEditingController();
  final _phoneController = TextEditingController();

  // Dropdowns and selections
  String? _selectedChainId;
  final _billingCurrencyController = TextEditingController();
  final _secondaryDisplayCurrencyController = TextEditingController();
  final _recentTicketEditWindowMinutesController = TextEditingController();

  /// Dual / secondary display currency (RDC / CDF context only).
  bool _dualCurrencyEnabled = false;
  bool _negativeStockGuardEnabled = false;
  bool _recentTicketEditEnabled = false;

  // Phone input helpers
  String _selectedPhoneCountryCode = '+1'; // Default to US

  // Country selection for address
  CountryCode? _selectedAddressCountry;
  // State management
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.isEditing) {
      if (widget.chain != null) {
        // Editing chain
        final chain = widget.chain!;
        _nameController.text = chain.name;
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
        _applyBusinessRulesFromChain(chain);
      } else if (widget.boutique != null) {
        // Editing boutique
        final boutique = widget.boutique!;
        _nameController.text = boutique.displayName;
        _selectedChainId = boutique.chainId;

        // Email
        if (boutique.boutique.hasMail() && boutique.boutique.mail.isNotEmpty) {
          _emailController.text = boutique.boutique.mail;
        } else if (boutique.additionalAttributes.containsKey('email')) {
          _emailController.text = boutique.additionalAttributes['email']!;
        }

        if (boutique.boutique.hasCurrency() &&
            boutique.boutique.currency.trim().isNotEmpty) {
          _billingCurrencyController.text =
              boutique.boutique.currency.trim().toUpperCase();
        }

        // Address
        if (boutique.boutique.hasAddressFull()) {
          final address = boutique.boutique.addressFull;
          _addressStreetController.text = address.street;
          _addressCityController.text = address.city;
          _addressCodeController.text = address.code;
          if (address.hasCountry()) {
            final selectedCountry =
                CountryCode.fromCode(address.country.code2Letters);
            _selectedAddressCountry = selectedCountry;
            final countryName = address.country.namel10n.trim().isNotEmpty
                ? address.country.namel10n
                : (selectedCountry?.localize(context).name == null ||
                        selectedCountry!.localize(context).name ==
                            'Unknown Country'
                    ? selectedCountry?.name ?? ''
                    : selectedCountry.localize(context).name);
            _addressCountryController.text = countryName;
          }
        }

        // Phone
        if (boutique.boutique.hasPhone()) {
          final phone = boutique.boutique.phone;
          _phoneController.text = phone.number;
          if (phone.hasCountryCode()) {
            _selectedPhoneCountryCode = '+${phone.countryCode}';
          }
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
    } else {
      // Creating new
      _selectedChainId = widget.initialChainId;
      _billingCurrencyController.addListener(_onBillingCurrencyChanged);

      // Initialize currency from parent chain if available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final provider = context.read<BoutiqueProvider>();
        final parentChain = _parentChainForBoutique(provider);
        if (parentChain != null) {
          if (parentChain.hasCurrency() &&
              parentChain.currency.trim().isNotEmpty) {
            _billingCurrencyController.text =
                parentChain.currency.trim().toUpperCase();
          }
          setState(() => _applyBusinessRulesFromChain(parentChain));
        }
      });
    }
  }

  void _onBillingCurrencyChanged() {
    if (!mounted) return;
    setState(() {});
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countryPicker = const FlCountryCodePicker();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
              tooltip: _isChainContext
                  ? BoutiqueUiStrings.deleteChain
                  : BoutiqueUiStrings.deleteBoutique,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) _buildErrorCard(),
              _buildBasicInfoSection(countryPicker),
              const SizedBox(height: 16),
              _buildCurrencySection(),
              if (_isCreatingBoutique()) ...[
                const SizedBox(height: 16),
                _buildChainSelectionSection(),
              ],
              const SizedBox(height: 16),
              _buildBusinessRulesSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    if (widget.isEditing) {
      return _isChainContext
          ? BoutiqueUiStrings.editChainDialogTitle
          : BoutiqueUiStrings.editBoutiqueDialogTitle;
    }
    return _isChainContext
        ? BoutiqueUiStrings.createChain
        : BoutiqueUiStrings.createBoutique;
  }

  bool get _isChainContext => _isCreatingChain() || widget.chain != null;

  bool _isCreatingChain() {
    return widget.initialChainId == null &&
        widget.boutique == null &&
        widget.chain == null;
  }

  bool _isCreatingBoutique() {
    return !_isCreatingChain() && widget.chain == null;
  }

  bool _eligibleChainSecondary() =>
      shouldShowSecondaryCurrencyForChain(_billingCurrencyController.text);

  Chain? _parentChainForBoutique(BoutiqueProvider provider) {
    final id = _selectedChainId;
    if (id == null || id.isEmpty) return null;
    for (final c in provider.chains) {
      if (c.chainId == id) return c;
    }
    return null;
  }

  bool _eligibleBoutiqueSecondary(BoutiqueProvider provider) {
    final iso = billingIsoForBoutiqueDualEligibility(
      billingFieldText: _billingCurrencyController.text,
      existingNestedBoutique: widget.boutique?.boutique,
      parentChain: _parentChainForBoutique(provider),
    );
    return shouldShowSecondaryCurrencyForBoutique(
      addressCountry: _selectedAddressCountry,
      billingCurrencyIso: iso,
    );
  }

  void _applyDualToChain(Chain chain) {
    applyDualCurrencyToChain(
      chain,
      billingCurrencyIso: _billingCurrencyController.text,
      dualEnabled: _dualCurrencyEnabled,
      secondaryTrimmedUpper:
          _secondaryDisplayCurrencyController.text.trim().toUpperCase(),
    );
  }

  void _applyDualToChainRequest(ChainRequest request) {
    applyDualCurrencyToChainRequest(
      request,
      billingCurrencyIso: _billingCurrencyController.text,
      dualEnabled: _dualCurrencyEnabled,
      secondaryTrimmedUpper:
          _secondaryDisplayCurrencyController.text.trim().toUpperCase(),
    );
  }

  void _applyDualToBoutiquePb(BoutiquePb boutique, BoutiqueProvider provider) {
    final iso = billingIsoForBoutiqueDualEligibility(
      billingFieldText: _billingCurrencyController.text,
      existingNestedBoutique: widget.boutique?.boutique,
      parentChain: _parentChainForBoutique(provider),
    );
    applyDualCurrencyToBoutiquePb(
      boutique,
      eligible: shouldShowSecondaryCurrencyForBoutique(
        addressCountry: _selectedAddressCountry,
        billingCurrencyIso: iso,
      ),
      dualEnabled: _dualCurrencyEnabled,
      secondaryTrimmedUpper:
          _secondaryDisplayCurrencyController.text.trim().toUpperCase(),
    );
  }

  void _applyBusinessRulesFromChain(Chain chain) {
    if (chain.hasBusinessRules()) {
      _applyBusinessRules(chain.businessRules);
    } else {
      _negativeStockGuardEnabled = false;
      _recentTicketEditEnabled = false;
      _recentTicketEditWindowMinutesController.clear();
    }
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

/*   void _setRecentTicketEditEnabled(bool value) {
    setState(() {
      _recentTicketEditEnabled = value;
      if (value && _recentTicketEditWindowMinutesController.text.isEmpty) {
        _recentTicketEditWindowMinutesController.text = '5';
      }
    });
  } */

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

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _error = null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(FlCountryCodePicker countryPicker) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BoutiqueUiStrings.basicInformation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // Name field
            Tooltip(
              message: BoutiqueUiStrings.enterNameTooltip(_isChainContext),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      BoutiqueUiStrings.nameLabelForType(_isChainContext),
                  hintText: _isCreatingChain()
                      ? BoutiqueUiStrings.hintChainNameExample
                      : BoutiqueUiStrings.hintBoutiqueNameExample,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                      _isCreatingChain() ? Icons.account_tree : Icons.store),
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
                    return BoutiqueUiStrings.pleaseEnterName(_isChainContext);
                  }
                  if (value.trim().length < 2) {
                    return BoutiqueUiStrings.nameMinLength;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onChanged: (value) => setState(() {}), // For clear button
              ),
            ),
            if (!_isCreatingChain()) ...[
              const SizedBox(height: 12),
              // Email field for boutiques
              Tooltip(
                message: BoutiqueUiStrings.enterBoutiqueEmailTooltip,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: BoutiqueUiStrings.emailAddressLabel,
                    hintText: BoutiqueUiStrings.enterBoutiqueEmailHint,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // email optional
                    }
                    return EmailValidator.validate(value.trim());
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              Tooltip(
                message: BoutiqueUiStrings.enterPhoneTooltip,
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefix: GestureDetector(
                      onTap: () async {
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
                    labelText: BoutiqueUiStrings.phoneLabel,
                    hintText: BoutiqueUiStrings.enterPhoneHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                    suffixIcon: _phoneController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _phoneController.clear()),
                          ),
                  ),
                  controller: _phoneController,
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
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(height: 12),
              Tooltip(
                message: BoutiqueUiStrings.enterStreetTooltip,
                child: TextFormField(
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return BoutiqueUiStrings.pleaseEnterStreet;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(height: 12),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return BoutiqueUiStrings.pleaseEnterCity;
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
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
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                showCursor: false,
                enableInteractiveSelection: false,
                controller: _addressCountryController,
                onTap: () async {
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
                  // In edit mode, an existing country can be restored by code only
                  // (flag visible) while the localized name may be empty in DB.
                  if (_selectedAddressCountry != null) {
                    return null;
                  }
                  if (value == null || value.trim().isEmpty) {
                    return BoutiqueUiStrings.selectCountryError;
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

  Widget _buildCurrencySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BoutiqueUiStrings.currencySectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            BillingCurrencyField(controller: _billingCurrencyController),
            const SizedBox(height: 12),
            if (_isChainContext)
              SecondaryDisplayCurrencyFields(
                eligible: _eligibleChainSecondary(),
                dualEnabled: _dualCurrencyEnabled,
                onDualChanged: (v) => setState(() => _dualCurrencyEnabled = v),
                secondaryController: _secondaryDisplayCurrencyController,
              )
            else
              Consumer<BoutiqueProvider>(
                builder: (context, provider, _) {
                  return SecondaryDisplayCurrencyFields(
                    eligible: _eligibleBoutiqueSecondary(provider),
                    dualEnabled: _dualCurrencyEnabled,
                    onDualChanged: (v) =>
                        setState(() => _dualCurrencyEnabled = v),
                    secondaryController: _secondaryDisplayCurrencyController,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BoutiqueUiStrings.chainAssignment,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Consumer<BoutiqueProvider>(
              builder: (context, provider, child) {
                if (provider.chains.isEmpty) {
                  return Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              BoutiqueUiStrings.noChainsCreateFirst,
                              style: TextStyle(color: Colors.orange[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedChainId,
                  decoration: const InputDecoration(
                    labelText: BoutiqueUiStrings.selectChainLabel,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_tree),
                  ),
                  items: provider.chains.map((chain) {
                    return DropdownMenuItem(
                      value: chain.chainId,
                      child: Text(BoutiqueUiStrings.chainDropdownSubtitle(
                          chain.name, chain.boutiqueCount)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChainId = value;
                      // Update currency from newly selected chain if creating
                      if (!widget.isEditing) {
                        final chain = provider.chains.firstWhere(
                          (c) => c.chainId == value,
                          orElse: () => Chain(),
                        );
                        if (chain.hasCurrency() &&
                            chain.currency.trim().isNotEmpty) {
                          _billingCurrencyController.text =
                              chain.currency.trim().toUpperCase();
                        }
                        _applyBusinessRulesFromChain(chain);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return BoutiqueUiStrings.pleaseSelectChain;
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
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
            // const Divider(height: 16),
           /*  SwitchListTile(
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

// Complicating things
/*   Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: Text(_isActive
                  ? 'Boutique is currently active and operational'
                  : 'Boutique is inactive and not operational'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: Icon(
                _isActive ? Icons.check_circle : Icons.cancel,
                color: _isActive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  } */

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isCreating ? null : _handleSubmit,
            icon: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(widget.isEditing ? Icons.save : Icons.add),
            label: Text(_isCreating
                ? BoutiqueUiStrings.creating
                : widget.isEditing
                    ? BoutiqueUiStrings.saveChanges
                    : BoutiqueUiStrings.createType(_isChainContext)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
            child: const Text(BoutiqueUiStrings.cancel),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(BoutiqueUiStrings.deleteTypeTitle(_isChainContext)),
        content: Text(
          _isChainContext
              ? BoutiqueUiStrings.deleteChainBody()
              : BoutiqueUiStrings.deleteBoutiqueBody(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(BoutiqueUiStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(BoutiqueUiStrings.deleteAction),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final provider = context.read<BoutiqueProvider>();
      bool success = false;

      if (_isCreatingChain() || widget.chain != null) {
        success = await _handleChainSubmit(provider);
      } else {
        success = await _handleBoutiqueSubmit(provider);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(BoutiqueUiStrings.submitSuccess(
                  _isChainContext, widget.isEditing)),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _error = provider.error ??
              BoutiqueUiStrings.submitFailed(_isChainContext, widget.isEditing);
        });
      }
    } on GrpcError catch (e) {
      setState(() {
        _error = '${e.code} ${e.message}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<bool> _handleChainSubmit(BoutiqueProvider provider) async {
    final name = _nameController.text.trim();
    final cur = _billingCurrencyController.text.trim().toUpperCase();

    final chain = Chain()..name = name;
    if (cur.isNotEmpty) {
      chain.currency = cur;
    } else {
      chain.clearCurrency();
    }
    _applyDualToChain(chain);
    chain.businessRules = _buildBusinessRules();

    if (widget.isEditing && widget.chain != null) {
      final request = ChainRequest()
        ..chainId = widget.chain!.chainId
        ..name = name;
      if (cur.isNotEmpty) {
        request.currency = cur;
      } else {
        request.clearCurrency();
      }
      _applyDualToChainRequest(request);
      request.businessRules = _buildBusinessRules();
      return await provider.updateChain(request);
    }
    return await provider.createChain(chain);
  }

  Future<bool> _handleBoutiqueSubmit(BoutiqueProvider provider) async {
    if (_selectedChainId == null) {
      setState(() => _error = BoutiqueUiStrings.pleaseSelectChainError);
      return false;
    }

    // Create address
    final address = Address()
      ..street = _addressStreetController.text.trim()
      ..city = _addressCityController.text.trim()
      ..code = _addressCodeController.text.trim();

    // Add country if selected
    if (_selectedAddressCountry != null) {
      address.country = Country()
        ..code2Letters = _selectedAddressCountry!.code
        ..namel10n = _addressCountryController.text.trim();
    }

    // Create phone with country code
    final phone = Phone()..number = _phoneController.text.trim();

    if (_selectedPhoneCountryCode.isNotEmpty) {
      phone.countryCode =
          int.tryParse(_selectedPhoneCountryCode.replaceAll('+', '')) ?? 33;
    }

    // Build boutique: merge existing protobuf on edit (matches BoutiqueFormWidget)
    // so optional fields (e.g. dual currency) are not lost on the wire.
    // We use mergeFromMessage to ensure we don't overwrite fields that are not
    // explicitly handled by this form (like technical or internal fields).
    final boutique = widget.isEditing && widget.boutique != null
        ? (BoutiquePb()..mergeFromMessage(widget.boutique!.boutique))
        : BoutiquePb();

    boutique
      ..name = _nameController.text.trim()
      ..addressFull = address
      ..phone = phone;

    // Store email in the mail field
    if (_emailController.text.trim().isNotEmpty) {
      boutique.mail = _emailController.text.trim();
    }

    final currency = _billingCurrencyController.text.trim().toUpperCase();
    if (currency.isNotEmpty) {
      boutique.currency = currency;
    } else {
      boutique.clearCurrency();
    }

    _applyDualToBoutiquePb(boutique, provider);
    boutique.businessRules = _buildBusinessRules();

    if (!widget.isEditing) {
      boutique.creationDate = DateTime.now().toIso8601String();
    }

    if (widget.isEditing && widget.boutique != null) {
      // Update existing boutique
      return await provider.updateBoutique(
          _selectedChainId!, widget.boutique!.boutiqueId, boutique);
    } else {
      // Create new boutique
      return await provider.createBoutique(_selectedChainId!, boutique);
    }
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final provider = context.read<BoutiqueProvider>();
      bool success = false;

      if (widget.chain != null) {
        success = await provider.deleteChain(widget.chain!.chainId);
      } else if (widget.boutique != null) {
        success = await provider.deleteBoutique(
            widget.boutique!.chainId, widget.boutique!.boutiqueId);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(BoutiqueUiStrings.deleteSuccess(_isChainContext)),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _error =
              provider.error ?? BoutiqueUiStrings.deleteFailed(_isChainContext);
        });
      }
    } on GrpcError catch (e) {
      setState(() {
        _error = '${e.code} ${e.message}';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
