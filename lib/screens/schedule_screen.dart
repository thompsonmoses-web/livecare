import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const List<String> _days = [
    'Tue\nOct 20', 'Wed\nOct 21', 'Thu\nOct 22', 'Fri\nOct 23',
    'Sat\nOct 24', 'Sun\nOct 25', 'Mon\nOct 26',
  ];

  /// One entry per visible row: name + role.
  late List<Map<String, String>> _staff;

  /// grid[row][day] = null (Off) or a cell map:
  ///   {'kind': 'shift', 'time': ..., 'client': ...}  or  {'kind': 'sick'}
  late List<List<Map<String, String>?>> _grid;

  int _chip = 0; // 0 All Staffs, 1 Caregivers, 2 Clients
  bool _week = true;

  static const String _kData = 'lc_schedule_v1';

  static const List<String> _seedNames = [
    'Mrs. Johnson', 'Mr. Williams', 'Mrs. Clark', 'Mr. Bello', 'Mrs. Fatima', 'Mr. Ibrahim',
  ];
  static const List<String> _seedClients = [
    'Client: Johnson', 'Client: Williams', 'Client: Clark',
    'Client: Bello', 'Client: Fatima', 'Client: Ibrahim',
  ];

  static List<Map<String, String>> _seedStaff() => [
        for (var i = 0; i < _seedNames.length; i++)
          {'name': _seedNames[i], 'role': 'Caregiver', 'client': _seedClients[i]},
      ];

  static List<List<Map<String, String>?>> _seedGrid() {
    final g = <List<Map<String, String>?>>[];
    for (var r = 0; r < _seedNames.length; r++) {
      final row = <Map<String, String>?>[];
      for (var d = 0; d < 7; d++) {
        final shift = {'kind': 'shift', 'time': '8:00 AM - 4:00 PM', 'client': _seedClients[r]};
        if (r == 4) {
          // Mrs. Fatima: sick on Thu, off Fri/Sat.
          if (d == 2) {
            row.add({'kind': 'sick'});
          } else if (d == 3 || d == 4) {
            row.add(null);
          } else {
            row.add(shift);
          }
        } else {
          // Others: off Sat/Sun.
          if (d == 4 || d == 5) {
            row.add(null);
          } else {
            row.add(shift);
          }
        }
      }
      g.add(row);
    }
    return g;
  }

  @override
  void initState() {
    super.initState();
    _staff = _seedStaff();
    _grid = _seedGrid();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kData);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final staff = (map['staff'] as List? ?? const [])
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
      final gridRaw = map['grid'] as List? ?? const [];
      final grid = gridRaw
          .map((row) => (row as List)
              .map((c) => c == null ? null : Map<String, String>.from(c as Map))
              .toList())
          .toList();
      if (staff.isNotEmpty && grid.length == staff.length && mounted) {
        setState(() {
          _staff = staff;
          _grid = grid;
        });
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kData, jsonEncode({'staff': _staff, 'grid': _grid}));
    } catch (_) {}
  }

  List<int> get _visibleRows {
    if (_chip == 1) {
      // Caregivers only.
      final out = <int>[];
      for (var i = 0; i < _staff.length; i++) {
        if (_staff[i]['role'] == 'Caregiver') out.add(i);
      }
      return out;
    }
    if (_chip == 2) {
      // Rows that have at least one live client assignment this week.
      final out = <int>[];
      for (var i = 0; i < _staff.length; i++) {
        if (_grid[i].any((c) => c != null && c['kind'] == 'shift')) out.add(i);
      }
      return out;
    }
    return List.generate(_staff.length, (i) => i);
  }

  void _editCell(int r, int d) {
    final cell = r < _grid.length && d < _grid[r].length ? _grid[r][d] : null;
    final initialKind = cell == null ? 'off' : (cell['kind'] ?? 'shift');
    final timeC = TextEditingController(text: cell?['time'] ?? '8:00 AM - 4:00 PM');
    final clientC = TextEditingController(text: cell?['client'] ?? _staff[r]['client'] ?? '');
    final staffName = _staff[r]['name'] ?? 'Staff';
    var kind = initialKind;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text('$staffName — ${_days[d].replaceAll('\n', ' ')}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _KindChip(label: 'Shift', selected: kind == 'shift',
                        onTap: () => setDlg(() => kind = 'shift')),
                    const SizedBox(width: 8),
                    _KindChip(label: 'Sick leave', selected: kind == 'sick',
                        onTap: () => setDlg(() => kind = 'sick')),
                    const SizedBox(width: 8),
                    _KindChip(label: 'Off', selected: kind == 'off',
                        onTap: () => setDlg(() => kind = 'off')),
                  ],
                ),
                const SizedBox(height: 16),
                if (kind == 'shift') ...[
                  _f('Shift time', timeC),
                  _f('Client', clientC),
                ] else
                  const Text('This day will be saved as shown above.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _grid[r][d] = null);
                _persist();
                AppNav.toast(context, '$staffName marked off');
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.red)),
            ),
            const Spacer(),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  if (kind == 'off') {
                    _grid[r][d] = null;
                  } else if (kind == 'sick') {
                    _grid[r][d] = {'kind': 'sick'};
                  } else {
                    _grid[r][d] = {
                      'kind': 'shift',
                      'time': timeC.text.trim().isEmpty ? '8:00 AM - 4:00 PM' : timeC.text.trim(),
                      'client': clientC.text.trim(),
                    };
                  }
                });
                _persist();
                AppNav.toast(context, '$staffName’s schedule updated');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _addRow() {
    final nameC = TextEditingController();
    final clientC = TextEditingController();
    final timeC = TextEditingController(text: '8:00 AM - 4:00 PM');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add shift', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add a caregiver and assign their weekday shift.',
                  style: TextStyle(fontSize: 13, color: AppColors.body)),
              const SizedBox(height: 14),
              _f('Caregiver name', nameC),
              _f('Client', clientC),
              _f('Shift time', timeC),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = nameC.text.trim();
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              setState(() {
                final client = clientC.text.trim().isEmpty ? 'Unassigned' : clientC.text.trim();
                _staff.add({'name': name, 'role': 'Caregiver', 'client': client});
                _grid.add([
                  for (var d = 0; d < 7; d++)
                    (d == 4 || d == 5)
                        ? null
                        : {
                            'kind': 'shift',
                            'time': timeC.text.trim().isEmpty ? '8:00 AM - 4:00 PM' : timeC.text.trim(),
                            'client': client,
                          },
                ]);
                _chip = 0;
              });
              _persist();
              AppNav.toast(context, '$name added to the schedule');
            },
            child: const Text('Add shift'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Schedule',
          subtitle: 'View and manage staff schedules, shifts and assignments.',
          trailing: Row(
            children: [
              FilledButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add shift'),
              ),
              const SizedBox(width: 12),
              _PillButton(
                label: 'Oct 20, 2026 - Oct 26, 2026',
                icon: Icons.calendar_today,
                onTap: () => AppNav.dialog(
                  context,
                  title: 'Week range',
                  message: 'Choose the week to view.',
                  fields: [
                    dialogField('Week of', hint: 'Oct 20, 2026', icon: Icons.calendar_today),
                  ],
                  confirmLabel: 'Apply',
                  onConfirm: () {},
                ),
              ),
              const SizedBox(width: 12),
              _WeekMonthToggle(week: _week, onChanged: (v) => setState(() => _week = v)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _FilterChip(label: 'All Staffs', active: _chip == 0, onTap: () => setState(() => _chip = 0)),
            const SizedBox(width: 10),
            _FilterChip(label: 'Caregivers', active: _chip == 1, onTap: () => setState(() => _chip = 1)),
            const SizedBox(width: 10),
            _FilterChip(label: 'Clients', active: _chip == 2, onTap: () => setState(() => _chip = 2)),
            const Spacer(),
            Text('Tap any cell to edit a shift',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Panel(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 960,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 150),
                        ..._days.map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
                                ),
                              ),
                            )),
                      ],
                    ),
                    const Divider(height: 24),
                    if (rows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                            child: Text('No rows match this filter.',
                                style: TextStyle(color: AppColors.muted, fontSize: 13))),
                      ),
                    ...rows.map((r) => _StaffRow(
                          name: _staff[r]['name'] ?? 'Staff',
                          role: _staff[r]['role'] ?? 'Caregiver',
                          cells: _grid[r],
                          onCell: (d) => _editCell(r, d),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
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
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.line),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.body,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
      ),
    );
  }
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

class _WeekMonthToggle extends StatelessWidget {
  const _WeekMonthToggle({this.week = true, this.onChanged});
  final bool week;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _Toggle(label: 'Week', active: week, onTap: () => onChanged?.call(true)),
          _Toggle(label: 'Month', active: !week, onTap: () => onChanged?.call(false)),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, this.active = false, this.onTap});
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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

class _StaffRow extends StatelessWidget {
  const _StaffRow({required this.name, required this.role, required this.cells, required this.onCell});

  final String name;
  final String role;
  final List<Map<String, String>?> cells;
  final void Function(int day) onCell;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Row(
              children: [
                Avatar(name: name, radius: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      Text(role,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(7, (d) {
            final cell = d < cells.length ? cells[d] : null;
            return Expanded(child: _cell(cell, d));
          }),
        ],
      ),
    );
  }

  Widget _cell(Map<String, String>? cell, int d) {
    if (cell == null) {
      return InkWell(
        onTap: () => onCell(d),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          child: const Text('Off', style: TextStyle(color: AppColors.muted, fontSize: 11)),
        ),
      );
    }
    final sick = cell['kind'] == 'sick';
    final fg = sick ? AppColors.amber : AppColors.green;
    final bg = sick ? AppColors.amberSoft : AppColors.greenSoft;
    return InkWell(
      onTap: () => onCell(d),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: fg.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sick ? 'Sick Leave' : (cell['time'] ?? ''),
              style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
            ),
            if (!sick) ...[
              const SizedBox(height: 2),
              Text(cell['client'] ?? '', style: TextStyle(color: fg, fontSize: 9)),
            ],
          ],
        ),
      ),
    );
  }
}
