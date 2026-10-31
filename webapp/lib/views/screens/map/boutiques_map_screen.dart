import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show Chain, License;
import 'package:web_admin/core/billing/load_firm_licenses.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/map/boutique_map_host.dart';
import 'package:web_admin/map/boutique_map_model.dart';
import 'package:web_admin/map/city_geocoder.dart';
import 'package:web_admin/map/city_point.dart';
import 'package:web_admin/map/leaflet_map_host.dart';
import 'package:web_admin/map/map_license.dart';
import 'package:web_admin/views/screens/map/boutiques_map_view.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Premium boutiques map shell: loads licenses + chains, then [BoutiquesMapView].
class BoutiquesMapScreen extends StatefulWidget {
  const BoutiquesMapScreen({
    super.key,
    this.mapHost,
    this.chainsOverride,
    this.licensesOverride,
    this.userIdOverride,
    this.geocoder,
  });

  final BoutiqueMapHost? mapHost;
  final List<Chain>? chainsOverride;
  final Iterable<License>? licensesOverride;
  final String? userIdOverride;
  final CityGeocoder? geocoder;

  @override
  State<BoutiquesMapScreen> createState() => _BoutiquesMapScreenState();
}

class _BoutiquesMapScreenState extends State<BoutiquesMapScreen> {
  BoutiqueMapHost? _host;
  LeafletMapHost? _leafletHost;
  Iterable<License>? _licenses;
  bool _licenseResolved = false;
  bool _loading = true;
  String? _error;
  List<BoutiquePin> _pins = const [];
  List<UnplacedBoutique> _unplaced = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _host?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (widget.licensesOverride != null) {
      _licenses = widget.licensesOverride;
      _licenseResolved = true;
    } else {
      final licenses = await loadFirmLicensesIfPermitted(context);
      if (!mounted) return;
      _licenses = licenses ?? const [];
      _licenseResolved = true;
    }

    if (!_isUnlocked) {
      setState(() => _loading = false);
      return;
    }

    _ensureHost();
    await _loadPins();
  }

  bool get _isUnlocked {
    final userId = widget.userIdOverride ??
        context.read<PermissionProvider>().userPermissions.userId;
    return mapViewUnlocked(userId, _licenses ?? const []);
  }

  void _ensureHost() {
    if (_host != null) return;
    if (widget.mapHost != null) {
      _host = widget.mapHost;
      return;
    }
    final leaflet = LeafletMapHost();
    _leafletHost = leaflet;
    _host = leaflet;
  }

  Future<void> _loadPins() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<Chain> chains;
      if (widget.chainsOverride != null) {
        chains = widget.chainsOverride!;
      } else {
        final boutiqueProvider = context.read<BoutiqueProvider>();
        if (boutiqueProvider.chains.isEmpty) {
          await boutiqueProvider.loadChains();
        }
        chains = List<Chain>.from(boutiqueProvider.chains);
      }

      final geocoder = widget.geocoder ?? const NullCityGeocoder();
      final result = await buildBoutiqueMap(chains, geocoder: geocoder);
      if (!mounted) return;

      setState(() {
        _pins = result.pins;
        _unplaced = result.unplaced;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Host is created once unlocked; locked/loading use a throwaway recorder.
    final host = _host ?? RecordingMapHost();
    final mapView = _leafletHost?.buildMapView() ??
        const SizedBox.expand(
          child: ColoredBox(color: Color(0xFFE8EEF5)),
        );

    final unlocked = _licenseResolved && _isUnlocked;
    return PortalMasterLayout(
      selectedMenuUri: RouteUri.map,
      body: BoutiquesMapView(
        unlocked: unlocked,
        loading: !_licenseResolved || (unlocked && _loading),
        error: _error,
        pins: _pins,
        unplaced: _unplaced,
        mapHost: host,
        mapView: mapView,
      ),
    );
  }
}
