import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final List<Map<String, String>> _staff = [
    {
      'name': 'Ms. Adeyemi', 'id': 'ST-001', 'role': 'Caregiver', 'location': 'Riverside',
      'status': 'Active', 'docs': 'Complete', 'phone': '0803 123 4567',
      'email': 'adeyemi@riversidecare.com', 'joined': '12 Jan 2024',
    },
    {
      'name': 'Mr. Eze', 'id': 'ST-002', 'role': 'Caregiver', 'location': 'Riverside',
      'status': 'Active', 'docs': 'Complete', 'phone': '0803 222 3344',
      'email': 'eze@riversidecare.com', 'joined': '03 Mar 2024',
    },
    {
      'name': 'Mr. Oklor', 'id': 'ST-003', 'role': 'Caregiver', 'location': 'Ija',
      'status': 'Active', 'docs': 'Complete', 'phone': '0803 333 4455',
      'email': 'oklor@riversidecare.com', 'joined': '21 Jun 2024',
    },
    {
      'name': 'Mr. Adebayo', 'id': 'ST-004', 'role': 'Caregiver', 'location': 'Lekki',
      'status': 'Pending', 'docs': 'In review', 'phone': '0803 444 5566',
      'email': 'adebayo@riversidecare.com', 'joined': '02 Sep 2025',
    },
    {
      'name': 'Mr. Tunde', 'id': 'ST-005', 'role': 'Caregiver', 'location': 'Riverside',
      'status': 'Active', 'docs': 'Complete', 'phone': '0803 555 6677',
      'email': 'tunde@riversidecare.com', 'joined': '17 Nov 2024',
    },
    {
      'name': 'Mr. Okon', 'id': 'ST-006', 'role': 'Caregiver', 'location': 'Ija',
      'status': 'Active', 'docs': 'Complete', 'phone': '0803 666 7788',
      'email': 'okon@riversidecare.com', 'joined': '09 Feb 2025',
    },
  ];

  static const List<String> _roles = ['All Roles', 'Caregiver', 'Nurse', 'Coordinator', 'Driver'];
  static const List<String> _statuses = ['All Statuses', 'Active', 'Pending', 'Inactive'];

  int _selected = 0;
  int _tab = 0;
  String _roleFilter = 'All Roles';
  String _statusFilter = 'All Statuses';
  final Map<String, Uint8List> _photos = {};

  int _countByTab(int tab) {
    var n = 0;
    for (final s in _staff) {
      if (tab == 1 && s['status'] != 'Pending') continue;
      if (tab == 2 && s['docs'] == 'Complete') continue;
      n++;
    }
    return n;
  }

  List<int> get _visible {
    final out = <int>[];
    for (var i = 0; i < _staff.length; i++) {
      final s = _staff[i];
      if (_tab == 1 && s['status'] != 'Pending') continue;
      if (_tab == 2 && s['docs'] == 'Complete') continue;
      if (_roleFilter != 'All Roles' && s['role'] != _roleFilter) continue;
      if (_statusFilter != 'All Statuses' && s['status'] != _statusFilter) continue;
      out.add(i);
    }
    return out;
  }

  int get _selectedSafe => _selected < _staff.length ? _selected : 0;

  Future<Uint8List?> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.isNotEmpty && res.files.single.bytes != null) {
      return res.files.single.bytes;
    }
    return null;
  }

  int _nextId() {
    var m = 0;
    for (final s in _staff) {
      final n = int.tryParse(s['id']!.replaceAll('ST-', '')) ?? 0;
      if (n > m) m = n;
    }
    return m + 1;
  }

  void _save(int i, Map<String, String> updated) {
    setState(() => _staff[i] = updated);
    AppNav.toast(context, '${updated['name']}’s record saved');
  }

  void _addStaff(String name, String role, String phone, String location, [Uint8List? photo]) {
    setState(() {
      final id = 'ST-${_nextId().toString().padLeft(3, '0')}';
      _staff.add({
        'name': name, 'id': id,
        'role': role.isEmpty ? 'Caregiver' : role,
        'location': location.isEmpty ? 'Unassigned' : location,
        'status': 'Active', 'docs': 'In review',
        'phone': phone.isEmpty ? '—' : phone,
        'email': '—', 'joined': 'Today',
      });
      if (photo != null) _photos[id] = photo;
      _selected = _staff.length - 1;
      _tab = 0;
    });
    AppNav.toast(context, '$name added');
  }

  void _openAdd() {
    final nameC = TextEditingController();
    final roleC = TextEditingController(text: 'Caregiver');
    final phoneC = TextEditingController();
    final locC = TextEditingController();
    Uint8List? newPhoto;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add a new caregiver to your team and start onboarding.',
                      style: TextStyle(fontSize: 13, color: AppColors.body)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Avatar(name: 'New', radius: 28, image: newPhoto),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Profile photo',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final b = await _pickImage();
                                if (b != null) setDlg(() => newPhoto = b);
                              },
                              icon: const Icon(Icons.upload_outlined, size: 16),
                              label: const Text('Upload'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 22),
                  _field('Full name', nameC, Icons.person_outline),
                  _field('Role', roleC, Icons.work_outline),
                  _field('Phone', phoneC, Icons.phone_outlined),
                  _field('Location', locC, Icons.location_on_outlined),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final n = nameC.text.trim();
                if (n.isEmpty) return;
                Navigator.of(ctx).pop();
                _addStaff(n, roleC.text.trim(), phoneC.text.trim(), locC.text.trim(), newPhoto);
              },
              child: const Text('Add staff'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(int i) {
    final s = _staff[i];
    final sid = s['id']!;
    final nameC = TextEditingController(text: s['name']);
    final roleC = TextEditingController(text: s['role']);
    final phoneC = TextEditingController(text: s['phone']);
    final locC = TextEditingController(text: s['location']);
    final emailC = TextEditingController(text: s['email']);
    final statusC = TextEditingController(text: s['status']);
    final docsC = TextEditingController(text: s['docs']);
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final photo = _photos[sid];
          return AlertDialog(
            title: Text('Edit ${s['name']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Avatar(name: s['name']!, radius: 28, image: photo),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Profile photo',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final b = await _pickImage();
                                      if (b != null) {
                                        setDlg(() => _photos[sid] = b);
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.upload_outlined, size: 16),
                                    label: const Text('Upload'),
                                  ),
                                  if (photo != null) ...[
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: () {
                                        setDlg(() => _photos.remove(sid));
                                        setState(() {});
                                      },
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22),
                    _field('Full name', nameC, Icons.person_outline),
                    _field('Role', roleC, Icons.work_outline),
                    _field('Phone', phoneC, Icons.phone_outlined),
                    _field('Location', locC, Icons.location_on_outlined),
                    _field('Email', emailC, Icons.email_outlined),
                    _field('Status', statusC, Icons.circle_outlined),
                    _field('Documents', docsC, Icons.description_outlined),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _save(i, {
                    ...s,
                    'name': nameC.text.trim().isEmpty ? s['name']! : nameC.text.trim(),
                    'role': roleC.text.trim(),
                    'phone': phoneC.text.trim(),
                    'location': locC.text.trim(),
                    'email': emailC.text.trim(),
                    'status': statusC.text.trim().isEmpty ? 'Active' : statusC.text.trim(),
                    'docs': docsC.text.trim().isEmpty ? 'Complete' : docsC.text.trim(),
                  });
                },
                child: const Text('Save changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pickFilter(String which) {
    final options = which == 'role' ? _roles : _statuses;
    final current = which == 'role' ? _roleFilter : _statusFilter;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(which == 'role' ? 'Filter by role' : 'Filter by status',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in options)
                ListTile(
                  dense: true,
                  title: Text(o, style: const TextStyle(fontSize: 14)),
                  trailing: o == current ? const Icon(Icons.check, size: 18, color: AppColors.primary) : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      if (which == 'role') {
                        _roleFilter = o;
                      } else {
                        _statusFilter = o;
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel'))],
      ),
    );
  }

  void _uploadForSelected() async {
    final sid = _staff[_selectedSafe]['id']!;
    final bytes = await _pickImage();
    if (!mounted || bytes == null) return;
    setState(() => _photos[sid] = bytes);
    AppNav.toast(context, 'Photo uploaded');
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final sel = _staff[_selectedSafe];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Staff',
          subtitle: 'Manage caregiver records, onboarding and approvals.',
          trailing: FilledButton.icon(
            onPressed: _openAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Staff'),
          ),
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _Tab(label: 'All Staff (${_staff.length})', active: _tab == 0,
                              onTap: () => setState(() => _tab = 0)),
                          const SizedBox(width: 20),
                          _Tab(label: 'Pending Approval (${_countByTab(1)})', active: _tab == 1,
                              onTap: () => setState(() => _tab = 1)),
                          const SizedBox(width: 20),
                          _Tab(label: 'Document Expiring (${_countByTab(2)})', active: _tab == 2,
                              onTap: () => setState(() => _tab = 2)),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _Dropdown(label: _roleFilter, onTap: () => _pickFilter('role')),
                        const SizedBox(width: 10),
                        _Dropdown(label: _statusFilter, onTap: () => _pickFilter('status')),
                        const Spacer(),
                        Container(
                          width: 170, height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Search by name or ID...',
                                style: TextStyle(color: AppColors.muted, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _HeaderRow(
                      cols: const ['Staff', 'Role', 'Location', 'Status', 'Documents', 'Actions'],
                      widths: const [4, 2, 2, 2, 2, 2],
                    ),
                    const Divider(height: 20),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No staff match these filters.',
                              style: TextStyle(color: AppColors.muted, fontSize: 13)),
                        ),
                      ),
                    for (final i in visible)
                      _StaffRow(
                        staff: _staff[i],
                        photo: _photos[_staff[i]['id']],
                        selected: i == _selectedSafe,
                        onTap: () => setState(() => _selected = i),
                        onEdit: () => _openEdit(i),
                      ),
                    const SizedBox(height: 12),
                    Text('Showing ${visible.length} of ${_staff.length} staff',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _StaffProfile(
                    staff: sel,
                    photo: _photos[sel['id']],
                    onEdit: () => _openEdit(_selectedSafe),
                    onUploadPhoto: _uploadForSelected,
                  ),
                  const SizedBox(height: 14),
                  _ApprovalsPanel(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _field(String label, TextEditingController ctrl, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
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

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.muted),
          ],
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

class _StaffRow extends StatelessWidget {
  const _StaffRow({
    required this.staff,
    required this.photo,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final Map<String, String> staff;
  final Uint8List? photo;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.surface : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Avatar(name: staff['name']!, image: photo),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff['name']!,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('(${staff['id']})',
                          style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(staff['role']!, style: const TextStyle(fontSize: 13))),
            Expanded(flex: 2, child: Text(staff['location']!, style: const TextStyle(fontSize: 13))),
            Expanded(
                flex: 2,
                child: Align(alignment: Alignment.centerLeft, child: statusBadge(staff['status']!))),
            Expanded(
                flex: 2,
                child: Align(alignment: Alignment.centerLeft, child: statusBadge(staff['docs']!))),
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: onEdit,
                child: const Text('Edit', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffProfile extends StatelessWidget {
  const _StaffProfile({
    required this.staff,
    required this.photo,
    required this.onEdit,
    required this.onUploadPhoto,
  });

  final Map<String, String> staff;
  final Uint8List? photo;
  final VoidCallback onEdit;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: onUploadPhoto,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Avatar(name: staff['name']!, radius: 34, image: photo),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(staff['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('(${staff['id']})', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 8),
                statusBadge(staff['status']!),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.work_outline, label: 'Role', value: staff['role']!),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: staff['location']!),
          _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: staff['phone']!),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: staff['email']!),
          _InfoRow(icon: Icons.calendar_today_outlined, label: 'Joined', value: staff['joined']!),
          _InfoRow(icon: Icons.description_outlined, label: 'Documents', value: staff['docs']!),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Staff Info'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.body, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _ApprovalsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Pending Approvals',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  _CountBadge('5'),
                ],
              ),
              const SizedBox(height: 14),
              _ApproveRow(label: 'New staff applications', count: '1', icon: Icons.person_add_alt),
              _ApproveRow(label: 'Document reviews', count: '2', icon: Icons.description_outlined),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => AppNav.dialog(
                    context,
                    title: 'Approval review queue',
                    message: 'Items waiting for your decision.',
                    fields: [
                      dialogInfo('New staff applications', '1'),
                      dialogInfo('Document reviews', '2'),
                    ],
                    confirmLabel: 'Open queue',
                    onConfirm: () {},
                  ),
                  child: const Text('Review queue'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Document Expiry',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  _CountBadge('3'),
                ],
              ),
              const SizedBox(height: 14),
              _ApproveRow(label: 'Certifications', count: '2', icon: Icons.verified_outlined),
              _ApproveRow(label: 'Background checks', count: '1', icon: Icons.fingerprint),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => AppNav.dialog(
                    context,
                    title: 'Expiring documents',
                    message: '3 documents expire soon.',
                    fields: [
                      dialogInfo('Certifications', '2'),
                      dialogInfo('Background checks', '1'),
                    ],
                    confirmLabel: 'View all',
                    onConfirm: () {},
                  ),
                  child: const Text('View expiring documents'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _ApproveRow extends StatelessWidget {
  const _ApproveRow({required this.label, required this.count, required this.icon});
  final String label;
  final String count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(count, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
