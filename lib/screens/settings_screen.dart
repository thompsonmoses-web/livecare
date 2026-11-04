import 'package:flutter/material.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

/// Opens a dialog of editable text fields; returns the edited map via [onSave].
Future<void> _editFields(
  BuildContext context, {
  required String title,
  required Map<String, String> values,
  required void Function(Map<String, String>) onSave,
}) async {
  final ctrls = {for (var e in values.entries) e.key: TextEditingController(text: e.value)};
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var e in values.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: ctrls[e.key],
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onSave({for (var e in values.entries) e.key: ctrls[e.key]!.text});
          },
          child: const Text('Save changes'),
        ),
      ],
    ),
  );
}

/// Opens a single-choice list dialog; returns the pick via [onPick].
Future<void> _chooseOption(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String current,
  required void Function(String) onPick,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in options)
              ListTile(
                dense: true,
                title: Text(o, style: const TextStyle(fontSize: 14)),
                trailing: o == current ? const Icon(Icons.check, color: AppColors.primary, size: 18) : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onPick(o);
                },
              ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel'))],
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> _tabs = ['Agency', 'Users & Roles', 'Notifications', 'Integrations', 'Security'];
  int _tab = 0;

  Map<String, String> _agency = {
    'Agency name': 'Riverside Care Agency',
    'Registration number': 'RC-AG-001234',
    'Email address': 'info@riversidecare.com',
    'Phone number': '+234 801 234 5678',
    'Address': '12 Riverside Drive, Ija, Lagos',
    'Time zone': '(GMT+1) West Africa Time',
  };

  final Map<String, String> _prefs = {
    'Default language': 'English (US)',
    'Date format': 'MM/DD/YYYY',
    'Currency': '\u20A6 Nigerian Naira',
    'Time format': '12-hour (AM/PM)',
    'Session timeout': '30 minutes',
  };

  final Map<String, List<String>> _prefOptions = {
    'Default language': ['English (US)', 'English (UK)', 'French', 'Yoruba', 'Hausa'],
    'Date format': ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
    'Currency': ['\u20A6 Nigerian Naira', r'$ US Dollar', '€ Euro', '£ Pound'],
    'Time format': ['12-hour (AM/PM)', '24-hour'],
    'Session timeout': ['15 minutes', '30 minutes', '1 hour', '4 hours'],
  };

  final List<List<String>> _hours = [
    ['Monday', '8:00 AM - 6:00 PM'],
    ['Tuesday', '8:00 AM - 6:00 PM'],
    ['Wednesday', '8:00 AM - 6:00 PM'],
    ['Thursday', '8:00 AM - 6:00 PM'],
    ['Friday', '9:00 AM - 1:00 PM'],
    ['Saturday', 'Closed'],
    ['Sunday', 'Closed'],
  ];

  List<String> _areas = ['Ija', 'Yaba', 'Victoria Island', 'Lekki', 'Surulere', 'Ikoyi', 'Ajah'];

  final Map<String, bool> _notif = {
    'New incident alerts': true,
    'Client updates': true,
    'Staff onboarding': true,
    'Payment reminders': false,
    'System updates': true,
  };

  final List<Map<String, String>> _users = [
    {'name': 'Admin User', 'email': 'admin@riversidecare.com', 'role': 'Administrator', 'status': 'Active'},
    {'name': 'Rita Menash', 'email': 'rita@riversidecare.com', 'role': 'Coordinator', 'status': 'Active'},
    {'name': 'Ada Obi', 'email': 'ada@riversidecare.com', 'role': 'Caregiver', 'status': 'Active'},
    {'name': 'Tunde Ogunmi', 'email': 'tunde@riversidecare.com', 'role': 'Caregiver', 'status': 'Active'},
    {'name': 'Okufu Rae', 'email': 'okufu@riversidecare.com', 'role': 'Caregiver', 'status': 'Inactive'},
  ];

  final Map<String, bool> _integrations = {
    'Electronic health records': false,
    'Payment gateway': true,
    'SMS notifications': true,
    'Calendar sync': false,
  };

  bool _twoFA = false;
  bool _loginAlerts = true;

  void _toast(String msg) => AppNav.toast(context, msg);

  void _editAgency() {
    _editFields(context, title: 'Edit agency information', values: Map.of(_agency), onSave: (m) {
      setState(() => _agency = m);
      _toast('Agency information saved');
    });
  }

  void _editPref(String label) {
    _chooseOption(
      context,
      title: label,
      options: _prefOptions[label]!,
      current: _prefs[label]!,
      onPick: (v) {
        setState(() => _prefs[label] = v);
        _toast('$label set to $v');
      },
    );
  }

  void _editDay(int i) {
    final c = TextEditingController(text: _hours[i][1]);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${_hours[i][0]}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Opening hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
              const SizedBox(height: 6),
              TextField(
                controller: c,
                decoration: InputDecoration(
                  hintText: 'e.g. 8:00 AM - 6:00 PM, or "Closed"',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _hours[i][1] = c.text.trim().isEmpty ? 'Closed' : c.text.trim());
              _toast('${_hours[i][0]} hours updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editAreas() {
    _editFields(
      context,
      title: 'Edit service areas',
      values: {for (var i = 0; i < _areas.length; i++) 'Area ${i + 1}': _areas[i]},
      onSave: (m) {
        setState(() => _areas = m.values.where((v) => v.trim().isNotEmpty).toList());
        _toast('Service areas updated');
      },
    );
  }

  void _addUser() {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final roleC = TextEditingController(text: 'Caregiver');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add user', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf('Full name', nameC),
              _tf('Email', emailC),
              _tf('Role', roleC),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final n = nameC.text.trim();
              if (n.isEmpty) return;
              Navigator.of(ctx).pop();
              setState(() => _users.add({
                    'name': n,
                    'email': emailC.text.trim().isEmpty ? '—' : emailC.text.trim(),
                    'role': roleC.text.trim().isEmpty ? 'Caregiver' : roleC.text.trim(),
                    'status': 'Active',
                  }));
              _toast('$n added');
            },
            child: const Text('Add user'),
          ),
        ],
      ),
    );
  }

  void _editUser(int i) {
    final u = _users[i];
    final nameC = TextEditingController(text: u['name']);
    final emailC = TextEditingController(text: u['email']);
    final roleC = TextEditingController(text: u['role']);
    final statusC = TextEditingController(text: u['status']);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${u['name']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf('Full name', nameC),
              _tf('Email', emailC),
              _tf('Role', roleC),
              _tf('Status', statusC),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _users[i] = {
                    'name': nameC.text.trim().isEmpty ? u['name']! : nameC.text.trim(),
                    'email': emailC.text.trim(),
                    'role': roleC.text.trim(),
                    'status': statusC.text.trim().isEmpty ? 'Active' : statusC.text.trim(),
                  });
              _toast('User updated');
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final newC = TextEditingController();
    final confC = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf('New password', newC, obscure: true),
              _tf('Confirm password', confC, obscure: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _toast('Password updated');
            },
            child: const Text('Update password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(
          title: 'Settings',
          subtitle: 'Configure your agency, users and system preferences.',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              _Tab(label: _tabs[i], active: i == _tab, onTap: () => setState(() => _tab = i)),
              if (i != _tabs.length - 1) const SizedBox(width: 20),
            ],
          ],
        ),
        const SizedBox(height: 18),
        _buildTab(),
      ],
    );
  }

  Widget _buildTab() {
    switch (_tab) {
      case 1:
        return _usersTab();
      case 2:
        return _notificationsTab();
      case 3:
        return _integrationsTab();
      case 4:
        return _securityTab();
      default:
        return _agencyTab();
    }
  }

  Widget _agencyTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _AgencyInfo(agency: _agency, onEdit: _editAgency),
              const SizedBox(height: 14),
              _SystemPreferences(prefs: _prefs, onPick: _editPref),
              const SizedBox(height: 14),
              _DataManagement(),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              _BusinessHours(hours: _hours, onEditDay: _editDay),
              const SizedBox(height: 14),
              _ServiceAreas(areas: _areas, onEdit: _editAreas),
              const SizedBox(height: 14),
              _NotificationsCard(notif: _notif, onToggle: (k) => setState(() => _notif[k] = !_notif[k]!)),
              const SizedBox(height: 14),
              _Support(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _usersTab() {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                  child: Text('Users & roles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              FilledButton.icon(
                onPressed: _addUser,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add user'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Manage who can access the agency dashboard and what they can do.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          const Divider(height: 1),
          for (var i = 0; i < _users.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Avatar(name: _users[i]['name']!, radius: 18),
              title: Text(_users[i]['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(_users[i]['email']!, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  statusBadge(_users[i]['status']!),
                  const SizedBox(width: 10),
                  Text(_users[i]['role']!, style: const TextStyle(fontSize: 12, color: AppColors.body)),
                  TextButton(onPressed: () => _editUser(i), child: const Text('Edit')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _notificationsTab() {
    return Column(
      children: [
        _NotificationsCard(notif: _notif, onToggle: (k) => setState(() => _notif[k] = !_notif[k]!)),
        const SizedBox(height: 14),
        _DeliveryPreferences(),
      ],
    );
  }

  Widget _integrationsTab() {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Integrations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Connect LiveCare to the tools your agency already uses.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          const Divider(height: 1),
          ..._integrations.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(e.value ? Icons.check_circle : Icons.link_off,
                      size: 20, color: e.value ? AppColors.green : AppColors.muted),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  FilledButton.tonal(
                    onPressed: () {
                      setState(() => _integrations[e.key] = !e.value);
                      _toast('${e.key} ${e.value ? 'disconnected' : 'connected'}');
                    },
                    child: Text(e.value ? 'Disconnect' : 'Connect'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                _toggleRow('Two-factor authentication', 'Require a second step at sign-in.', _twoFA,
                    (v) => setState(() => _twoFA = v)),
                const Divider(height: 20),
                _toggleRow('Login alerts', 'Email me when a new device signs in.', _loginAlerts,
                    (v) => setState(() => _loginAlerts = v)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.lock_outline, size: 16),
                    label: const Text('Change password'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Devices currently signed in to this account.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 14),
                _sessionRow('This device', 'Lagos, NG • Chrome', true),
                _sessionRow('iPhone 14', 'Lagos, NG • App', false),
                _sessionRow('MacBook Air', 'Abuja, NG • Safari', false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
      ],
    );
  }

  Widget _sessionRow(String device, String detail, bool current) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(current ? Icons.phone_iphone : Icons.devices, size: 18, color: AppColors.body),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(detail, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          if (current)
            statusBadge('Active')
          else
            TextButton(onPressed: () => _toast('Signed out $device'), child: const Text('Sign out')),
        ],
      ),
    );
  }
}

Widget _tf(String label, TextEditingController c, {bool obscure = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          obscureText: obscure,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, this.active = false, this.onTap});
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.body,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
            decoration: active ? TextDecoration.underline : null,
            decorationColor: AppColors.primary,
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, this.onEdit});
  final String title;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        if (onEdit != null)
          InkWell(
            onTap: onEdit,
            child: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
      ],
    );
  }
}

class _AgencyInfo extends StatelessWidget {
  const _AgencyInfo({required this.agency, required this.onEdit});
  final Map<String, String> agency;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(title: 'Agency Information', onEdit: onEdit),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.home_work_outlined, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(agency['Agency name']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const Text('Better care. Together.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var e in agency.entries) _Field(label: e.key, value: e.value),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _BusinessHours extends StatelessWidget {
  const _BusinessHours({required this.hours, required this.onEditDay});
  final List<List<String>> hours;
  final void Function(int) onEditDay;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: 'Business hours'),
          const SizedBox(height: 4),
          const Text('Tap a day to edit its hours.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          for (var i = 0; i < hours.length; i++)
            InkWell(
              onTap: () => onEditDay(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(hours[i][0], style: const TextStyle(fontSize: 13))),
                    Text(hours[i][1],
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: hours[i][1] == 'Closed' ? AppColors.muted : AppColors.ink)),
                    const SizedBox(width: 6),
                    const Icon(Icons.edit_outlined, size: 14, color: AppColors.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceAreas extends StatelessWidget {
  const _ServiceAreas({required this.areas, required this.onEdit});
  final List<String> areas;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(title: 'Service areas', onEdit: onEdit),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...areas.map((a) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(a,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemPreferences extends StatelessWidget {
  const _SystemPreferences({required this.prefs, required this.onPick});
  final Map<String, String> prefs;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('System preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          for (var e in prefs.entries) _DropdownField(label: e.key, value: e.value, onTap: () => onPick(e.key)),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 4),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({required this.notif, required this.onToggle});
  final Map<String, bool> notif;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...notif.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                  Switch(
                      value: e.value,
                      onChanged: (_) => onToggle(e.key),
                      activeThumbColor: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPreferences extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Choose how you want to be notified.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 12),
          _DeliveryRow(label: 'Email', icon: Icons.email_outlined),
          _DeliveryRow(label: 'SMS', icon: Icons.sms_outlined),
          _DeliveryRow(label: 'Push notifications', icon: Icons.notifications_active_outlined),
          _DeliveryRow(label: 'Weekly summary report', icon: Icons.summarize_outlined),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatefulWidget {
  const _DeliveryRow({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  State<_DeliveryRow> createState() => _DeliveryRowState();
}

class _DeliveryRowState extends State<_DeliveryRow> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(widget.icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Switch(
              value: _on,
              onChanged: (v) => setState(() => _on = v),
              activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _DataManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storage_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Data management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Export your data or manage data retention settings.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppNav.dialog(
                    context,
                    title: 'Export data',
                    message: 'Choose what to export and the format.',
                    fields: [
                      dialogField('Data', hint: 'Clients, staff, billing\u2026', icon: Icons.folder_outlined),
                      dialogField('Format', hint: 'CSV or PDF', icon: Icons.insert_drive_file_outlined),
                    ],
                    confirmLabel: 'Export',
                    onConfirm: () {},
                  ),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export data'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppNav.dialog(
                    context,
                    title: 'Retention settings',
                    message: 'Control how long records are kept.',
                    fields: [
                      dialogField('Keep inactive records', hint: 'e.g. 24 months', icon: Icons.history),
                      dialogField('Auto-delete', hint: 'Off', icon: Icons.delete_outline),
                    ],
                    confirmLabel: 'Save',
                    onConfirm: () {},
                  ),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('Retention settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Support extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Support & help', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Get help, read guides or contact support.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppNav.dialog(
                    context,
                    title: 'Help centre',
                    message: 'Browse guides and answers to common questions.',
                    fields: [
                      dialogInfo('Getting started', 'Guide'),
                      dialogInfo('Managing clients', 'Guide'),
                      dialogInfo('Billing & invoices', 'Guide'),
                    ],
                    confirmLabel: 'Close',
                    onConfirm: () {},
                  ),
                  icon: const Icon(Icons.menu_book, size: 16),
                  label: const Text('Help centre'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppNav.dialog(
                    context,
                    title: 'Contact support',
                    message: 'Send a message to the LiveCare support team.',
                    fields: [
                      dialogField('Subject', hint: 'What do you need help with?', icon: Icons.subject),
                      dialogField('Message', hint: 'Describe the issue\u2026', icon: Icons.message_outlined),
                    ],
                    confirmLabel: 'Send',
                    onConfirm: () {},
                  ),
                  icon: const Icon(Icons.support_agent, size: 16),
                  label: const Text('Contact support'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
