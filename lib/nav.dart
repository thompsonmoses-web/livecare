import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Screen indices matching the sidebar order (W1–W10).
abstract final class Screens {
  static const dashboard = 0;
  static const liveMonitoring = 1;
  static const clients = 2;
  static const staff = 3;
  static const schedule = 4;
  static const incidents = 5;
  static const messages = 6;
  static const reports = 7;
  static const billing = 8;
  static const settings = 9;
}

/// Lets any screen ask the shell to switch tabs.
class AppNav {
  static void Function(int index)? _handler;

  static void register(void Function(int index) handler) => _handler = handler;
  static void unregister() => _handler = null;

  /// Navigate to a screen by index.
  static void go(int index) => _handler?.call(index);

  /// Feedback for actions that don't lead to a new screen.
  static void toast(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Opens an interactive dialog as the "next option" for a create/action button.
  static Future<void> dialog(
    BuildContext context, {
    required String title,
    String message = '',
    List<Widget> fields = const [],
    String confirmLabel = 'Save',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isNotEmpty) ...[
                Text(message, style: const TextStyle(fontSize: 13, color: AppColors.body)),
                const SizedBox(height: 14),
              ],
              ...fields,
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
              Navigator.of(ctx).pop();
              onConfirm?.call();
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

/// A labelled text field used inside [AppNav.dialog].
Widget dialogField(String label, {String hint = '', IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

/// A read-only label/value row used inside [AppNav.dialog].
Widget dialogInfo(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
