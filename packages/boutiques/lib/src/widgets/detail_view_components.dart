import 'package:flutter/material.dart';

/// Reusable components for consistent detail views across the app
class DetailViewComponents {
  
  /// Creates a consistent summary card for any entity
  static Widget buildSummaryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? avatar,
    List<Widget>? additionalInfo,
    Color? backgroundColor,
  }) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar/Icon section
            if (avatar != null)
              avatar
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 28, color: Colors.grey[600]),
              ),
            
            const SizedBox(width: 12),
            
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Additional info
                  if (additionalInfo != null) ...[
                    const SizedBox(height: 8),
                    ...additionalInfo,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Creates a consistent info row
  static Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: onTap != null
                ? GestureDetector(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }
}
