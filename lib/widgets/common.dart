import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../theme/app_theme.dart';

/// A status pill used across tables and cards.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  /// Convenience factory for the common LiveCare statuses.
  factory StatusBadge.tone(String label, StatusTone tone) {
    switch (tone) {
      case StatusTone.green:
        return StatusBadge(label: label, color: AppColors.green, bg: AppColors.greenSoft);
      case StatusTone.amber:
        return StatusBadge(label: label, color: AppColors.amber, bg: AppColors.amberSoft);
      case StatusTone.red:
        return StatusBadge(label: label, color: AppColors.red, bg: AppColors.redSoft);
      case StatusTone.blue:
        return StatusBadge(label: label, color: AppColors.primary, bg: AppColors.primarySoft);
      case StatusTone.purple:
        return StatusBadge(label: label, color: AppColors.purple, bg: AppColors.purpleSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusTone { green, amber, red, blue, purple }

/// Maps a status string to a tone for reuse.
StatusBadge statusBadge(String label) {
  final l = label.toLowerCase();
  // Non-active / ended states must be checked BEFORE 'active' — otherwise the
  // substring trap makes "inactive" render green like an active client.
  if (l.contains('inactive') ||
      l.contains('discharged') ||
      l.contains('archived') ||
      l.contains('transferred')) {
    return StatusBadge(label: label, color: AppColors.muted, bg: AppColors.surface);
  }
  if (l.contains('on track') ||
      l.contains('active') ||
      l.contains('paid') ||
      l.contains('resolved') ||
      l.contains('complete') ||
      l.contains('on time') ||
      l.contains('updated') ||
      l.contains('in progress')) {
    if (l.contains('in progress')) return StatusBadge.tone(label, StatusTone.blue);
    return StatusBadge.tone(label, StatusTone.green);
  }
  if (l.contains('pending') ||
      l.contains('late') ||
      l.contains('review') ||
      l.contains('scheduled') ||
      l.contains('in review') ||
      l.contains('expiring')) {
    return StatusBadge.tone(label, StatusTone.amber);
  }
  if (l.contains('open') ||
      l.contains('overdue') ||
      l.contains('needs') ||
      l.contains('action') ||
      l.contains('fall') ||
      l.contains('injury')) {
    return StatusBadge.tone(label, StatusTone.red);
  }
  if (l.contains('refusal') || l.contains('behavioral') || l.contains('concern')) {
    return StatusBadge.tone(label, StatusTone.purple);
  }
  return StatusBadge.tone(label, StatusTone.blue);
}

/// A circular avatar with initials (no network images needed).
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, this.radius = 18, this.color, this.image});

  final String name;
  final double radius;
  final Color? color;
  final Uint8List? image;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return CircleAvatar(
      radius: radius,
      backgroundColor: c.withValues(alpha: 0.15),
      backgroundImage: image != null ? MemoryImage(image!) : null,
      child: image == null
          ? Text(
              _initials,
              style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: radius * 0.8),
            )
          : null,
    );
  }
}
