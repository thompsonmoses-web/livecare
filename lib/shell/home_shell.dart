import 'package:flutter/material.dart';

import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/scaffold_parts.dart';
import '../screens/dashboard_screen.dart';
import '../screens/live_monitoring_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/staff_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/incidents_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/billing_screen.dart';
import '../screens/settings_screen.dart';

/// Per-screen search hint, matching the mockups.
const List<String> _searchHints = [
  'Search anything...',
  'Search sessions, clients or caregivers...',
  'Search clients by name, ID or phone...',
  'Search staff by name, ID or specialization...',
  'Search schedule, staff, or clients...',
  'Search incidents, clients or staff...',
  'Search messages, clients or staff...',
  'Search reports, clients or staff...',
  'Search invoices, clients, staff, or reference...',
  'Search settings, users, or agency...',
];

/// Builds the screen for a given nav index.
Widget _buildScreen(int index) {
  switch (index) {
    case 0:
      return const DashboardScreen();
    case 1:
      return const LiveMonitoringScreen();
    case 2:
      return const ClientsScreen();
    case 3:
      return const StaffScreen();
    case 4:
      return const ScheduleScreen();
    case 5:
      return const IncidentsScreen();
    case 6:
      return const MessagesScreen();
    case 7:
      return const ReportsScreen();
    case 8:
      return const BillingScreen();
    case 9:
      return const SettingsScreen();
    default:
      return const DashboardScreen();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    AppNav.register((i) => setState(() => _index = i));
  }

  @override
  void dispose() {
    AppNav.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _index,
            onSelect: (i) => setState(() => _index = i),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TopBar(hint: _searchHints[_index]),
                Expanded(
                  child: Container(
                    color: AppColors.surface,
                    child: _buildScreen(_index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
