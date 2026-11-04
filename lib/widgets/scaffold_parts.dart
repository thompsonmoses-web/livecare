import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../nav.dart';
import '../theme/app_theme.dart';

/// The top search bar + user area shown on every screen.
class TopBar extends StatefulWidget {
  const TopBar({super.key, required this.hint});

  final String hint;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String _name = 'Admin User';
  String _agency = 'Riverside Care Agency';
  Uint8List? _photo;

  static const _kName = 'lc_admin_name_v1';
  static const _kAgency = 'lc_admin_agency_v1';
  static const _kPhoto = 'lc_admin_photo_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _name = prefs.getString(_kName) ?? _name;
        _agency = prefs.getString(_kAgency) ?? _agency;
        final b64 = prefs.getString(_kPhoto);
        if (b64 != null) {
          try {
            _photo = base64Decode(b64);
          } catch (_) {}
        }
      });
    } catch (_) {
      // Storage unavailable — keep the defaults.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kName, _name);
      await prefs.setString(_kAgency, _agency);
    } catch (_) {}
  }

  /// Downscale + JPEG-compress so the photo stays small enough for browser storage.
  Uint8List _compress(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;
      final resized = img.copyResize(decoded,
          width: 400, height: 400, interpolation: img.Interpolation.average);
      return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
    } catch (_) {
      return bytes;
    }
  }

  Future<void> _uploadPhoto() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res == null || res.files.isEmpty || res.files.single.bytes == null) return;
    final bytes = _compress(res.files.single.bytes!);
    if (!mounted) return;
    setState(() => _photo = bytes);
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(_kPhoto, base64Encode(bytes));
      if (!ok && mounted) {
        AppNav.toast(context, 'Photo saved for this session only (browser storage full)');
        return;
      }
    } catch (_) {}
    if (mounted) AppNav.toast(context, 'Profile photo updated');
  }

  Future<void> _removePhoto() async {
    setState(() => _photo = null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPhoto);
    } catch (_) {}
    if (mounted) AppNav.toast(context, 'Photo removed');
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final agencyCtrl = TextEditingController(text: _agency);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _editField(nameCtrl, 'Full name', Icons.person_outline),
              _editField(agencyCtrl, 'Agency / organization', Icons.business_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                if (nameCtrl.text.trim().isNotEmpty) _name = nameCtrl.text.trim();
                if (agencyCtrl.text.trim().isNotEmpty) _agency = agencyCtrl.text.trim();
              });
              _persist();
              Navigator.of(ctx).pop();
              AppNav.toast(context, 'Profile updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _editField(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _onMenu(String value) {
    switch (value) {
      case 'edit':
        _editProfile();
        break;
      case 'photo':
        _uploadPhoto();
        break;
      case 'removePhoto':
        _removePhoto();
        break;
      case 'settings':
        AppNav.go(Screens.settings);
        break;
      case 'signout':
        AppNav.toast(context, 'Signed out (demo)');
        break;
    }
  }

  void _showNotifications() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NoteRow(time: '09:15 AM', text: 'New incident reported — Mr. Williams (Fall risk)'),
              _NoteRow(time: '09:00 AM', text: 'New staff application — Tunde Adeyemi'),
              _NoteRow(time: '08:32 AM', text: 'Care plan updated — Mrs. Clark'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppNav.go(Screens.incidents);
            },
            child: const Text('Open Incidents'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget get _avatar => CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primary,
        backgroundImage: _photo != null ? MemoryImage(_photo!) : null,
        child: _photo == null
            ? Text(_initials,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
            : null,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 3,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.hint,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Notification bell
          Stack(
            children: [
              IconButton(
                onPressed: _showNotifications,
                icon: const Icon(Icons.notifications_none, color: AppColors.body),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1),
          const SizedBox(width: 12),
          // Clickable account area: name / agency / avatar + dropdown
          PopupMenuButton<String>(
            onSelected: _onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit profile'),
              ),
              PopupMenuItem(
                value: 'photo',
                child: _MenuRow(icon: Icons.photo_camera_outlined, label: 'Upload photo'),
              ),
              PopupMenuItem(
                value: 'removePhoto',
                child: _MenuRow(icon: Icons.hide_image_outlined, label: 'Remove photo'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: _MenuRow(icon: Icons.settings_outlined, label: 'Account settings'),
              ),
              PopupMenuItem(
                value: 'signout',
                child: _MenuRow(icon: Icons.logout, label: 'Sign out'),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(_agency, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 10),
                _avatar,
                const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.body),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.time, required this.text});
  final String time;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(time,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child:
                Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Standard page header with title, subtitle and optional trailing widgets.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.body, fontSize: 14)),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A white rounded card used for panels and tables.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

/// A stat card used on Dashboard / Monitoring / Billing.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    this.accent,
    this.iconColor,
    this.footer,
    this.onTap,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color? accent;
  final Color? iconColor;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isFilled = accent != null;
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFilled ? accent : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isFilled ? accent! : AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isFilled ? Colors.white70 : AppColors.body,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isFilled ? Colors.white24 : (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: isFilled ? Colors.white : (iconColor ?? AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isFilled ? Colors.white : AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: TextStyle(
              fontSize: 12,
              color: isFilled ? Colors.white70 : AppColors.muted,
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 8), footer!],
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: card,
    );
  }
}
