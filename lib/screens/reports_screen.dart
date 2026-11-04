import 'package:flutter/material.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      _Report('Session Summary', 'Total sessions, completed, missed and in progress', Icons.bar_chart, AppColors.primary,
          onTap: () => AppNav.go(Screens.liveMonitoring)),
      _Report('Incident Report', 'Incidents by type, status and resolution time', Icons.warning_amber, AppColors.amber,
          onTap: () => AppNav.go(Screens.incidents)),
      _Report('Caregiver Performance', 'Attendance, punctuality and session completion', Icons.emoji_people, AppColors.primary,
          onTap: () => AppNav.go(Screens.staff)),
      _Report('Client Activity', 'Care plans, activities and outcomes', Icons.directions_walk, AppColors.green,
          onTap: () => AppNav.go(Screens.clients)),
      _Report('Staff Roster', 'Schedule adherence and shift coverage', Icons.groups, AppColors.purple,
          onTap: () => AppNav.go(Screens.schedule)),
      _Report('Billing Summary', 'Service charges, payments and outstanding balances', Icons.payments, AppColors.primary,
          onTap: () => AppNav.go(Screens.billing)),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Reports',
          subtitle: 'Generate and view operational reports.',
          trailing: _PillButton(label: 'Oct 13, 2026 - Oct 20, 2026', icon: Icons.calendar_today),
        ),
        const SizedBox(height: 18),
        Row(
          children: const [
            _FilterChip(label: 'Operational', active: true),
            SizedBox(width: 10),
            _FilterChip(label: 'Care & Client'),
            SizedBox(width: 10),
            _FilterChip(label: 'Staff'),
            SizedBox(width: 10),
            _FilterChip(label: 'Billing'),
            SizedBox(width: 10),
            _FilterChip(label: 'Custom'),
          ],
        ),
        const SizedBox(height: 18),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Operational Reports',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: reports[0]),
                        const SizedBox(width: 12),
                        Expanded(child: reports[1]),
                        const SizedBox(width: 12),
                        Expanded(child: reports[2]),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: reports[3]),
                        const SizedBox(width: 12),
                        Expanded(child: reports[4]),
                        const SizedBox(width: 12),
                        Expanded(child: reports[5]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(flex: 1, child: _RecentReports()),
          ],
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.primary : AppColors.line),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: active ? Colors.white : AppColors.body,
            fontWeight: FontWeight.w600,
            fontSize: 13),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report(this.title, this.caption, this.icon, this.color, {this.onTap});

  final String title;
  final String caption;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () => AppNav.dialog(
                context,
                title: title,
                message: 'Set options to generate this report.',
                fields: [
                  dialogField('Date range', hint: 'This month', icon: Icons.calendar_today_outlined),
                  dialogField('Format', hint: 'PDF or CSV', icon: Icons.insert_drive_file_outlined),
                ],
                confirmLabel: 'Generate',
                onConfirm: () {},
              ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Text(caption,
                style: const TextStyle(color: AppColors.muted, fontSize: 12), maxLines: 2),
            const SizedBox(height: 10),
            Row(
              children: const [
                Text('View report',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      ['Session Summary', 'Oct 13 - Oct 20, 2026', 'Generated 2 hours ago'],
      ['Incident Report', 'Oct 13 - Oct 20, 2026', 'Generated 3 hours ago'],
      ['Staff Roster', 'Oct 13 - Oct 19, 2026', 'Generated 5 hours ago'],
      ['Billing Summary', 'Oct 13 - Oct 20, 2026', 'Generated 1 day ago'],
    ];

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.description, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(i[1], style: const TextStyle(color: AppColors.body, fontSize: 11)),
                          Text(i[2], style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => AppNav.dialog(
                context,
                title: 'All reports',
                message: '6 report types available.',
                fields: [
                  dialogInfo('Session Summary', 'Ready'),
                  dialogInfo('Incident Report', 'Ready'),
                  dialogInfo('Caregiver Performance', 'Ready'),
                  dialogInfo('Client Activity', 'Ready'),
                  dialogInfo('Staff Roster', 'Ready'),
                  dialogInfo('Billing Summary', 'Ready'),
                ],
                confirmLabel: 'Close',
                onConfirm: () {},
              ),
              child: const Text('View all reports'),
            ),
          ),
        ],
      ),
    );
  }
}
