import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' as pb;
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:auth_weebi/auth_weebi.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<pb.FinancialChartResponse> _chartFuture;
  pb.FinancialChartMetric _selectedMetric = pb.FinancialChartMetric.CASHFLOW_INCOME;
  pb.ChartTimePeriod _selectedPeriod = pb.ChartTimePeriod.DAY;

  @override
  void initState() {
    super.initState();
    _fetchChart();
  }

  void _fetchChart() {
    final statsClient = context.read<StatsServiceClientProvider>().statsServiceClient;
    final userPerms = context.read<PermissionProvider>().userPermissions;
    
    final request = pb.FinancialChartRequest()
      ..firmId = userPerms.firmId
      ..boutiqueIds.addAll(userPerms.fullAccess.hasFullAccess 
          ? [] 
          : userPerms.limitedAccess.boutiqueIds.ids)
      ..start = pb.Timestamp.fromDateTime(DateTime.now().subtract(const Duration(days: 30)))
      ..end = pb.Timestamp.fromDateTime(DateTime.now())
      ..timePeriod = _selectedPeriod
      ..metric = _selectedMetric
      ..stackedByBoutique = false;

    setState(() {
      _chartFuture = statsClient.getFinancialChart(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: kDefaultPadding),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      DropdownButton<pb.FinancialChartMetric>(
                        value: _selectedMetric,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedMetric = value);
                            _fetchChart();
                          }
                        },
                        items: pb.FinancialChartMetric.values.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(m.name),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      DropdownButton<pb.ChartTimePeriod>(
                        value: _selectedPeriod,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPeriod = value);
                            _fetchChart();
                          }
                        },
                        items: pb.ChartTimePeriod.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: kDefaultPadding),
                  FutureBuilder<pb.FinancialChartResponse>(
                    future: _chartFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.svgContent.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }
                      return SvgPicture.string(
                        snapshot.data!.svgContent,
                        width: double.infinity,
                        height: 400,
                      );
                    },
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
