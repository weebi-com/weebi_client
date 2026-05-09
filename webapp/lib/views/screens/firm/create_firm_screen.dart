import 'package:boutiques_weebi/currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/utils/app_dialogs.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

import '../../../core/constants/dimens.dart';
import '../../../core/services/firm_service.dart';
import '../../../core/theme/theme_extensions/app_button_theme.dart';

class CreateFirmScreen extends StatefulWidget {
  const CreateFirmScreen({super.key});

  @override
  State<CreateFirmScreen> createState() => _CreateFirmScreenState();
}

class _CreateFirmScreenState extends State<CreateFirmScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();
  bool _isLoading = false;

  final FirmService _firmService = FirmService();

  void _doSubmit(BuildContext context) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _firmService.createFirm(
          name: _formData.name,
          defaultCurrency: _formData.defaultCurrency,
        );
        if (!context.mounted) return;
        final lang = Lang.of(context);
        setState(() {
          _isLoading = false;
        });
        AppDialog.show(
          context: context,
          dialogType: AppDialogType.success,
          title: lang.createEnterpriseSuccessTitle(response.firm.name),
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () => (GoRouter.of(context).go(RouteUri.firmDetail)),
        );
      } catch (e) {
        if (!context.mounted) return;
        final lang = Lang.of(context);
        setState(() {
          _isLoading = false;
        });
        AppDialog.show(
          context: context,
          dialogType: AppDialogType.error,
          title: lang.createEnterprisePageTitle,
          desc: '${lang.createEnterpriseErrorPrefix}${e.toString()}',
          btnOkText: 'OK',
          btnOkOnPress: () {},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final pageTitle = lang.createEnterprisePageTitle;

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.crud,
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            pageTitle,
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(
                    title: pageTitle,
                  ),
                  CardBody(
                    child: _content(context, lang),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, Lang lang) {
    final themeData = Theme.of(context);

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Nom',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.name,
              validator: FormBuilderValidators.required(
                  errorText: 'Le nom est requis'),
              onSaved: (value) => {_formData.name = value ?? ''},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: OutlinedButton.icon(
              onPressed: () {
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  onSelect: (Currency c) {
                    setState(() {
                      _formData.defaultCurrency = c.code;
                    });
                  },
                );
              },
              icon: const Icon(Icons.monetization_on_outlined),
              label: Text(
                _formData.defaultCurrency == null
                    ? 'Devise par défaut (EUR plateforme si non choisi)'
                    : 'Devise : ${_formData.defaultCurrency}',
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBackButton(context, themeData, lang),
              const Spacer(),
              _buildSubmitButton(context, themeData, lang),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(
      BuildContext context, ThemeData themeData, Lang lang) {
    return SizedBox(
      height: 40.0,
      child: ElevatedButton(
        style: themeData.extension<AppButtonTheme>()!.secondaryElevated,
        onPressed: () => GoRouter.of(context).go(RouteUri.firmDetail),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
              child: Icon(
                Icons.arrow_circle_left_outlined,
                size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
              ),
            ),
            Text(lang.crudBack),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, ThemeData themeData, Lang lang) {
    return SizedBox(
      height: 40.0,
      child: ElevatedButton(
        style: themeData.extension<AppButtonTheme>()!.successElevated,
        onPressed: _isLoading ? null : () => _doSubmit(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(right: kDefaultPadding * 0.5),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                ),
              ),
            Text(lang.submit),
          ],
        ),
      ),
    );
  }
}

class FormData {
  String id = '';
  String name = '';
  /// ISO 4217; null = server uses [FIRMS_DEFAULT_CURRENCY] / EUR.
  String? defaultCurrency;
}
