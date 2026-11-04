import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:livecare/main.dart';
import 'package:livecare/shell/home_shell.dart';
import 'package:livecare/widgets/sidebar.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const LiveCareApp());
    await tester.pumpAndSettle();
  }

  testWidgets('App builds the dashboard shell with sidebar nav', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(Sidebar), findsOneWidget);
    // Dashboard is the default screen.
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Active Care Sessions'), findsOneWidget);
  });

  testWidgets('Tapping a sidebar item switches screens', (tester) async {
    await pumpApp(tester);

    // Helper to tap a nav item inside the sidebar only (avoids the page-header title match).
    Finder nav(String label) => find.descendant(
          of: find.byType(Sidebar),
          matching: find.text(label),
        );

    // Navigate to Clients (index 2).
    await tester.tap(nav('Clients'));
    await tester.pumpAndSettle();
    expect(find.text('Manage client records and access care information.'), findsOneWidget);

    // Navigate to Billing (index 8).
    await tester.tap(nav('Billing'));
    await tester.pumpAndSettle();
    expect(find.text('Manage invoices, payments and financial records.'), findsOneWidget);

    // Navigate to Settings (index 9).
    await tester.tap(nav('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Configure your agency, users and system preferences.'), findsOneWidget);
  });

  testWidgets('Each of the 10 screens renders', (tester) async {
    await pumpApp(tester);

    final titles = <String, String>{
      'Dashboard': "Here's what's happening with your agency today.",
      'Live Monitoring': 'Monitor active sessions, caregiver check-ins and any flagged concerns.',
      'Clients': 'Manage client records and access care information.',
      'Staff': 'Manage caregiver records, onboarding and approvals.',
      'Schedule': 'View and manage staff schedules, shifts and assignments.',
      'Incidents': 'View and manage incidents, concerns and follow ups.',
      'Messages': 'Communicate with your team, clients and families.',
      'Reports': 'Generate and view operational reports.',
      'Billing': 'Manage invoices, payments and financial records.',
      'Settings': 'Configure your agency, users and system preferences.',
    };

    for (final entry in titles.entries) {
      // Tap only the sidebar nav item to avoid matching the page-header title.
      await tester.tap(find.descendant(
        of: find.byType(Sidebar),
        matching: find.text(entry.key),
      ));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget,
          reason: 'Screen "${entry.key}" should render its subtitle');
    }
  });
}
