import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  static const List<String> _tabs = ['Overview', 'Invoices', 'Payments', 'Clients', 'Settings'];
  int _tab = 1; // "Invoices" is the active tab in the design.

  final List<Map<String, String>> _invoices = [
    {'id': 'INV-2026-1045', 'client': 'Mrs. Johnson', 'period': 'Oct 13 - Oct 19, 2026', 'amount': '\u20A6 680,000', 'status': 'Paid', 'due': 'Oct 28, 2026'},
    {'id': 'INV-2026-1044', 'client': 'Mr. Williams', 'period': 'Oct 13 - Oct 19, 2026', 'amount': '\u20A6 450,000', 'status': 'Paid', 'due': 'Oct 26, 2026'},
    {'id': 'INV-2026-1043', 'client': 'Mrs. Clark', 'period': 'Oct 6 - Oct 12, 2026', 'amount': '\u20A6 720,000', 'status': 'Pending', 'due': 'Oct 28, 2026'},
    {'id': 'INV-2026-1042', 'client': 'Mr. Bello', 'period': 'Oct 6 - Oct 12, 2026', 'amount': '\u20A6 520,000', 'status': 'Paid', 'due': 'Oct 22, 2026'},
    {'id': 'INV-2026-1041', 'client': 'Mrs. Fatima', 'period': 'Sep 29 - Oct 5, 2026', 'amount': '\u20A6 610,000', 'status': 'Overdue', 'due': 'Oct 18, 2026'},
  ];

  final List<Map<String, String>> _payments = [
    {'date': 'Oct 19, 2026', 'client': 'Mrs. Johnson', 'amount': '\u20A6 680,000', 'method': 'Bank Transfer', 'status': 'Paid'},
    {'date': 'Oct 18, 2026', 'client': 'Mr. Williams', 'amount': '\u20A6 450,000', 'method': 'Card', 'status': 'Paid'},
    {'date': 'Oct 16, 2026', 'client': 'Mrs. Clark', 'amount': '\u20A6 720,000', 'method': 'Bank Transfer', 'status': 'Paid'},
    {'date': 'Oct 14, 2026', 'client': 'Mr. Bello', 'amount': '\u20A6 520,000', 'method': 'Card', 'status': 'Paid'},
    {'date': 'Oct 12, 2026', 'client': 'Mrs. Fatima', 'amount': '\u20A6 610,000', 'method': 'Bank Transfer', 'status': 'Pending'},
  ];

  Map<String, String> _settings = {
    'Invoice prefix': 'INV-2026-',
    'Payment terms': 'Net 14 days',
    'Currency': '\u20A6 Nigerian Naira',
    'Tax rate': '7.5%',
    'Late fee': '\u20A6 25,000',
  };

  static const String _kInv = 'lc_invoices_v1';
  static const String _kPay = 'lc_payments_v1';
  static const String _kSet = 'lc_bill_settings_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final iRaw = prefs.getString(_kInv);
      final pRaw = prefs.getString(_kPay);
      final sRaw = prefs.getString(_kSet);
      var changed = false;
      if (iRaw != null) {
        final list = jsonDecode(iRaw) as List<dynamic>;
        final inv = list
            .map((e) => Map<String, String>.from(e as Map))
            .where((m) => m['id'] != null)
            .toList();
        if (inv.isNotEmpty) {
          _invoices
            ..clear()
            ..addAll(inv);
          changed = true;
        }
      }
      if (pRaw != null) {
        final list = jsonDecode(pRaw) as List<dynamic>;
        final pay = list.map((e) => Map<String, String>.from(e as Map)).toList();
        if (pay.isNotEmpty) {
          _payments
            ..clear()
            ..addAll(pay);
          changed = true;
        }
      }
      if (sRaw != null) {
        final map = Map<String, String>.from(jsonDecode(sRaw) as Map);
        if (map.isNotEmpty) {
          _settings = map;
          changed = true;
        }
      }
      if (changed && mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kInv, jsonEncode(_invoices));
      await prefs.setString(_kPay, jsonEncode(_payments));
      await prefs.setString(_kSet, jsonEncode(_settings));
    } catch (_) {}
  }

  void _toast(String m) => AppNav.toast(context, m);

  int _nextInvoiceNum() {
    var m = 1045;
    for (final i in _invoices) {
      final n = int.tryParse((i['id'] ?? '').split('-').last) ?? 0;
      if (n > m) m = n;
    }
    return m + 1;
  }

  // ---------- Invoice editing ----------
  void _openInvoice(int i) {
    final inv = _invoices[i];
    final clientC = TextEditingController(text: inv['client']);
    final periodC = TextEditingController(text: inv['period']);
    final amountC = TextEditingController(text: inv['amount']);
    final statusC = TextEditingController(text: inv['status']);
    final dueC = TextEditingController(text: inv['due']);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${inv['id']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _f('Client', clientC),
                _f('Service period', periodC),
                _f('Amount', amountC),
                _f('Status', statusC),
                _f('Due date', dueC),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _invoices.removeAt(i));
              _persist();
              _toast('Invoice ${inv['id']} deleted');
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
          const Spacer(),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _invoices[i] = {
                    ...inv,
                    'client': clientC.text.trim().isEmpty ? inv['client']! : clientC.text.trim(),
                    'period': periodC.text.trim(),
                    'amount': amountC.text.trim(),
                    'status': statusC.text.trim().isEmpty ? 'Pending' : statusC.text.trim(),
                    'due': dueC.text.trim(),
                  });
              _persist();
              _toast('${inv['id']} updated');
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }

  void _createInvoice() {
    final clientC = TextEditingController();
    final periodC = TextEditingController(text: 'Oct 20 - Oct 26, 2026');
    final amountC = TextEditingController();
    final statusC = TextEditingController(text: 'Pending');
    final dueC = TextEditingController(text: 'Nov 3, 2026');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create invoice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _f('Client', clientC),
                _f('Service period', periodC),
                _f('Amount', amountC),
                _f('Status', statusC),
                _f('Due date', dueC),
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
              final id = 'INV-2026-${_nextInvoiceNum().toString().padLeft(4, '0')}';
              setState(() => _invoices.insert(0, {
                    'id': id,
                    'client': client,
                    'period': periodC.text.trim(),
                    'amount': amountC.text.trim().isEmpty ? '\u20A6 0' : amountC.text.trim(),
                    'status': statusC.text.trim().isEmpty ? 'Pending' : statusC.text.trim(),
                    'due': dueC.text.trim(),
                  }));
              _persist();
              _toast('$id created');
            },
            child: const Text('Create invoice'),
          ),
        ],
      ),
    );
  }

  void _recordPayment() {
    final clientC = TextEditingController();
    final amountC = TextEditingController();
    final methodC = TextEditingController(text: 'Bank Transfer');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _f('Client', clientC),
              _f('Amount', amountC),
              _f('Method', methodC),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final client = clientC.text.trim();
              if (client.isEmpty) return;
              Navigator.of(ctx).pop();
              setState(() => _payments.insert(0, {
                    'date': 'Today',
                    'client': client,
                    'amount': amountC.text.trim().isEmpty ? '\u20A6 0' : amountC.text.trim(),
                    'method': methodC.text.trim().isEmpty ? 'Cash' : methodC.text.trim(),
                    'status': 'Paid',
                  }));
              _persist();
              _toast('Payment recorded for $client');
            },
            child: const Text('Record payment'),
          ),
        ],
      ),
    );
  }

  void _editSettings() {
    _editMap(
      context,
      title: 'Billing settings',
      values: Map.of(_settings),
      onSave: (m) {
        setState(() => _settings = m);
        _persist();
        _toast('Billing settings saved');
      },
    );
  }

  // ---------- Derived ----------
  static int _amountOf(String s) => int.tryParse(s.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

  static String _group(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Map<String, List<int>> get _byClient {
    final out = <String, List<int>>{};
    for (final inv in _invoices) {
      final c = inv['client'] ?? '—';
      final amt = _amountOf(inv['amount'] ?? '');
      final e = out.putIfAbsent(c, () => [0, 0, 0]);
      e[0] += amt; // billed
      e[2] += 1; // count
      if ((inv['status'] ?? '').toLowerCase() == 'paid') e[1] += amt; // paid
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Billing',
          subtitle: 'Manage invoices, payments and financial records.',
          trailing: Row(
            children: [
              _PillButton(
                label: 'Oct 13, 2026 - Oct 26, 2026',
                icon: Icons.calendar_today,
                onTap: () => AppNav.dialog(
                  context,
                  title: 'Billing period',
                  message: 'Choose the date range to report on.',
                  fields: [
                    dialogField('From', hint: 'Oct 13, 2026', icon: Icons.calendar_today),
                    dialogField('To', hint: 'Oct 26, 2026', icon: Icons.calendar_today),
                  ],
                  confirmLabel: 'Apply',
                  onConfirm: () {},
                ),
              ),
              const SizedBox(width: 10),
              _PillButton(
                label: 'Filter',
                icon: Icons.tune,
                onTap: () => AppNav.dialog(
                  context,
                  title: 'Filter invoices',
                  message: 'Narrow the list by status or client.',
                  fields: [
                    dialogField('Status', hint: 'Paid, Pending, Overdue', icon: Icons.filter_list),
                    dialogField('Client', hint: 'Any client', icon: Icons.person_outline),
                  ],
                  confirmLabel: 'Apply',
                  onConfirm: () {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: const [
            Expanded(child: _TintedStat(label: 'Total Billed', value: '\u20A6 4,582,000', delta: '\u2191 12% vs. previous period', color: AppColors.primary, bg: AppColors.primarySoft)),
            SizedBox(width: 14),
            Expanded(child: _TintedStat(label: 'Paid', value: '\u20A6 3,892,000', delta: '\u2191 18% vs. previous period', color: AppColors.green, bg: AppColors.greenSoft)),
            SizedBox(width: 14),
            Expanded(child: _TintedStat(label: 'Outstanding', value: '\u20A6 690,000', delta: '\u2193 5% vs. previous period', color: AppColors.amber, bg: AppColors.amberSoft)),
            SizedBox(width: 14),
            Expanded(child: _TintedStat(label: 'Overdue', value: '\u20A6 320,000', delta: '3 invoices', color: AppColors.red, bg: AppColors.redSoft)),
          ],
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
        const SizedBox(height: 16),
        _tabBody(),
      ],
    );
  }

  Widget _tabBody() {
    switch (_tab) {
      case 0: // Overview
        return Column(
          children: [
            _StatusSummary(invoices: _invoices),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _RevenueSummary()),
                const SizedBox(width: 14),
                Expanded(flex: 3, child: _quickActions()),
              ],
            ),
          ],
        );
      case 2: // Payments
        return Column(
          children: [
            _PaymentHistory(_payments, onRecord: _recordPayment),
          ],
        );
      case 3: // Clients
        return _ClientBilling(byClient: _byClient);
      case 4: // Settings
        return _BillingSettings(settings: _settings, onEdit: _editSettings);
      default: // 1 — Invoices (the full design layout)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Recent Invoices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _tab = 2),
                        child: const Text('View all payments',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HeaderRow(
                    cols: const ['Invoice #', 'Client', 'Service period', 'Amount', 'Status', 'Due date', 'Actions'],
                    widths: const [2, 2, 3, 2, 2, 2, 1],
                  ),
                  const Divider(height: 20),
                  if (_invoices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: Text('No invoices yet.', style: TextStyle(color: AppColors.muted, fontSize: 13))),
                    ),
                  for (var i = 0; i < _invoices.length; i++)
                    _InvoiceRow(_invoices[i], onEdit: () => _openInvoice(i)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _RevenueSummary()),
                const SizedBox(width: 14),
                Expanded(flex: 3, child: _PaymentHistory(_payments, onRecord: _recordPayment)),
              ],
            ),
            const SizedBox(height: 14),
            _quickActions(),
          ],
        );
    }
  }

  Widget _quickActions() {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ActionTile(label: 'Create invoice', icon: Icons.add_circle_outline, onTap: _createInvoice)),
              const SizedBox(width: 12),
              Expanded(child: _ActionTile(label: 'Record payment', icon: Icons.payments_outlined, onTap: _recordPayment)),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionTile(
                label: 'View unpaid invoices',
                icon: Icons.receipt_long_outlined,
                onTap: () => AppNav.dialog(
                  context,
                  title: 'Unpaid invoices',
                  message: 'Invoices still awaiting payment.',
                  fields: [
                    for (final inv in _invoices)
                      if ((inv['status'] ?? '').toLowerCase() != 'paid')
                        dialogInfo(inv['id']!, '${inv['client']} — ${inv['amount']}'),
                  ],
                  confirmLabel: 'Close',
                  onConfirm: () {},
                ),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionTile(
                label: 'Generate report',
                icon: Icons.insert_chart_outlined,
                onTap: () => AppNav.go(Screens.reports),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- shared field helpers ----------
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

Future<void> _editMap(
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
              for (var e in values.entries) _f(e.key, ctrls[e.key]!),
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

// ---------- widgets ----------
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

class _TintedStat extends StatelessWidget {
  const _TintedStat({
    required this.label, required this.value, required this.delta,
    required this.color, required this.bg,
  });

  final String label;
  final String value;
  final String delta;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          Text(delta, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
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

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow(this.inv, {required this.onEdit});
  final Map<String, String> inv;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(inv['id']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Avatar(name: inv['client']!, radius: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(inv['client']!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          Expanded(flex: 3, child: Text(inv['period']!, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(inv['amount']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: statusBadge(inv['status']!))),
          Expanded(flex: 2, child: Text(inv['due']!, style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: onEdit,
              child: const Text('Edit', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary({required this.invoices});
  final List<Map<String, String>> invoices;

  @override
  Widget build(BuildContext context) {
    var paid = 0, pending = 0, overdue = 0;
    for (final i in invoices) {
      final s = (i['status'] ?? '').toLowerCase();
      if (s == 'paid') {
        paid++;
      } else if (s == 'overdue') {
        overdue++;
      } else {
        pending++;
      }
    }
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invoice status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('A snapshot of every invoice in this period.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Paid', value: '$paid', color: AppColors.green, bg: AppColors.greenSoft)),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(label: 'Pending', value: '$pending', color: AppColors.amber, bg: AppColors.amberSoft)),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(label: 'Overdue', value: '$overdue', color: AppColors.red, bg: AppColors.redSoft)),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(label: 'Total', value: '${invoices.length}', color: AppColors.primary, bg: AppColors.primarySoft)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color, required this.bg});
  final String label;
  final String value;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ClientBilling extends StatelessWidget {
  const _ClientBilling({required this.byClient});
  final Map<String, List<int>> byClient;

  @override
  Widget build(BuildContext context) {
    final entries = byClient.entries.toList()
      ..sort((a, b) => b.value[0].compareTo(a.value[0]));
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billing by client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Totals calculated from the invoices in this period.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          _HeaderRow(
            cols: const ['Client', 'Invoices', 'Billed', 'Paid', 'Outstanding'],
            widths: const [3, 2, 2, 2, 2],
          ),
          const Divider(height: 20),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Avatar(name: e.key, radius: 14),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(e.key,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  Expanded(flex: 2, child: Text('${e.value[2]}', style: const TextStyle(fontSize: 13))),
                  Expanded(
                      flex: 2,
                      child: Text('\u20A6 ${_BillingScreenState._group(e.value[0])}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 2,
                      child: Text('\u20A6 ${_BillingScreenState._group(e.value[1])}',
                          style: const TextStyle(fontSize: 13, color: AppColors.green))),
                  Expanded(
                      flex: 2,
                      child: Text('\u20A6 ${_BillingScreenState._group(e.value[0] - e.value[1])}',
                          style: const TextStyle(fontSize: 13, color: AppColors.amber))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RevenueSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['Oct 13', '14', '15', '16', '17', '18', '19'];
    const billed = [0.5, 0.7, 0.4, 0.9, 0.6, 0.8, 1.0];
    const paid = [0.4, 0.5, 0.35, 0.7, 0.5, 0.6, 0.8];

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Revenue summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Text('Last 7 days', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('\u20A6 4,582,000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const Text('Total billed', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 140 * billed[i],
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Container(
                                    height: 140 * paid[i],
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(days[i], style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.primary, label: 'Billed'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.primary.withValues(alpha: 0.35), label: 'Paid'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.body)),
      ],
    );
  }
}

class _PaymentHistory extends StatelessWidget {
  const _PaymentHistory(this.rows, {this.onRecord});
  final List<Map<String, String>> rows;
  final VoidCallback? onRecord;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Payment history', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              TextButton(onPressed: onRecord, child: const Text('Record payment',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 12),
          _HeaderRow(
            cols: const ['Date', 'Client', 'Amount', 'Method', 'Status'],
            widths: const [2, 2, 2, 2, 2],
          ),
          const Divider(height: 20),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No payments yet.', style: TextStyle(color: AppColors.muted, fontSize: 13))),
            ),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(r['date']!, style: const TextStyle(fontSize: 13))),
                    Expanded(flex: 2, child: Text(r['client']!, style: const TextStyle(fontSize: 13))),
                    Expanded(
                        flex: 2,
                        child: Text(r['amount']!,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                    Expanded(flex: 2, child: Text(r['method']!, style: const TextStyle(fontSize: 13))),
                    Expanded(
                        flex: 2,
                        child: Align(alignment: Alignment.centerLeft, child: statusBadge(r['status']!))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _BillingSettings extends StatelessWidget {
  const _BillingSettings({required this.settings, required this.onEdit});
  final Map<String, String> settings;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Billing settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              InkWell(
                onTap: onEdit,
                child: const Text('Edit',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Invoice numbering, terms and currency preferences.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 16),
          for (var e in settings.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.key, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () => AppNav.dialog(
                context,
                title: label,
                message: 'Confirm to continue.',
                fields: [
                  dialogField('Reference', hint: 'Optional note', icon: Icons.edit_note),
                ],
                confirmLabel: 'Continue',
                onConfirm: () {},
              ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
