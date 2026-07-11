import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' as pb;
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:auth_weebi/auth_weebi.dart';
import 'package:web_admin/providers/current_user_provider.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Future<pb.FinancialChartResponse>? _chartFuture;
  pb.FinancialChartMetric _selectedMetric =
      pb.FinancialChartMetric.CASHFLOW_INCOME;
  pb.ChartTimePeriod _selectedPeriod = pb.ChartTimePeriod.DAY;
  List<String> _selectedBoutiqueIds = [];
  bool _isStacked = false;
  String _lastFirmId = '';
  int _lastBoutiquesCount = 0;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // Cache for the last successful chart request and response
  pb.FinancialChartRequest? _lastRequest;
  pb.FinancialChartResponse? _cachedResponse;

  @override
  void initState() {
    super.initState();
    _fetchChart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final boutiqueProvider = context.watch<BoutiqueProvider>();
    final userPerms = context.watch<PermissionProvider>().userPermissions;

    if (boutiqueProvider.allBoutiques.isEmpty && !boutiqueProvider.isLoading) {
      // Use a microtask to avoid calling loadChains during build
      Future.microtask(() => boutiqueProvider.loadChains());
    }

    final boutiquesChanged =
        boutiqueProvider.allBoutiques.length != _lastBoutiquesCount;
    final firmChanged = userPerms.firmId != _lastFirmId;

    if (userPerms.firmId.isNotEmpty && (firmChanged || boutiquesChanged)) {
      _lastFirmId = userPerms.firmId;
      _lastBoutiquesCount = boutiqueProvider.allBoutiques.length;
      // Trigger fetch if firm or boutique list changed
      _fetchChart();
    }
  }

  void _fetchChart() {
    final statsClient =
        context.read<StatsServiceClientProvider>().statsServiceClient;
    final userPerms = context.read<PermissionProvider>().userPermissions;
    final boutiqueProvider = context.read<BoutiqueProvider>();

    if (userPerms.firmId.isEmpty) return;

    // Use beginning of day for start and end of day for end
    final start = DateTime(_selectedDateRange.start.year,
        _selectedDateRange.start.month, _selectedDateRange.start.day);
    final end = DateTime(_selectedDateRange.end.year,
        _selectedDateRange.end.month, _selectedDateRange.end.day, 23, 59, 59);

    final List<String> boutiqueIds;
    if (_selectedBoutiqueIds.isNotEmpty) {
      boutiqueIds = _selectedBoutiqueIds;
    } else {
      final allBoutiqueIds =
          boutiqueProvider.allBoutiques.map((b) => b.boutiqueId).toList();
      if (allBoutiqueIds.isNotEmpty) {
        boutiqueIds = allBoutiqueIds;
      } else {
        boutiqueIds = userPerms.fullAccess.hasFullAccess
            ? []
            : userPerms.limitedAccess.boutiqueIds.ids;
      }
    }

    final request = pb.FinancialChartRequest()
      ..firmId = userPerms.firmId
      ..boutiqueIds.addAll(boutiqueIds)
      ..start = pb.Timestamp.fromDateTime(start)
      ..end = pb.Timestamp.fromDateTime(end)
      ..timePeriod = _selectedPeriod
      ..metric = _selectedMetric
      ..stackedByBoutique = _isStacked;

    // Check if request is identical to the last one
    if (_lastRequest != null && _requestEquals(_lastRequest!, request)) {
      if (_cachedResponse != null) {
        setState(() {
          _chartFuture = Future.value(_cachedResponse);
        });
        return;
      }
    }

    _lastRequest = request;

    setState(() {
      _chartFuture = statsClient.getFinancialChart(request).then((response) {
        _cachedResponse = response;
        return response;
      });
    });
  }

  bool _requestEquals(pb.FinancialChartRequest a, pb.FinancialChartRequest b) {
    if (a.firmId != b.firmId) return false;
    if (a.metric != b.metric) return false;
    if (a.timePeriod != b.timePeriod) return false;
    if (a.stackedByBoutique != b.stackedByBoutique) return false;
    if (a.start.seconds != b.start.seconds) return false;
    if (a.end.seconds != b.end.seconds) return false;
    if (a.boutiqueIds.length != b.boutiqueIds.length) return false;
    for (int i = 0; i < a.boutiqueIds.length; i++) {
      if (a.boutiqueIds[i] != b.boutiqueIds[i]) return false;
    }
    return true;
  }

  String _getMetricLabel(pb.FinancialChartMetric m, Lang lang) {
    return switch (m) {
      pb.FinancialChartMetric.CASHFLOW_INCOME => lang.statsMetricCashflowIncome,
      pb.FinancialChartMetric.CASHFLOW_SPENDING =>
        lang.statsMetricCashflowSpending,
      pb.FinancialChartMetric.ALL_INCOME => lang.statsMetricAllIncome,
      pb.FinancialChartMetric.ALL_SPENDING => lang.statsMetricAllSpending,
      _ => m.name,
    };
  }

  IconData _getMetricIcon(pb.FinancialChartMetric m) {
    return switch (m) {
      pb.FinancialChartMetric.CASHFLOW_INCOME => Icons.trending_up,
      pb.FinancialChartMetric.CASHFLOW_SPENDING => Icons.trending_down,
      pb.FinancialChartMetric.ALL_INCOME => Icons.account_balance_wallet,
      pb.FinancialChartMetric.ALL_SPENDING => Icons.shopping_cart,
      _ => Icons.bar_chart,
    };
  }

  String _getPeriodLabel(pb.ChartTimePeriod p, Lang lang) {
    return switch (p) {
      pb.ChartTimePeriod.DAY => lang.statsPeriodDay,
      pb.ChartTimePeriod.WEEK => lang.statsPeriodWeek,
      pb.ChartTimePeriod.MONTH => lang.statsPeriodMonth,
      _ => p.name,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<CurrentUserProvider>();
    final boutiques = context.watch<BoutiqueProvider>().allBoutiques;
    final userPerms = context.watch<PermissionProvider>().userPermissions;
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    if (userPerms.firmId.isEmpty) {
      if (currentUser.isLoading) {
        return const PortalMasterLayout(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return PortalMasterLayout(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentUser.error != null
                    ? '${lang.firmErrorUnexpected}: ${currentUser.error}'
                    : lang.statsNoAccess),
                const SizedBox(height: kDefaultPadding),
                ElevatedButton(
                  onPressed: () => currentUser.load(force: true),
                  child: Text(lang.refreshAction),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PortalMasterLayout(
      key: const Key('statsScreen'),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchChart();
          await _chartFuture;
        },
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Row(
              children: [
                Icon(Icons.analytics,
                    size: 32, color: themeData.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  lang.menuStats,
                  style: themeData.textTheme.headlineMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchChart,
                  tooltip: lang.refreshAction,
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            LayoutBuilder(builder: (context, constraints) {
              final isLarge = constraints.maxWidth >= kScreenWidthLg;
              return Column(
                children: [
                  if (isLarge)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMetricSelectorCard(lang)),
                        const SizedBox(width: kDefaultPadding),
                        Expanded(child: _buildPeriodSelectorCard(lang)),
                      ],
                    )
                  else ...[
                    _buildMetricSelectorCard(lang),
                    const SizedBox(height: kDefaultPadding),
                    _buildPeriodSelectorCard(lang),
                  ],
                  const SizedBox(height: kDefaultPadding),
                  _buildBoutiqueSelectorCard(lang, boutiques),
                  const SizedBox(height: kDefaultPadding),
                  _buildChartCard(lang, boutiques),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelectorCard(Lang lang) {
    final themeData = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category,
                    size: 20, color: themeData.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(lang.ticketsColumnType,
                    style: themeData.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<pb.FinancialChartMetric>(
                  showSelectedIcon: false,
                  segments: pb.FinancialChartMetric.values.map((m) {
                    return ButtonSegment(
                      value: m,
                      label: Text(_getMetricLabel(m, lang)),
                      icon: Icon(_getMetricIcon(m)),
                    );
                  }).toList(),
                  selected: {_selectedMetric},
                  onSelectionChanged: (newSelection) {
                    setState(() => _selectedMetric = newSelection.first);
                    _fetchChart();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelectorCard(Lang lang) {
    final themeData = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range,
                    size: 20, color: themeData.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(lang.ticketsColumnDateAndNumber,
                    style: themeData.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<pb.ChartTimePeriod>(
                    showSelectedIcon: false,
                    segments: pb.ChartTimePeriod.values.map((p) {
                      return ButtonSegment(
                        value: p,
                        label: Text(_getPeriodLabel(p, lang)),
                      );
                    }).toList(),
                    selected: {_selectedPeriod},
                    onSelectionChanged: (newSelection) {
                      setState(() => _selectedPeriod = newSelection.first);
                      _fetchChart();
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        initialDateRange: _selectedDateRange,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: themeData.colorScheme.copyWith(
                                primary: themeData.colorScheme.primary,
                                onPrimary: themeData.colorScheme.onPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _selectedDateRange = picked);
                        _fetchChart();
                      }
                    },
                    icon: const Icon(Icons.edit_calendar, size: 18),
                    label: Text(
                      '${_selectedDateRange.start.day}/${_selectedDateRange.start.month} - ${_selectedDateRange.end.day}/${_selectedDateRange.end.month}',
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoutiqueSelectorCard(Lang lang, List<dynamic> boutiques) {
    final themeData = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store,
                    size: 20, color: themeData.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(lang.statsSelectBoutiques,
                    style: themeData.textTheme.titleSmall),
                const Spacer(),
                _SwitchConfig(
                  label: lang.statsStackedByBoutique,
                  value: _isStacked,
                  onChanged: (value) {
                    setState(() => _isStacked = value);
                    _fetchChart();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(lang.statsAll),
                  selected: _selectedBoutiqueIds.isEmpty,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedBoutiqueIds = []);
                      _fetchChart();
                    }
                  },
                ),
                ...boutiques.map((b) {
                  return FilterChip(
                    label: Text(b.name),
                    selected: _selectedBoutiqueIds.contains(b.boutiqueId),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedBoutiqueIds.add(b.boutiqueId);
                        } else {
                          _selectedBoutiqueIds.remove(b.boutiqueId);
                        }
                      });
                      _fetchChart();
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(Lang lang, List<dynamic> boutiques) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<pb.FinancialChartResponse>(
              future: _chartFuture,
              builder: (context, snapshot) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildChartContent(context, snapshot, lang, boutiques),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(
      BuildContext context,
      AsyncSnapshot<pb.FinancialChartResponse> snapshot,
      Lang lang,
      List<dynamic> boutiques) {
    if (_chartFuture == null ||
        snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating your dazzling stats...'),
            ],
          ),
        ),
      );
    }
    if (snapshot.hasError) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('${lang.firmErrorUnexpected}: ${snapshot.error}'),
            ],
          ),
        ),
      );
    }
    if (!snapshot.hasData || snapshot.data!.svgContent.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(lang.statsNoDataAvailable),
            ],
          ),
        ),
      );
    }
    String svg = snapshot.data!.svgContent;
    for (final b in boutiques) {
      if (b.boutiqueId.isNotEmpty && b.name.isNotEmpty) {
        svg = svg.replaceAll(b.boutiqueId, b.name);
      }
    }
    return SvgPicture.string(
      svg,
      key: ValueKey(svg.hashCode),
      width: double.infinity,
      height: 400,
    );
  }
}

class _SwitchConfig extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchConfig({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
