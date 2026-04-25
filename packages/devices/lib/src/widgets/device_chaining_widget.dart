import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart'; // For BoutiqueProvider and BoutiqueMongo
import '../providers/device_provider.dart';

/// Simple widget for device-boutique chaining during POS app first login
///
/// This widget:
/// 1. Reads boutiques (server already filters based on user permissions)
/// 2. Groups them by chain if multiple chains exist
/// 3. Allows device chaining code generation
///
/// Ultra-simple usage - automatically gets current user from auth token!
class DeviceChainingWidget extends StatefulWidget {
  final Function(BoutiqueMongo, String)?
      onDeviceChained; // Called with boutique and code
  final VoidCallback? onCancel;

  const DeviceChainingWidget({
    super.key,
    this.onDeviceChained,
    this.onCancel,
  });

  @override
  State<DeviceChainingWidget> createState() => _DeviceChainingWidgetState();
}

class _DeviceChainingWidgetState extends State<DeviceChainingWidget> {
  String _searchQuery = '';
  bool _initialized = false;
  BoutiqueMongo? _selectedBoutique;
  bool _isGeneratingCode = false;
  String? _generatedCode;
  String? _error;
  UserPermissions? _userPermissions;
  List<BoutiqueMongo>? _activeBoutiques;
  bool _canGenerateCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() async {
    if (!_initialized && mounted) {
      _initialized = true;
      final boutiqueProvider = context.read<BoutiqueProvider>();

      // Initialize if not already done
      if (boutiqueProvider.chains.isEmpty && !boutiqueProvider.isLoading) {
        await boutiqueProvider.loadChains();
      }

      // Load user permissions and boutiques
      await _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final boutiqueProvider = context.read<BoutiqueProvider>();
    final deviceProvider = context.read<DeviceProvider>();

    try {
      // Get current user permissions from auth token
      final authProvider = context.read<AccessTokenProvider>();
      final permissions = authProvider.permissions;

      if ((permissions.userId.isNotEmpty ||
              deviceProvider.useServerPermissions) &&
          mounted) {
        setState(() {
          _userPermissions = permissions;
          // Server already filters boutiques based on permissions!
          // Just get all active boutiques - they're already filtered for this user
          _activeBoutiques = boutiqueProvider.activeBoutiques;
          _canGenerateCode = deviceProvider.canCreateDevice;
        });
      } else {
        setState(() {
          _error = 'No valid authentication token found';
        });
      }
    } on GrpcError catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load user data: ${e.code} ${e.message}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load user data: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BoutiqueProvider>(
      builder: (context, boutiqueProvider, child) {
        // Show loading during initial load or while loading user data
        if ((boutiqueProvider.isLoading && boutiqueProvider.chains.isEmpty) ||
            _userPermissions == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (boutiqueProvider.error != null || _error != null) {
          return _buildErrorView(boutiqueProvider.error ?? _error!);
        }

        if (_activeBoutiques?.isEmpty ?? true) {
          return _buildNoAccessView();
        }

        return Column(
          children: [
            _buildPermissionInfo(),
            _buildSearchBar(),
            Expanded(
              child: _buildBoutiquesList(_activeBoutiques!),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _canGenerateCode ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _canGenerateCode ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _canGenerateCode ? Icons.check_circle : Icons.warning,
            color: _canGenerateCode ? Colors.green[700] : Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _canGenerateCode
                      ? 'Device Chaining Available'
                      : 'Limited Device Chaining Access',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _canGenerateCode
                        ? Colors.green[800]
                        : Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _canGenerateCode
                      ? 'You can generate pairing codes for device chaining'
                      : 'ChainRight with Update permission required to chain devices',
                  style: TextStyle(
                    fontSize: 12,
                    color: _canGenerateCode
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error loading data'),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadUserData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Accessible Boutiques',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have access to any active boutiques.\n'
            'Contact your administrator to get access.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search boutiques...',
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

  Widget _buildBoutiquesList(List<BoutiqueMongo> boutiques) {
    final filteredBoutiques = _searchQuery.isEmpty
        ? boutiques
        : boutiques
            .where((boutique) =>
                boutique.displayName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                boutique.formattedAddress
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();

    if (filteredBoutiques.isEmpty) {
      return const Center(
        child: Text('No boutiques found'),
      );
    }

    // Group boutiques by chain for better organization (server already filtered them)
    final boutiquesByChain = <String, List<BoutiqueMongo>>{};
    final boutiqueProvider = context.read<BoutiqueProvider>();

    for (final boutique in filteredBoutiques) {
      final chainName = boutiqueProvider.chains
          .firstWhere((c) => c.chainId == boutique.chainId,
              orElse: () => Chain())
          .name;
      boutiquesByChain
          .putIfAbsent(
              chainName.isEmpty ? 'Unknown Chain' : chainName, () => [])
          .add(boutique);
    }

    // If only one chain, show boutiques directly without chain headers
    if (boutiquesByChain.length == 1) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBoutiques.length,
        itemBuilder: (context, index) {
          final boutique = filteredBoutiques[index];
          return _buildBoutiqueItem(boutique);
        },
      );
    }

    // Multiple chains - show with chain groupings
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: boutiquesByChain.length,
      itemBuilder: (context, index) {
        final chainName = boutiquesByChain.keys.elementAt(index);
        final chainBoutiques = boutiquesByChain[chainName]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chain header
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
                    Icon(Icons.account_tree,
                        color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      chainName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              // Boutiques list
              ...chainBoutiques.map((boutique) => _buildBoutiqueItem(boutique)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoutiqueItem(BoutiqueMongo boutique) {
    final isSelected = _selectedBoutique?.boutiqueId == boutique.boutiqueId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _selectBoutique(boutique),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Boutique logo or icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: (boutique.logo.isNotEmpty &&
                        boutique.logoExtension.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          Uint8List.fromList(boutique.logo),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.store),
                        ),
                      )
                    : const Icon(Icons.store),
              ),
              const SizedBox(width: 16),
              // Boutique details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boutique.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (boutique.formattedAddress.isNotEmpty)
                      Text(
                        boutique.formattedAddress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (boutique.devices.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Chip(
                          label: Text('${boutique.devices.length} devices'),
                          backgroundColor: Colors.blue[100],
                        ),
                      ),
                  ],
                ),
              ),
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedCodeDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code, size: 48, color: Colors.green[700]),
          const SizedBox(height: 8),
          Text(
            'Device Pairing Code Generated',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _generatedCode!,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Colors.green[800],
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Next Steps:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Copy this code using the button below\n'
                  '2. Go to the POS device that needs to be linked\n'
                  '3. After login, find the "Link this device" section\n'
                  '4. Enter this 6-digit code to complete the pairing',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Copy button centered
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _generatedCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Code copied to clipboard! Ready to use on POS device.'),
                    backgroundColor: Colors.green[600],
                    action: SnackBarAction(
                      label: 'Close',
                      textColor: Colors.white,
                      onPressed: () {
                        // Automatically call the callback to indicate we're done
                        widget.onDeviceChained
                            ?.call(_selectedBoutique!, _generatedCode!);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBoutiqueDialog(BoutiqueMongo boutique) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hasCode = _generatedCode != null;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.link, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Device Chaining',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Boutique info
                    Text(
                      boutique.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (boutique.formattedAddress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        boutique.formattedAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 16),

                    if (hasCode) ...[
                      // Show generated code
                      _buildGeneratedCodeDisplay(),
                    ] else ...[
                      // Show generate code button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _canGenerateCode && !_isGeneratingCode
                              ? () async {
                                  await _generatePairingCode();
                                  setDialogState(() {}); // Update dialog
                                }
                              : null,
                          icon: _isGeneratingCode
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.confirmation_number_sharp),
                          label: Text(
                            _isGeneratingCode
                                ? 'Generating Code...'
                                : 'Generate Pairing Code',
                          ),
                        ),
                      ),
                      if (!_canGenerateCode)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Note: ChainRight with Update permission is required',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style:
                              TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _selectBoutique(null); // Clear selection
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectBoutique(BoutiqueMongo? boutique) {
    if (boutique == null) {
      setState(() {
        _selectedBoutique = null;
        _generatedCode = null;
        _error = null;
      });
      return;
    }

    // Show dialog when boutique is selected
    setState(() {
      _selectedBoutique = boutique;
      _generatedCode = null;
      _error = null;
    });

    _showBoutiqueDialog(boutique);
  }

  Future<void> _generatePairingCode() async {
    if (_selectedBoutique == null) return;

    setState(() {
      _isGeneratingCode = true;
      _error = null;
    });

    try {
      final deviceProvider = context.read<DeviceProvider>();
      final code = await deviceProvider.generatePairingCode(
        _selectedBoutique!.chainId,
        _selectedBoutique!.boutiqueId,
      );

      if (code != null) {
        setState(() {
          _generatedCode = code;
        });
      } else {
        setState(() {
          _error = deviceProvider.error ?? 'Failed to generate pairing code';
        });
      }
    } on GrpcError catch (e) {
      setState(() {
        _error = 'Failed to generate pairing code: ${e.code} ${e.message}';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate pairing code: $e';
      });
    } finally {
      setState(() {
        _isGeneratingCode = false;
      });
    }
  }
}
