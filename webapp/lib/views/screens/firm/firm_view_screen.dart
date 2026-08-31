import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/core/services/firm_service.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/screens/firm/firm_overview_body.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

import '../../../core/constants/dimens.dart';
import '../../../core/theme/theme_extensions/app_button_theme.dart';
import '../../../core/theme/theme_extensions/app_color_scheme.dart';

class FirmListScreen extends StatefulWidget {
  const FirmListScreen({super.key});

  @override
  State<FirmListScreen> createState() => _FirmListScreenState();
}

class _FirmListScreenState extends State<FirmListScreen> {
  final FirmService _firmService = FirmService();
  Firm? currentFirm;
  String? errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserFirm();
  }

  Future<void> _loadUserFirm() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });
    try {
      final firm = await _firmService.readOneFirm();
      if (!mounted) return;
      setState(() {
        currentFirm = firm;
        errorMessage = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final lang = Lang.of(context);
      if (error is GrpcError && error.code == 7) {
        setState(() {
          errorMessage = lang.firmErrorCreateHint;
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = lang.firmErrorUnexpected;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;
    final lang = Lang.of(context);

    return PortalMasterLayout(
      body: ListView(
        key: const Key('firmScreen'),
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.firmPageTitle,
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
                    title: lang.firmCardDescription,
                  ),
                  CardBody(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: kDefaultPadding * 2.0,
                            ),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (errorMessage != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 6.0,
                                ),
                                backgroundColor: appColorScheme.error,
                                label: Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: kDefaultPadding),
                              ElevatedButton.icon(
                                key: const Key('createFirmCtaButton'),
                                style: themeData
                                    .extension<AppButtonTheme>()!
                                    .successElevated,
                                onPressed: () => GoRouter.of(context)
                                    .go(RouteUri.createFirm),
                                icon: const Icon(Icons.add_business_outlined),
                                label: Text(lang.createEnterprisePageTitle),
                              ),
                            ],
                          )
                        else if (currentFirm != null)
                          FirmOverviewBody(firm: currentFirm!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
