import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show UserPublic;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_weebi/users_weebi.dart' show DynamicBody;
import 'package:web_admin/core/services/user_service.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/user_data_provider.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/utils/profile_image_provider.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

import '../../core/constants/dimens.dart';
import '../../core/constants/values.dart';
import '../../core/theme/theme_extensions/app_button_theme.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  Future<bool>? _future;

  Future<bool> _getDataAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    // _formData.firstName = sharedPref.getString(StorageKeys.firstname)!;
    // _formData.lastName = sharedPref.getString(StorageKeys.lastname)!;
    _formData.mail = sharedPref.getString(SharePrefKeys.mail)!;
    _formData.userProfileImageUrl = sharedPref.getString(SharePrefKeys.userProfileImageUrl)!;

    return true;
  }

  void _doSave(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final lang = Lang.of(context);

      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: lang.recordSavedSuccessfully,
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {},
      );

      dialog.show();
    }
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.first.bytes == null) return;

    final bytes = result.files.first.bytes!;
    final extension = result.files.first.extension ?? 'jpeg';
    final mimeType = switch (extension.toLowerCase()) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';

    _formData.userProfileImageUrl = dataUrl;

    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(SharePrefKeys.userProfileImageUrl, dataUrl);

    await context.read<UserDataProvider>().setUserDataAsync(
          userProfileImageUrl: dataUrl,
        );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.myProfile,
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: CardBody(
                    child: FutureBuilder<bool>(
                      initialData: null,
                      future: (_future ??= _getDataAsync()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          if (snapshot.hasData && snapshot.data!) {
                            return _content(context);
                          }
                        } else if (snapshot.hasData && snapshot.data!) {
                          return _content(context);
                        }

                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                          child: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: CircularProgressIndicator(
                              backgroundColor: themeData.scaffoldBackgroundColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      profileImageProvider(_formData.userProfileImageUrl),
                  radius: 60.0,
                  onBackgroundImageError: (_, __) {},
                  child: _formData.userProfileImageUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 60.0,
                          color: themeData.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: SizedBox(
                    height: 40.0,
                    width: 40.0,
                    child: Tooltip(
                      message: lang.changeProfilePhoto,
                      child: ElevatedButton(
                        onPressed: () => _pickProfileImage(context),
                        style: themeData.extension<AppButtonTheme>()!.secondaryElevated.copyWith(
                          shape: WidgetStateProperty.all(const CircleBorder()),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Row(
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
          //       child: FormBuilderTextField(
          //         name: 'firstName',
          //         decoration: const InputDecoration(
          //           labelText: 'Nom',
          //           hintText: 'Nom',
          //           border: OutlineInputBorder(),
          //           floatingLabelBehavior: FloatingLabelBehavior.always,
          //         ),
          //         initialValue: _formData.firstName,
          //         keyboardType: TextInputType.text,
          //         validator: FormBuilderValidators.required(),
          //         onSaved: (value) => (_formData.firstName = value ?? ''),
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
          //       child: FormBuilderTextField(
          //         name: 'lastName',
          //         decoration: const InputDecoration(
          //           labelText: 'Prénom',
          //           hintText: 'Prénom',
          //           border: OutlineInputBorder(),
          //           floatingLabelBehavior: FloatingLabelBehavior.always,
          //         ),
          //         initialValue: _formData.lastName,
          //         keyboardType: TextInputType.text,
          //         validator: FormBuilderValidators.required(),
          //         onSaved: (value) => (_formData.lastName = value ?? ''),
          //       ),
          //     ),
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(
                labelText: lang.email,
                hintText: lang.email,
                border: const OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.mail,
              keyboardType: TextInputType.emailAddress,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.mail = value ?? ''),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40.0,
              child: ElevatedButton(
                style: themeData.extension<AppButtonTheme>()!.successElevated,
                onPressed: () => _doSave(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                      child: Icon(
                        Icons.save_rounded,
                        size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                      ),
                    ),
                    Text(lang.save),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: kDefaultPadding * 2),
          _buildProfileDetails(context),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    final userId = context.read<PermissionProvider>().userId;
    if (userId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<UserPublic?>(
      future: UserService().readOneUser(userId: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        return DynamicBody<UserPublic>(
          pbObject: snapshot.data!,
          skipFieldNames: const ['permissions'],
        );
      },
    );
  }
}

class FormData {
  // String firstName = '';
  // String lastName = '';
  String userProfileImageUrl = '';
  String mail = '';
}