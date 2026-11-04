import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Navigation destinations matching the W1–W10 design.
class NavItem {
  const NavItem(this.label, this.icon, {this.badge});
  final String label;
  final IconData icon;
  final String? badge;
}

const List<NavItem> navItems = [
  NavItem('Dashboard', Icons.dashboard_outlined),
  NavItem('Live Monitoring', Icons.monitor_heart_outlined),
  NavItem('Clients', Icons.people_outline),
  NavItem('Staff', Icons.badge_outlined),
  NavItem('Schedule', Icons.calendar_month_outlined),
  NavItem('Incidents', Icons.report_gmailerrorred, badge: '7'),
  NavItem('Messages', Icons.chat_bubble_outline, badge: '3'),
  NavItem('Reports', Icons.insights_outlined),
  NavItem('Billing', Icons.receipt_long_outlined),
  NavItem('Settings', Icons.settings_outlined),
];

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: AppColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Logo(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: navItems.length,
              itemBuilder: (context, i) {
                final item = navItems[i];
                final selected = i == selectedIndex;
                return _NavTile(
                  item: item,
                  selected: selected,
                  onTap: () => onSelect(i),
                );
              },
            ),
          ),
          const _SidebarFooter(),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Image.asset(
        'assets/logo_light.png',
        width: 190,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.navActive : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected ? Colors.white : const Color(0xFF93A7C4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFC3D2E6),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.navyDeep,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text('AU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text('Riverside Care Agency',
                    style: TextStyle(color: Color(0xFF93A7C4), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
