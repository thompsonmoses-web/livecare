import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  static const List<String> _chipLabels = ['All', 'Open', 'In Progress', 'Resolved'];

  int _chip = 0;

  final List<Map<String, String>> _incidents = [
    {'id': 'INC-0007', 'date': 'Oct 20, 2026 12:04 PM', 'client': 'Mrs. Johnson', 'type': 'Fall', 'reporter': 'Mrs. Adeyemi', 'status': 'Open', 'notes': 'Fall in the hallway. No visible injury — assessed and monitored.'},
    {'id': 'INC-0006', 'date': 'Oct 19, 2026 04:12 PM', 'client': 'Mr. Bello', 'type': 'Medication Issue', 'reporter': 'Mr. Williams', 'status': 'In Progress', 'notes': 'Dose given 40 minutes late. Pharmacy schedule under review.'},
    {'id': 'INC-0005', 'date': 'Oct 18, 2026 11:03 AM', 'client': 'Mrs. Fatima', 'type': 'Behavioral concern', 'reporter': 'Mr. Clark', 'status': 'Open', 'notes': 'Agitation during evening care. Family notified.'},
    {'id': 'INC-0004', 'date': 'Oct 17, 2026 09:45 AM', 'client': 'Mr. Ibrahim', 'type': 'Health concern', 'reporter': 'Mr. Bello', 'status': 'Resolved', 'notes': 'Elevated BP, treated and rechecked. Returned to normal.'},
    {'id': 'INC-0003', 'date': 'Oct 16, 2026 03:30 PM', 'client': 'Mrs. Johnson', 'type': 'Missed medication', 'reporter': 'Mrs. Fatima', 'status': 'In Progress', 'notes': 'Evening dose missed. Reminder system being updated.'},
    {'id': 'INC-0002', 'date': 'Oct 15, 2026 01:12 PM', 'client': 'Mr. Williams', 'type': 'Client refusal', 'reporter': 'Mr. Ibrahim', 'status': 'Resolved', 'notes': 'Refused bath; consent documented and follow-up scheduled.'},
    {'id': 'INC-0001', 'date': 'Oct 14, 2026 08:50 AM', 'client': 'Mr. Clark', 'type': 'Injury', 'reporter': 'Mr. Clark', 'status': 'Resolved', 'notes': 'Minor bruise from a wheelchair transfer. Treated on site.'},
  ];

  static const String _kData = 'lc_incidents_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kData);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final items = list
          .map((e) => Map<String, String>.from(e as Map))
          .where((m) => m['id'] != null)
          .toList();
      if (items.isNotEmpty && mounted) setState(() => _incidents..clear()..addAll(items));
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kData, jsonEncode(_incidents));
    } catch (_) {}
  }

  void _toast(String m) => AppNav.toast(context, m);

  int _count(String status) => _incidents.where((i) => i['status'] == status).length;

  List<int> get _visible {
    final out = <int>[];
    for (var i = 0; i < _incidents.length; i++) {
      if (_chip != 0 && _incidents[i]['status'] != _chipLabels[_chip]) continue;
      out.add(i);
    }
    return out;
  }

  String _nextId() {
    var m = 0;
    for (final i in _incidents) {
      final n = int.tryParse((i['id'] ?? '').split('-').last) ?? 0;
      if (n > m) m = n;
    }
    return 'INC-${(m + 1).toString().padLeft(4, '0')}';
  }

  // ---------- dialogs ----------
  void _openReport() {
    final clientC = TextEditingController();
    final typeC = TextEditingController(text: 'Fall');
    final reporterC = TextEditingController();
    final statusC = TextEditingController(text: 'Open');
    final notesC = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report incident', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _f('Client', clientC),
                _f('Type', typeC),
                _f('Reported by', reporterC),
                _f('Status', statusC),
                _f('Notes', notesC),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final client = clientC.text.trim();
              if (client.isEmpty) return;
              Navigator.of(ctx).pop();
              setState(() => _incidents.insert(0, {
                    'id': _nextId(),
                    'date': 'Just now',
                    'client': client,
                    'type': typeC.text.trim().isEmpty ? 'Health concern' : typeC.text.trim(),
                    'reporter': reporterC.text.trim().isEmpty ? '—' : reporterC.text.trim(),
                    'status': statusC.text.trim().isEmpty ? 'Open' : statusC.text.trim(),
                    'notes': notesC.text.trim(),
                  }));
              _persist();
              _toast('Incident reported for $client');
            },
            child: const Text('Report incident'),
          ),
        ],
      ),
    );
  }

  void _openEdit(int i) {
    final inc = _incidents[i];
    final clientC = TextEditingController(text: inc['client']);
    final typeC = TextEditingController(text: inc['type']);
    final reporterC = TextEditingController(text: inc['reporter']);
    final statusC = TextEditingController(text: inc['status']);
    final dateC = TextEditingController(text: inc['date']);
    final notesC = TextEditingController(text: inc['notes']);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${inc['id']} — ${inc['type']}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(inc['notes'] ?? '',
                    style: const TextStyle(fontSize: 13, color: AppColors.body, height: 1.4)),
                const Divider(height: 22),
                _f('Client', clientC),
                _f('Type', typeC),
                _f('Reported by', reporterC),
                _f('Status', statusC),
                _f('Date & time', dateC),
                _f('Notes', notesC),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _incidents.removeAt(i));
              _persist();
              _toast('${inc['id']} deleted');
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
          const Spacer(),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _incidents[i] = {
                    ...inc,
                    'client': clientC.text.trim().isEmpty ? inc['client']! : clientC.text.trim(),
                    'type': typeC.text.trim(),
                    'reporter': reporterC.text.trim(),
                    'status': statusC.text.trim().isEmpty ? 'Open' : statusC.text.trim(),
                    'date': dateC.text.trim(),
                    'notes': notesC.text.trim(),
                  });
              _persist();
              _toast('${inc['id']} updated');
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }

  void _rowMenu(int i) {
    final inc = _incidents[i];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${inc['type']} — ${inc['client']}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${inc['id']}  •  ${inc['date']}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 8),
              Text(inc['notes'] ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                title: const Text('View / edit details', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openEdit(i);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.timelapse, size: 18, color: AppColors.amber),
                title: const Text('Mark as In Progress', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _incidents[i] = {...inc, 'status': 'In Progress'});
                  _persist();
                  _toast('${inc['id']} marked In Progress');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.green),
                title: const Text('Mark as Resolved', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _incidents[i] = {...inc, 'status': 'Resolved'});
                  _persist();
                  _toast('${inc['id']} resolved');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                title: const Text('Delete incident', style: TextStyle(fontSize: 14, color: AppColors.red)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _incidents.removeAt(i));
                  _persist();
                  _toast('${inc['id']} deleted');
                },
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Incidents',
          subtitle: 'View and manage incidents, concerns and follow ups.',
          trailing: Row(
            children: [
              FilledButton.icon(
                onPressed: _openReport,
                icon: const Icon(Icons.add_alert, size: 16),
                label: const Text('Report incident'),
              ),
              const SizedBox(width: 10),
              _PillButton(
                label: 'Oct 20, 2026 - Oct 20, 2026',
                icon: Icons.calendar_today,
                onTap: () => AppNav.dialog(
                  context,
                  title: 'Incident date range',
                  message: 'Choose the period to report on.',
                  fields: [
                    dialogField('From', hint: 'Oct 20, 2026', icon: Icons.calendar_today),
                    dialogField('To', hint: 'Oct 20, 2026', icon: Icons.calendar_today),
                  ],
                  confirmLabel: 'Apply',
                  onConfirm: () {},
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: () => AppNav.dialog(
                  context,
                  title: 'Export incidents',
                  message: 'Choose a format and date range for the export.',
                  fields: [
                    dialogField('Format', hint: 'PDF or CSV', icon: Icons.insert_drive_file_outlined),
                    dialogField('Date range', hint: 'Oct 1 - Oct 20, 2026', icon: Icons.calendar_today_outlined),
                  ],
                  confirmLabel: 'Export',
                  onConfirm: () {},
                ),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (var i = 0; i < _chipLabels.length; i++) ...[
              _FilterChip(
                label: i == 0 ? 'All (${_incidents.length})' : '${_chipLabels[i]} (${_count(_chipLabels[i])})',
                active: _chip == i,
                onTap: () => setState(() => _chip = i),
              ),
              if (i != _chipLabels.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(
                cols: const ['Date & Time', 'Client', 'Type', 'Reported by', 'Status', ''],
                widths: const [3, 2, 2, 2, 2, 1],
              ),
              const Divider(height: 22),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child: Text('No incidents in this status.',
                          style: TextStyle(color: AppColors.muted, fontSize: 13))),
                ),
              ...visible.map((i) => _IncidentRow(
                    _incidents[i],
                    onTap: () => _openEdit(i),
                    onMore: () => _rowMenu(i),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Showing ${visible.length} of ${_incidents.length} incidents',
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

Widget _f(String label, TextEditingController c) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          maxLines: label == 'Notes' ? 3 : 1,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.body),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false, this.onTap});
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: active ? Colors.white : AppColors.body, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.cols, required this.widths});
  final List<String> cols;
  final List<int> widths;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < cols.length; i++)
          Expanded(
            flex: widths[i],
            child: Text(cols[i],
                style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.tone});
  final String label;
  final String tone;

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (tone) {
      case 'red':
        c = AppColors.red;
        break;
      case 'amber':
        c = AppColors.amber;
        break;
      case 'purple':
        c = AppColors.purple;
        break;
      default:
        c = AppColors.primary;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: c),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label,
              style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _IncidentRow extends StatelessWidget {
  const _IncidentRow(this.r, {required this.onTap, required this.onMore});
  final Map<String, String> r;
  final VoidCallback onTap;
  final VoidCallback onMore;

  String get _tone {
    final l = (r['type'] ?? '').toLowerCase();
    if (l.contains('fall') || l.contains('injury')) return 'red';
    if (l.contains('medication')) return 'amber';
    if (l.contains('behavioral') || l.contains('refusal')) return 'purple';
    return 'blue';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(r['date'] ?? '', style: const TextStyle(fontSize: 13))),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Avatar(name: r['client'] ?? '', radius: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r['client'] ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: _TypeChip(label: r['type'] ?? '', tone: _tone)),
            Expanded(flex: 2, child: Text(r['reporter'] ?? '', style: const TextStyle(fontSize: 13))),
            Expanded(
                flex: 2,
                child: Align(alignment: Alignment.centerLeft, child: statusBadge(r['status'] ?? ''))),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: onMore,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.more_vert, size: 18, color: AppColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
