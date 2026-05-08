import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';
import '../providers/device_provider.dart';
import 'device_chaining_widget.dart';

/// Comprehensive device management widget with full CRUD operations
///
/// Features:
/// - List all devices for accessible chains
/// - Create new devices (chain to boutiques)
/// - Update device passwords
/// - Delete devices
/// - Move devices between boutiques (when available)
/// - Enable/disable devices (when available)
///
/// All operations respect ChainRights permissions
class DeviceManagementWidget extends StatefulWidget {
  const DeviceManagementWidget({super.key});

  @override
  State<DeviceManagementWidget> createState() => _DeviceManagementWidgetState();
}

class _DeviceManagementWidgetState extends State<DeviceManagementWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedChainId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initialize() async {
    if (!_initialized && mounted) {
      _initialized = true;

      // Initialize providers
      final boutiqueProvider = context.read<BoutiqueProvider>();
      final deviceProvider = context.read<DeviceProvider>();
      final authProvider = context.read<AccessTokenProvider>();

      // Set user permissions for device provider
      deviceProvider.setUserPermissions(authProvider.permissions);

      // Load chains if needed
      if (boutiqueProvider.chains.isEmpty && !boutiqueProvider.isLoading) {
        await boutiqueProvider.loadChains();
      }

      // Load devices for the first accessible chain
      if (boutiqueProvider.chains.isNotEmpty) {
        final firstChain = boutiqueProvider.chains.first;
        setState(() {
          _selectedChainId = firstChain.chainId;
        });
        await deviceProvider.loadDevices(firstChain.chainId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        tabBarTheme: const TabBarThemeData(
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Colors.teal, width: 8, style: BorderStyle.solid),
            ),
            color: Color(0xFFE0E0E0),
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des appareils'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.devices), text: 'Gérer les appareils'),
              Tab(icon: Icon(Icons.add_link), text: 'Associer un appareil'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDeviceListTab(),
            _buildDeviceChainingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceListTab() {
    return Consumer2<DeviceProvider, BoutiqueProvider>(
      builder: (context, deviceProvider, boutiqueProvider, child) {
        return Column(
          children: [
            _buildPermissionsHeader(deviceProvider),
            _buildChainSelector(boutiqueProvider, deviceProvider),
            _buildSearchBar(),
            Expanded(
              child: _buildDevicesList(deviceProvider, boutiqueProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeviceChainingTab() {
    return const DeviceChainingWidget();
  }

  Widget _buildPermissionsHeader(DeviceProvider deviceProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.grey[600], size: 16),
          const SizedBox(width: 6),
          Text(
            'Permissions:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                _buildCompactPermissionChip(
                    'Créer', deviceProvider.canCreateDevice),
                _buildCompactPermissionChip(
                    'Lire', deviceProvider.canReadDevices),
                _buildCompactPermissionChip(
                    'Modifier', deviceProvider.canUpdateDevice),
                _buildCompactPermissionChip(
                    'Supprimer', deviceProvider.canDeleteDevice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPermissionChip(String label, bool hasPermission) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasPermission ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasPermission ? Colors.green[300]! : Colors.red[300]!,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: hasPermission ? Colors.green[800] : Colors.red[800],
        ),
      ),
    );
  }

  Widget _buildChainSelector(
      BoutiqueProvider boutiqueProvider, DeviceProvider deviceProvider) {
    if (boutiqueProvider.chains.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only one chain, show a subtle info display instead of dropdown
    if (boutiqueProvider.chains.length == 1) {
      final chain = boutiqueProvider.chains.first;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.account_tree, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Chaîne : ${chain.name.isEmpty ? 'Chaîne sans nom' : chain.name}',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.check_circle, color: Colors.green[600], size: 16),
          ],
        ),
      );
    }

    // Multiple chains - show dropdown
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Sélectionner une chaîne',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.account_tree),
        ),
        value: _selectedChainId,
        items: boutiqueProvider.chains.map((chain) {
          return DropdownMenuItem(
            value: chain.chainId,
            child: Text(chain.name.isEmpty ? 'Chaîne sans nom' : chain.name),
          );
        }).toList(),
        onChanged: deviceProvider.canReadDevices
            ? (chainId) async {
                if (chainId != null) {
                  setState(() {
                    _selectedChainId = chainId;
                  });
                  await deviceProvider.loadDevices(chainId);
                }
              }
            : null,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Rechercher des appareils...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildDevicesList(
      DeviceProvider deviceProvider, BoutiqueProvider boutiqueProvider) {
    if (deviceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (deviceProvider.error != null) {
      return _buildErrorView(deviceProvider.error!, () async {
        if (_selectedChainId != null) {
          await deviceProvider.loadDevices(_selectedChainId!);
        }
      });
    }

    if (!deviceProvider.canReadDevices) {
      return _buildNoPermissionView('ChainRight.read requis pour voir les appareils');
    }

    final devices = deviceProvider.searchDevices(_searchQuery);

    if (devices.isEmpty) {
      return _buildEmptyDevicesView();
    }

    // Group devices by boutique
    final devicesByBoutique = <String, List<Device>>{};
    for (final device in devices) {
      final boutique = boutiqueProvider.allBoutiques.firstWhere(
          (b) => b.boutiqueId == device.boutiqueId,
          orElse: () => BoutiqueMongo());
      final boutiqueName = boutique.displayName.isEmpty
          ? 'Boutique inconnue'
          : boutique.displayName;
      devicesByBoutique.putIfAbsent(boutiqueName, () => []).add(device);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: devicesByBoutique.length,
      itemBuilder: (context, index) {
        final boutiqueName = devicesByBoutique.keys.elementAt(index);
        final boutiqueDevices = devicesByBoutique[boutiqueName]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Boutique header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.store, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      boutiqueName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text('${boutiqueDevices.length} appareils'),
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
              // Devices list
              ...boutiqueDevices
                  .map((device) => _buildDeviceItem(device, deviceProvider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceItem(Device device, DeviceProvider deviceProvider) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: device.status ? Colors.green[100] : Colors.red[100],
        child: Icon(
          device.status ? Icons.phone_android : Icons.phone_android_outlined,
          color: device.status ? Colors.green[700] : Colors.red[700],
        ),
      ),
      title: Text(
        device.hardwareInfo.name.isEmpty
            ? 'Appareil ${device.deviceId.substring(0, 8)}...'
            : device.hardwareInfo.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${device.deviceId}'),
          if (device.hardwareInfo.brand.isNotEmpty ||
              device.hardwareInfo.baseOS.isNotEmpty)
            Text('${device.hardwareInfo.brand} ${device.hardwareInfo.baseOS}'
                .trim()),
          Row(
            children: [
              Icon(
                device.status ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: device.status ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                device.status ? 'Actif' : 'Inactif',
                style: TextStyle(
                  color: device.status ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) =>
            _handleDeviceAction(action, device, deviceProvider),
        itemBuilder: (context) => [
          if (deviceProvider.canUpdateDevice) ...[
            const PopupMenuItem(
              value: 'update_password',
              child: ListTile(
                leading: Icon(Icons.lock_reset),
                title: Text('Modifier le mot de passe'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'move_boutique',
              child: ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text('Déplacer vers une autre boutique'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: device.status ? 'disable' : 'enable',
              child: ListTile(
                leading:
                    Icon(device.status ? Icons.toggle_off : Icons.toggle_on),
                title: Text(device.status ? 'Désactiver l\'appareil' : 'Activer l\'appareil'),
                dense: true,
              ),
            ),
          ],
          if (deviceProvider.canDeleteDevice)
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title:
                    Text('Supprimer l\'appareil', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text('Erreur lors du chargement des appareils'),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPermissionView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Permissions insuffisantes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDevicesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucun appareil trouvé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Aucun appareil n\'est enregistré pour cette chaîne.\nUtilisez l\'onglet "Associer un appareil" pour en ajouter un.'
                : 'Aucun appareil ne correspond à vos critères de recherche.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.add_link),
              label: const Text('Associer un appareil'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleDeviceAction(
      String action, Device device, DeviceProvider deviceProvider) {
    switch (action) {
      case 'update_password':
        _showUpdatePasswordDialog(device, deviceProvider);
        break;
      case 'move_boutique':
        _showMoveBoutiqueDialog(device, deviceProvider);
        break;
      case 'enable':
      case 'disable':
        _showToggleStatusDialog(device, action == 'enable', deviceProvider);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(device, deviceProvider);
        break;
    }
  }

  void _showUpdatePasswordDialog(Device device, DeviceProvider deviceProvider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le mot de passe de l\'appareil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Modifier le mot de passe pour l\'appareil : ${device.hardwareInfo.name.isEmpty ? device.deviceId.substring(0, 8) : device.hardwareInfo.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                // Capture the context before async operations
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();

                final success = await deviceProvider.updateDevicePassword(
                    device, controller.text);

                // Check if widget is still mounted before showing snackbar
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Mot de passe mis à jour avec succès'
                          : 'Échec de la mise à jour du mot de passe'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showMoveBoutiqueDialog(Device device, DeviceProvider deviceProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déplacer l\'appareil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, color: Colors.blue[600], size: 48),
            const SizedBox(height: 16),
            const Text(
              'Le déplacement d\'appareils entre boutiques n\'est pas encore disponible.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez contacter le support pour obtenir de l\'aide sur les transferts d\'appareils.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showToggleStatusDialog(
      Device device, bool enable, DeviceProvider deviceProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${enable ? 'Activer' : 'Désactiver'} l\'appareil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, color: Colors.blue[600], size: 48),
            const SizedBox(height: 16),
            const Text(
              'La fonctionnalité d\'activation/désactivation d\'appareil n\'est pas encore disponible.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez contacter le support pour obtenir de l\'aide sur les changements de statut d\'appareil.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      Device device, DeviceProvider deviceProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'appareil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 48),
            const SizedBox(height: 16),
            Text(
              'Êtes-vous sûr de vouloir supprimer définitivement cet appareil ?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              device.hardwareInfo.name.isEmpty
                  ? 'ID de l\'appareil : ${device.deviceId}'
                  : device.hardwareInfo.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                'Cette action est irréversible. L\'appareil sera définitivement retiré du système.',
                style: TextStyle(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Capture the context before async operations
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();

              final success = await deviceProvider.deleteDevice(device);

              // Check if widget is still mounted before showing snackbar
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Appareil supprimé avec succès'
                        : 'Échec de la suppression de l\'appareil'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
