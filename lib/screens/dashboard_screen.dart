import 'package:flutter/material.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // "Today" is pinned to the mockup date so the header matches the design.
  static final DateTime _today = DateTime(2026, 10, 20);
  DateTime _selectedDate = DateTime(2026, 10, 20);

  String get _dateLabel {
    final isToday = _selectedDate.year == _today.year &&
        _selectedDate.month == _today.month &&
        _selectedDate.day == _today.day;
    final date =
        '${_selectedDate.day} ${_months[_selectedDate.month - 1]}, ${_selectedDate.year}';
    return isToday ? 'Today, $date' : date;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      if (mounted) AppNav.toast(context, 'Showing overview for $_dateLabel');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Dashboard',
          subtitle: "Here's what's happening with your agency today.",
          trailing: _DatePill(label: _dateLabel, onTap: _pickDate),
        ),
        const SizedBox(height: 18),

        // Stat cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Active Care Sessions',
                value: '18',
                caption: 'of 24 scheduled',
                icon: Icons.calendar_month,
                accent: AppColors.primary,
                onTap: () => AppNav.go(Screens.schedule),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StatCard(
                label: 'Clients',
                value: '42',
                caption: 'Total active clients',
                icon: Icons.people,
                iconColor: AppColors.primary,
                onTap: () => AppNav.go(Screens.clients),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StatCard(
                label: 'Caregivers',
                value: '28',
                caption: 'Active staff',
                icon: Icons.badge,
                iconColor: AppColors.primary,
                onTap: () => AppNav.go(Screens.staff),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StatCard(
                label: 'Pending Approvals',
                value: '5',
                caption: 'Staff / documents',
                icon: Icons.pending_actions,
                iconColor: AppColors.amber,
                onTap: () => AppNav.go(Screens.staff),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Three columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _RecentActivity()),
            const SizedBox(width: 14),
            Expanded(flex: 3, child: _UpcomingSessions()),
            const SizedBox(width: 14),
            Expanded(flex: 2, child: _QuickActions()),
          ],
        ),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

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
            const Icon(Icons.calendar_today, size: 15, color: AppColors.body),
            const SizedBox(width: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.child, this.action = 'View all', this.onViewAll});

  final String title;
  final String action;
  final Widget child;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              if (action.isNotEmpty)
                InkWell(
                  onTap: onViewAll,
                  child: Text(action,
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile(
      {required this.time,
      required this.title,
      required this.caption,
      required this.status,
      this.onTap});

  final String time;
  final String title;
  final String caption;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Text(time,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(caption, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            statusBadge(status),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recent Activity',
      onViewAll: () => AppNav.go(Screens.liveMonitoring),
      child: Column(
        children: [
          _ActivityTile(
            time: '09:42 AM',
            title: 'Mrs. Adeyemi checked in for care session',
            caption: 'Client: Mrs. Johnson • Room 2B',
            status: 'On track',
            onTap: () => AppNav.go(Screens.liveMonitoring),
          ),
          _ActivityTile(
            time: '09:15 AM',
            title: 'Incident reported',
            caption: 'Client: Mr. Williams • Fall risk',
            status: 'Needs review',
            onTap: () => AppNav.go(Screens.incidents),
          ),
          _ActivityTile(
            time: '09:00 AM',
            title: 'New staff application',
            caption: 'Tunde Adeyemi • Caregiver',
            status: 'Pending',
            onTap: () => AppNav.go(Screens.staff),
          ),
          _ActivityTile(
            time: '08:32 AM',
            title: 'Care plan updated',
            caption: 'Client: Mrs. Clark',
            status: 'Updated',
            onTap: () => AppNav.go(Screens.clients),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.time, required this.name, required this.caption, required this.status});

  final String time;
  final String name;
  final String caption;
  final String status;

  void _openDetails(BuildContext context) {
    AppNav.dialog(
      context,
      title: name,
      message: 'Care session details',
      fields: [
        dialogInfo('Time', time),
        dialogInfo('Details', caption),
        dialogInfo('Status', status),
      ],
      confirmLabel: 'Open Schedule',
      onConfirm: () => AppNav.go(Screens.schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$time  •  $name',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(caption, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            statusBadge(status),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSessions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Upcoming Sessions',
      onViewAll: () => AppNav.go(Screens.schedule),
      child: Column(
        children: const [
          _SessionTile(
              time: '10:00 AM',
              name: 'Mrs. Johnson',
              caption: 'Room 2B • Caregiver: Ms. Adeyemi',
              status: 'In progress'),
          _SessionTile(
              time: '11:30 AM',
              name: 'Mr. Williams',
              caption: 'Room 1A • Caregiver: Mr. Eze',
              status: 'Scheduled'),
          _SessionTile(
              time: '01:00 PM',
              name: 'Mrs. Clark',
              caption: 'Room 3C • Caregiver: Mr. Oklor',
              status: 'Scheduled'),
          _SessionTile(
              time: '03:30 PM',
              name: 'Mr. Bello',
              caption: 'Room 2A • Caregiver: Ms. Adeyemi',
              status: 'Scheduled'),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Quick Actions',
      action: '',
      child: Column(
        children: [
          _ActionTile(
            label: 'View Live Sessions',
            icon: Icons.play_circle_outline,
            onTap: () => AppNav.go(Screens.liveMonitoring),
          ),
          _ActionTile(
            label: 'Manage Clients',
            icon: Icons.people_outline,
            onTap: () => AppNav.go(Screens.clients),
          ),
          _ActionTile(
            label: 'Review Staff Approvals',
            icon: Icons.how_to_reg_outlined,
            onTap: () => AppNav.go(Screens.staff),
          ),
          _ActionTile(
            label: 'Generate Report',
            icon: Icons.insert_chart_outlined,
            onTap: () => AppNav.go(Screens.reports),
          ),
          const SizedBox(height: 6),
          const _ApprovalNote(),
        ],
      ),
    );
  }
}

class _ApprovalNote extends StatelessWidget {
  const _ApprovalNote();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppNav.go(Screens.staff),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.amberSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('5 items pending approval',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Staff applications and documents',
                      style: TextStyle(color: AppColors.body, fontSize: 11)),
                  SizedBox(height: 4),
                  Text('Review Now →',
                      style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
