import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/map/boutique_map_host.dart';
import 'package:web_admin/map/boutique_map_model.dart';
import 'package:web_admin/map/city_point.dart';

/// Presentational map UI. Feeds [mapHost] and has no gRPC / Leaflet imports.
///
/// Used by [BoutiquesMapScreen] and by widget tests with a [RecordingMapHost].
class BoutiquesMapView extends StatefulWidget {
  const BoutiquesMapView({
    super.key,
    required this.unlocked,
    required this.pins,
    required this.unplaced,
    required this.mapHost,
    required this.mapView,
    this.loading = false,
    this.error,
    this.initialGroupBy = MapGroupBy.chainName,
  });

  final bool unlocked;
  final bool loading;
  final String? error;
  final List<BoutiquePin> pins;
  final List<UnplacedBoutique> unplaced;
  final BoutiqueMapHost mapHost;
  final Widget mapView;
  final MapGroupBy initialGroupBy;

  @override
  State<BoutiquesMapView> createState() => _BoutiquesMapViewState();
}

class _BoutiquesMapViewState extends State<BoutiquesMapView> {
  late MapGroupBy _groupBy;
  final TextEditingController _searchController = TextEditingController();
  bool _pushedPins = false;

  @override
  void initState() {
    super.initState();
    _groupBy = widget.initialGroupBy;
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncHost());
  }

  @override
  void didUpdateWidget(covariant BoutiquesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pins != widget.pins ||
        oldWidget.unlocked != widget.unlocked ||
        oldWidget.loading != widget.loading) {
      _pushedPins = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncHost());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncHost() {
    if (!mounted || !widget.unlocked || widget.loading) return;
    widget.mapHost.setPins(widget.pins, _groupBy);
    widget.mapHost.fitBounds(boundsFor(widget.pins));
    _pushedPins = true;
  }

  void _onGroupByChanged(MapGroupBy value) {
    setState(() => _groupBy = value);
    if (widget.unlocked) {
      widget.mapHost.setPins(widget.pins, value);
    }
  }

  void _onSearch(String query) {
    final pin = findPin(widget.pins, query);
    if (pin != null) {
      widget.mapHost.focus(pin);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.of(context).mapSearchNoResult)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!widget.unlocked) {
      return _LockedMapBody(lang: lang);
    }
    return _MapBody(
      lang: lang,
      pins: widget.pins,
      unplaced: widget.unplaced,
      error: widget.error,
      groupBy: _groupBy,
      searchController: _searchController,
      onGroupByChanged: _onGroupByChanged,
      onSearch: _onSearch,
      mapView: widget.mapView,
      hostSynced: _pushedPins,
    );
  }
}

class _LockedMapBody extends StatelessWidget {
  const _LockedMapBody({required this.lang});

  final Lang lang;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PointerInterceptor(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang.mapLockedTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.mapLockedDetail,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('mapGoToBilling'),
                    onPressed: () => GoRouter.of(context).go(RouteUri.billing),
                    icon: const Icon(Icons.workspace_premium_rounded),
                    label: Text(lang.mapGoToBilling),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapBody extends StatelessWidget {
  const _MapBody({
    required this.lang,
    required this.pins,
    required this.unplaced,
    required this.error,
    required this.groupBy,
    required this.searchController,
    required this.onGroupByChanged,
    required this.onSearch,
    required this.mapView,
    required this.hostSynced,
  });

  final Lang lang;
  final List<BoutiquePin> pins;
  final List<UnplacedBoutique> unplaced;
  final String? error;
  final MapGroupBy groupBy;
  final TextEditingController searchController;
  final ValueChanged<MapGroupBy> onGroupByChanged;
  final ValueChanged<String> onSearch;
  final Widget mapView;
  final bool hostSynced;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: mapView),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: PointerInterceptor(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      key: const Key('mapSearchField'),
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: lang.mapSearchHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                      ),
                      onSubmitted: onSearch,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: SegmentedButton<MapGroupBy>(
                      segments: [
                        ButtonSegment(
                          value: MapGroupBy.chainName,
                          label: Text(lang.mapGroupByChain),
                        ),
                        ButtonSegment(
                          value: MapGroupBy.countryCode,
                          label: Text(lang.mapGroupByCountry),
                        ),
                      ],
                      selected: {groupBy},
                      onSelectionChanged: (selected) {
                        if (selected.isNotEmpty) {
                          onGroupByChanged(selected.first);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (unplaced.isNotEmpty)
          Positioned(
            right: 12,
            bottom: 12,
            width: 280,
            child: PointerInterceptor(
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.mapUnplacedHeading,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...unplaced.take(8).map(
                            (u) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${u.name} (${u.chainName})',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                      if (unplaced.length > 8)
                        Text(
                          '+${unplaced.length - 8}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (error != null)
          Positioned(
            left: 12,
            bottom: 12,
            child: PointerInterceptor(
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(error!),
                ),
              ),
            ),
          ),
        if (pins.isEmpty && unplaced.isEmpty && error == null)
          Center(
            child: PointerInterceptor(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(lang.mapEmpty),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
