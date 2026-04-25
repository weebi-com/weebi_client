import 'package:flutter/material.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/services/firm_service.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'firm_dynamic_body.dart';

import '../../../core/constants/dimens.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserFirm();
  }

  Future<void> _loadUserFirm() async {
    try {
      final firm = await _firmService.readOneFirm();
      setState(() {
        currentFirm = firm;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      final lang = Lang.of(context);
      if (error is GrpcError && error.code == 7) {
        setState(() {
          errorMessage = lang.firmErrorCreateHint;
        });
      } else {
        setState(() {
          errorMessage = lang.firmErrorUnexpected;
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: kDefaultPadding * 2.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: kDefaultPadding),
                                  child: Chip(
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
                                )
                              else if (currentFirm != null)
                                FirmDynamicBody(firm: currentFirm!),
                            ],
                          ),
                        ),
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
