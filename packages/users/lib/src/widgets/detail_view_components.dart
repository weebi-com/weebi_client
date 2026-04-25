import 'package:flutter/material.dart';
//import 'package:protos_weebi/protos_weebi_io.dart';

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
    BuildContext? context,
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
                      style: TextStyle(
                        color: context != null ? Theme.of(context).primaryColor : Colors.blue,
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
  
  /// Creates a consistent status chip
  static Widget buildStatusChip({
    required String text,
    required bool isActive,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? (activeColor ?? Colors.green[100]) 
            : (inactiveColor ?? Colors.red[100]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive 
              ? (activeColor ?? Colors.green[800]) 
              : (inactiveColor ?? Colors.red[800]),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
  
  /// Creates a consistent section header
  static Widget buildSectionHeader({
    required String title,
    IconData? icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
