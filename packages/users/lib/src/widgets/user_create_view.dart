// Flutter imports:
import 'package:auth_weebi/auth_weebi.dart' show JsonWebToken;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:fl_country_code_picker_weebi/fl_country_code_picker.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/utils.dart' show RegExpWeebi;
import 'package:provider/provider.dart';
import 'package:users_weebi/weebi_users.dart' show AccessTokenProvider;

// Project imports:
import '../firm_license_seat_utils.dart';
import '../l10n/license_ui_strings.dart';
import '../l10n/user_ui_strings.dart';
import '../providers/user_provider.dart';
import 'elegant_permissions_widget.dart';
import 'phone_field_prefix_icon.dart';

// user will need to sign up after this step
// and will then be linked to boss' firm
class UserCreateView extends StatefulWidget {
  const UserCreateView({
    super.key,
    this.showFloatingActionButton = true,
    this.onUserCreated,
    this.showLicenseReminder = true,
    this.firmLicenses,
  });

  /// Whether to show the floating action button for saving
  /// Set to false when used inside a custom scaffold
  final bool showFloatingActionButton;

  /// When true (default), shows a short notice that new users need an active
  /// license seat. Set false only if your app shows this elsewhere.
  final bool showLicenseReminder;

  /// When provided (e.g. from [readLicenses]), shows seat usage for active
  /// licenses so admins see capacity at a glance.
  final Iterable<License>? firmLicenses;

  /// Optional callback when user is successfully created
  /// This allows the client app to take additional actions like:
  /// - Navigate to access management screen
  /// - Show additional setup dialogs
  /// - Update parent state
  ///
  /// The callback receives both the created user and a BuildContext
  /// that has Navigator access for navigation.
  final void Function(BuildContext context, UserPublic createdUser)?
      onUserCreated;

  @override
  State<UserCreateView> createState() => _UserCreateViewState();
}

class _UserCreateViewState extends State<UserCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  /// Public method to trigger form submission
  /// Can be called from parent widgets
  Future<void> submitForm() async {
    await _saveAndCreateUser();
  }

  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Country code for phone
  CountryCode? _countryCodePhone;

  // User permissions
  UserPermissions _userPermissions = UserPermissions.create();

  // Loading and error states
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  void _initializeDefaults() {
    // Set default country code to Sénégal
    _countryCodePhone = CountryCode.fromDialCode('+221');

    // Initialize with minimal permissions (principle of least privilege)
    _userPermissions = UserPermissions.create()
      ..firmId = _getFirmIdFromToken()
      ..articleRights = ArticleRights(rights: [Right.read])
      ..contactRights = ContactRights(rights: [Right.read])
      ..ticketRights = TicketRights(rights: [Right.read])
      ..boutiqueRights = BoutiqueRights.create()
      ..chainRights = ChainRights.create()
      ..firmRights = FirmRights.create()
      ..userManagementRights = UserManagementRights.create()
      ..billingRights = BillingRights.create()
      ..boolRights = BoolRights.create()
      ..limitedAccess = (AccessLimited.create());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Extract firmId from bearer token via provider
  String _getFirmIdFromToken() {
    try {
      final authProvider = context.read<AccessTokenProvider>();
      final jwt = JsonWebToken.parse(authProvider.accessToken);
      return jwt.permissions.firmId;
    } catch (e) {
      throw Exception(UserUiStrings.couldNotExtractFirmId(e));
    }
  }

  Future<void> _saveAndCreateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      _formKey.currentState!.save();

      // Create the new user (backend will generate the user ID)
      final newUserRequest = UserPublic.create()
        ..firstname = _firstNameController.text.trim()
        ..lastname = _lastNameController.text.trim()
        ..mail = _emailController.text.trim()
        ..phone = (Phone.create()
          ..countryCode =
              int.tryParse(_countryCodePhone?.dialCode.substring(1) ?? '33') ??
                  33
          ..number = _phoneController.text.trim())
        ..permissions = _userPermissions;

      final userProvider = context.read<UserProvider>();
      final createdUser = await userProvider.createUser(newUserRequest);

      // Show success message and offer to set up access
      if (mounted) {
        // If callback is provided, show dialog to set up access
        // Don't pop yet - let the dialog handle navigation
        if (widget.onUserCreated != null) {
          _showAccessSetupDialog(createdUser);
        } else {
          // No callback - show default success and pop immediately
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(UserUiStrings.userCreatedSuccess(
                        createdUser.firstname, createdUser.lastname)),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: UserUiStrings.ok,
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } on GrpcError catch (e) {
      final errorMsg = '${e.code} ${e.message}';
      setState(() {
        _error = errorMsg;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(UserUiStrings.errorCreatingUser(errorMsg))),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(UserUiStrings.errorCreatingUser('$e'))),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Widget _buildLicenseReminderBanner() {
    final licenses = widget.firmLicenses;
    final FirmLicenseSeatSummary? summary =
        licenses != null ? summarizeFirmLicenseSeats(licenses) : null;

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.blue[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    LicenseUiStrings.createUserLicenseBannerBody,
                    style: TextStyle(
                      color: Colors.blue[900],
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            if (summary != null) ...[
              const SizedBox(height: 12),
              Text(
                summary.totalCapacity > 0
                    ? LicenseUiStrings.createUserSeatsSummary(
                        summary.activeAssignedSeats,
                        summary.totalCapacity,
                      )
                    : LicenseUiStrings.createUserNoValidLicenseSummary,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Check if form has been modified
    if (_firstNameController.text.isNotEmpty ||
        _lastNameController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty) {
      return await _showDiscardDialog() ?? false;
    }
    return true;
  }

  Future<bool?> _showDiscardDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(UserUiStrings.discardChangesTitle),
        content: const Text(UserUiStrings.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(UserUiStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(UserUiStrings.discard),
          ),
        ],
      ),
    );
  }

  void _showAccessSetupDialog(UserPublic createdUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(LicenseUiStrings.userCreatedSuccessTitle),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${createdUser.firstname} ${createdUser.lastname} a été créé.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        LicenseUiStrings.createUserPostCreateLicenseWarning,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[900],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                LicenseUiStrings.userCreatedSetUpAccessPrompt,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // Pop UserCreateView
                // Show reminder message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      LicenseUiStrings.userCreatedLaterSnackbar,
                    ),
                    backgroundColor: Colors.orange[700],
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              child: const Text(LicenseUiStrings.userCreatedLater),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Don't pop UserCreateView - let callback handle navigation
                // Use post-frame callback to ensure dialog is fully closed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    widget.onUserCreated?.call(context, createdUser);
                  }
                });
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(LicenseUiStrings.userCreatedSetUpNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final countryPicker = const FlCountryCodePicker();

    Widget content = WillPopScope(
      onWillPop: _onWillPop,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error indicator (moved from AppBar)
              if (_error != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(UserUiStrings.errorDialogTitle),
                                content: Text(_error!),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(UserUiStrings.ok),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(UserUiStrings.details),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_error != null) const SizedBox(height: 16),

              if (widget.showLicenseReminder) ...[
                _buildLicenseReminderBanner(),
                const SizedBox(height: 16),
              ],

              // Basic Information Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Name Field
                      TextFormField(
                        controller: _firstNameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: UserUiStrings.labelFirstName,
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return UserUiStrings.firstNameRequired;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Last Name Field
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: UserUiStrings.labelLastName,
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return UserUiStrings.lastNameRequired;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: UserUiStrings.labelEmail,
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return UserUiStrings.emailRequired;
                          }
                          if (RegExpWeebi.mailFormat.hasMatch(value) == false) {
                            return UserUiStrings.emailInvalid;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Phone Field with Country Code Picker
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: UserUiStrings.labelPhone,
                          prefixIcon: PhoneFieldPrefixIcon(
                            dialCode:
                                _countryCodePhone?.dialCode ?? '+221',
                            onPickDialCode: () async {
                              final code = await countryPicker.showPicker(
                                context: context,
                                pickerMaxHeight: 800,
                              );
                              if (code != null) {
                                setState(() {
                                  _countryCodePhone = code;
                                });
                              }
                            },
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minHeight: 48,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length < 8) {
                              return UserUiStrings.phoneTooShort;
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Permissions Section
              Card(
                child:
                    // Permission Editor
                    ElegantPermissionsWidget(
                  permissions: _userPermissions,
                  onPermissionsChanged: (updatedPermissions) {
                    setState(() {
                      _userPermissions = updatedPermissions;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Save button (shown when FAB is disabled)
              if (!widget.showFloatingActionButton)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isCreating ? null : _saveAndCreateUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCreating ? Colors.grey : Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isCreating
                        ? UserUiStrings.creating
                        : UserUiStrings.createUser),
                  ),
                ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );

    // If FAB should be shown, wrap in Scaffold
    if (widget.showFloatingActionButton) {
      return Scaffold(
        body: content,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isCreating ? null : _saveAndCreateUser,
          backgroundColor: _isCreating ? Colors.grey : Colors.green[600],
          icon: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(_isCreating
              ? UserUiStrings.creating
              : UserUiStrings.createUser),
        ),
      );
    }

    // Otherwise, return just the content
    return content;
  }
}
