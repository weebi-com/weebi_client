import 'package:design_weebi/design_weebi.dart' show IconsWeebi;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/theme/theme_extensions/app_color_scheme.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
// import 'package:web_admin/core/theme/theme_extensions/app_data_table_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dataTableHorizontalScrollController = ScrollController();

  @override
  void dispose() {
    _dataTableHorizontalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appColorScheme = Theme.of(context).extension<AppColorScheme>()!;
    // final appDataTableTheme = Theme.of(context).extension<AppDataTableTheme>()!;
    final size = MediaQuery.of(context).size;

    final summaryCardCrossAxisCount = (size.width >= kScreenWidthLg ? 4 : 2);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          const SizedBox(height: 8),
          /* ListTile(
            leading: const Icon(Icons.search),
            title: TextField(
              controller: TextEditingController(
                  text: 'recherche dynamique des tuiles ci-dessous'),
            ),
          ), */
          //Text(
          //  lang.dashboard,
          //  style: themeData.textTheme.headlineMedium,
          //),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final summaryCardWidth = ((constraints.maxWidth -
                        (kDefaultPadding * (summaryCardCrossAxisCount - 1))) /
                    summaryCardCrossAxisCount);
                return Wrap(
                  direction: Axis.horizontal,
                  spacing: kDefaultPadding,
                  runSpacing: kDefaultPadding,
                  children: [
                    _HoverableTile(
                      onTap: () => GoRouter.of(context).go(RouteUri.firmDetail),
                      child: SummaryCard(
                        title: lang.pendingIssues(2),
                        value: lang.dashboardCardMyFirmValue,
                        icon: Icons.business,
                        backgroundColor: Colors.lightBlue,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ),
                    _HoverableTile(
                      onTap: () =>
                          GoRouter.of(context).go(RouteUri.listBoutique),
                      child: SummaryCard(
                        title: lang.pendingIssues(2),
                        value: lang.dashboardCardBoutiquesValue,
                        icon: Icons.store,
                        backgroundColor: Colors.blue,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ),
                    _HoverableTile(
                      onTap: () => GoRouter.of(context).go(RouteUri.listUser),
                      child: SummaryCard(
                        title: lang.newUsers(2),
                        value: lang.dashboardCardUsersValue,
                        icon: Icons.group_add_rounded,
                        backgroundColor: appColorScheme.warning,
                        textColor: appColorScheme.buttonTextBlack,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ),
                    _HoverableTile(
                      onTap: () =>
                          GoRouter.of(context).go(RouteUri.listAccess),
                      child: SummaryCard(
                        title: lang.dashboardCardUserAccess,
                        value: lang.dashboardCardUserAccess,
                        icon: Icons.admin_panel_settings_rounded,
                        backgroundColor: Colors.purple,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ),
                    _HoverableTile(
                      onTap: () =>
                          GoRouter.of(context).go(RouteUri.listDevice),
                      child: SummaryCard(
                        title: lang.dashboardCardDevicesValue,
                        value: lang.dashboardCardDevicesValue,
                        icon: Icons.devices_rounded,
                        backgroundColor: Colors.teal,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ),
                    _HoverableTile(
                      onTap: () =>
                          GoRouter.of(context).go(RouteUri.ticketsOverview),
                      child: SummaryCard(
                        title: lang.dashboardCardTicketsToday,
                        value: lang.dashboardCardTicketsShort,
                        icon: IconsWeebi.ticketsIconData,
                        backgroundColor: Colors.grey,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ),
                    _HoverableTile(
                      onTap: () =>
                          GoRouter.of(context).go(RouteUri.billing),
                      child: SummaryCard(
                        title: lang.menuBilling,
                        value: lang.menuBilling,
                        icon: Icons.credit_card_rounded,
                        backgroundColor: Colors.indigo,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ),

                    // NOT READY YET
/*                     InkWell(
                      child: SummaryCard(
                        title: lang.newOrders(2),
                        value: 'Contacts',
                        icon: Icons.person,
                        backgroundColor: Colors.blue,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      onTap: () {
                        final chainId = JsonWebToken.parse(
                                context.read<UserDataProvider>().accessToken)
                            .permissions
                            .firmId; // first chainId == firmId, making it simple
                        GoRouter.of(context)
                            .go(RouteUri.contacts, extra: chainId);
                      },
                    ), */
/*                     GestureDetector(
                      child: SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Boutiques',
                        icon: Icons.store,
                        backgroundColor: Colors.teal,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      onTap: () {
                        GoRouter.of(context).go(RouteUri.listBoutique);
                      },
                    ), */
                    // mockup ok, now no point displaying until functionnal
                    if (2 + 2 == 5) ...[
                      SummaryCard(
                        title: lang.newOrders(2),
                        value: 'Vente',
                        icon: Icons.point_of_sale,
                        backgroundColor: appColorScheme.info,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.newOrders(2),
                        value: 'Vente hors-catalogue',
                        icon: Icons.point_of_sale,
                        backgroundColor: appColorScheme.info,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Achat',
                        icon: Icons.shopping_cart_rounded,
                        backgroundColor: appColorScheme.error,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Achat/dépense hors catalogue',
                        icon: Icons.shopping_cart_rounded,
                        backgroundColor: appColorScheme.error,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Mouvement de stock',
                        icon: Icons.warehouse,
                        backgroundColor: appColorScheme.error,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Faire un inventaire',
                        icon: Icons.warehouse,
                        backgroundColor: appColorScheme.success,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.newOrders(2),
                        value: 'Articles',
                        icon: Icons.widgets,
                        backgroundColor: Colors.orange,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Articles Import/Export',
                        icon: Icons.file_download,
                        backgroundColor: Colors.orange,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Articles photos Import/Export',
                        icon: Icons.image,
                        backgroundColor: Colors.orange,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),

                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Contacts Import/Export',
                        icon: Icons.file_download,
                        backgroundColor: Colors.blue,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Tickets',
                        icon: IconsWeebi.ticketsIconData,
                        backgroundColor: Colors.grey,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Tickets Import/Export',
                        icon: Icons.file_download,
                        backgroundColor: Colors.grey,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.todaySales,
                        value: 'Stats',
                        icon: Icons.ssid_chart_rounded,
                        backgroundColor: appColorScheme.success,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Taxes',
                        icon: Icons.cut,
                        backgroundColor: Colors.red[800]!,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      const Divider(),

                      /// Accessoires
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Imprimante',
                        icon: Icons.print,
                        backgroundColor: Colors.lightBlue,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                      SummaryCard(
                        title: lang.pendingIssues(2),
                        value: 'Lecteur de code barre',
                        icon: Icons.barcode_reader,
                        backgroundColor: Colors.lightBlue,
                        textColor: themeData.colorScheme.onPrimary,
                        iconColor: Colors.black12,
                        width: summaryCardWidth,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps a tile with hover feedback: pointer cursor and subtle scale on hover.
class _HoverableTile extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _HoverableTile({
    required this.onTap,
    required this.child,
  });

  @override
  State<_HoverableTile> createState() => _HoverableTileState();
}

class _HoverableTileState extends State<_HoverableTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double width;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.width,
  });

  static const double _minHeight = 118.0;
  static const double _compactTileBreakpoint = 200.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconSize = width < _compactTileBreakpoint ? 64.0 : 80.0;
    final tileHeight = width < _compactTileBreakpoint ? 128.0 : _minHeight;

    // Use almost full card width so phrases like "Mes boutiques" stay on one
    // line on phones; icon sits in the corner and rarely overlaps bottom text.
    const horizontalInset = kDefaultPadding * 0.5;
    final textStyle = _valueStyle(textTheme, width);

    return SizedBox(
      height: tileHeight,
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: backgroundColor,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: kDefaultPadding * 0.25,
              right: horizontalInset * 0.75,
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
            Positioned(
              left: horizontalInset,
              right: horizontalInset,
              bottom: kDefaultPadding * 0.4,
              child: Text(
                value,
                style: textStyle,
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Smaller type on narrow dashboard tiles (typical two-column phone layout).
  TextStyle _valueStyle(TextTheme textTheme, double tileWidth) {
    final base = tileWidth < 170
        ? textTheme.titleMedium
        : tileWidth < 260
            ? textTheme.titleLarge
            : textTheme.headlineSmall;
    return base!.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
  }
}
