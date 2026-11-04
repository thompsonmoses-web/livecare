import 'package:flutter/material.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class LiveMonitoringScreen extends StatelessWidget {
  const LiveMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['Mrs. Johnson', 'Room 2B', 'Ms. Adeyemi', '09:42 AM', '1h 12m', 'On track'],
      ['Mr. Williams', 'Room 1A', 'Mr. Eze', '09:15 AM', '1h 40m', 'On track'],
      ['Mrs. Clark', 'Room 3C', 'Mr. Oklor', '08:50 AM', '2h 13m', 'On track'],
      ['Mr. Bello', 'Room 2A', 'Ms. Adeyemi', '08:32 AM', '2h 31m', 'On track'],
      ['Mrs. Fatima', 'Room 4B', 'Mr. Tunde', '08:20 AM', '2h 45m', 'Late'],
      ['Mr. Ibrahim', 'Room 3B', 'Mr. Oklor', '07:58 AM', '3h 07m', 'On track'],
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Live Monitoring',
          subtitle: 'Monitor active sessions, caregiver check-ins and any flagged concerns.',
          trailing: Row(
            children: [
              _PillButton(label: 'Oct 20, 2026', icon: Icons.calendar_today),
              const SizedBox(width: 10),
              _PillButton(label: 'Filters', icon: Icons.tune),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: _TintedStat(
                label: 'Active Sessions', value: '18', badge: 'On track',
                color: AppColors.primary, bg: AppColors.primarySoft,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: _TintedStat(
                label: 'Check-ins Today', value: '20', badge: 'On time',
                color: AppColors.green, bg: AppColors.greenSoft,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: _TintedStat(
                label: 'Flagged Concerns', value: '2', badge: 'Needs attention',
                color: AppColors.red, bg: AppColors.redSoft,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: _TintedStat(
                label: 'Offline Caregivers', value: '1', badge: 'Action needed',
                color: AppColors.amber, bg: AppColors.amberSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Active Care Sessions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _HeaderRow(
                cols: const ['Client', 'Location', 'Caregiver', 'Check-in', 'Duration', 'Status', ''],
                widths: const [3, 2, 3, 2, 2, 2, 1],
              ),
              const Divider(height: 20),
              ...rows.map((r) => _SessionRow(r)),
            ],
          ),
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

class _TintedStat extends StatelessWidget {
  const _TintedStat({
    required this.label, required this.value, required this.badge,
    required this.color, required this.bg,
  });

  final String label;
  final String value;
  final String badge;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 5),
              Text(badge, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
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

class _SessionRow extends StatelessWidget {
  const _SessionRow(this.r);
  final List<String> r;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Avatar(name: r[0], radius: 15),
                const SizedBox(width: 8),
                Text(r[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(r[1], style: const TextStyle(fontSize: 13))),
          Expanded(flex: 3, child: Text(r[2], style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(r[3], style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(r[4], style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: statusBadge(r[5]))),
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () => AppNav.go(Screens.clients),
              child: const Text('View', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
