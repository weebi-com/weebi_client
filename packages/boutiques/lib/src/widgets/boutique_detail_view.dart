import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../../boutique.dart'; // For extensions
import '../../dynamic_body.dart';

/// Widget to display boutique or chain details, similar to UserDetailWidget
class BoutiqueDetailView extends StatelessWidget {
  final BoutiqueMongo? boutique;
  final Chain? chain;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BoutiqueDetailView({
    super.key,
    this.boutique,
    this.chain,
    this.onEdit,
    this.onDelete,
  })  : assert(boutique != null || chain != null,
            'Either boutique or chain must be provided'),
        assert(boutique == null || chain == null,
            'Cannot provide both boutique and chain');

  @override
  Widget build(BuildContext context) {
    final pbObject = boutique ?? chain;
    final title = boutique?.displayName ?? chain?.name ?? 'Details';
    final isChain = chain != null;

    if (pbObject == null) {
      return const Scaffold(
        body: Center(child: Text('Aucune donnée à afficher')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Modifier ${isChain ? 'la chaîne' : 'la boutique'}',
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Supprimer ${isChain ? 'la chaîne' : 'la boutique'}',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isChain ? Icons.account_tree : Icons.store,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (isChain) ...[
                                const SizedBox(height: 4),
                                Text(
                                  chain!.summary,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!isChain && boutique!.formattedAddress.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              boutique!.formattedAddress,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats Card
            if (!isChain) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de base',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      if (boutique!.devices.isNotEmpty)
                        _buildInfoRow(
                          context,
                          Icons.devices,
                          'Appareils',
                          '${boutique!.devices.length} connecté(s)',
                        ),
                      if (boutique!.formattedCreatedAt.isNotEmpty)
                        _buildInfoRow(
                          context,
                          Icons.calendar_today,
                          'Créé le',
                          boutique!.formattedCreatedAt,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Detailed Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations détaillées',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    BoutiqueDynamicBody(pbObject: pbObject),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
