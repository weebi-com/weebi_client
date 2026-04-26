import 'dart:convert';

import 'package:flutter/material.dart';

/// Returns an ImageProvider for a profile image URL.
/// Supports both http(s) URLs and data URLs (base64).
/// Returns null for empty or invalid strings.
ImageProvider? profileImageProvider(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('data:')) {
    try {
      final base64 = url.split(',').last;
      final bytes = base64Decode(base64);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(url);
}
