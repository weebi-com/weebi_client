import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../../boutique.dart';
import '../../dynamic_body.dart';

/// Widget for displaying detailed information about a chain using dynamic body
class ChainDetailWidget extends StatelessWidget {
  final Chain chain;
  final bool showEditButton;
  final VoidCallback? onEdit;
  final Function(BoutiqueMongo)? onBoutiqueSelected;

  const ChainDetailWidget({
    super.key,
    required this.chain,
    this.showEditButton = false,
    this.onEdit,
    this.onBoutiqueSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chain.name),
        actions: [
          if (showEditButton)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier la chaîne',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(context),
          Expanded(
            child: BoutiqueDynamicBody<Chain>(pbObject: chain),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.account_tree,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chain.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chain.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text('${chain.activeBoutiques.length} Actif'),
                        backgroundColor: Colors.green[100],
                      ),
                      if (chain.deletedBoutiques.isNotEmpty)
                        Chip(
                          label: Text('${chain.deletedBoutiques.length} Inactive'),
                          backgroundColor: Colors.red[100],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 