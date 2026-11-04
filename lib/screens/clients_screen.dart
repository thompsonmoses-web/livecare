import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final List<Map<String, String>> _clients = _buildClients();

  static const List<String> _names = [
    'Mr. Okafor', 'Mrs. Adeyemi', 'Mr. Chukwu', 'Mrs. Gambo', 'Mr. Sani', 'Mrs. Nwosu',
    'Mr. Danjuma', 'Mrs. Eze', 'Mr. Obi', 'Mrs. Yakubu', 'Mr. Musa', 'Mrs. Adebayo',
    'Mr. Uche', 'Mrs. Lawal', 'Mr. Emeka', 'Mrs. Balogun', 'Mr. Tosin', 'Mrs. Oladele',
    'Mr. Shehu', 'Mrs. Chike', 'Mr. Adeleke', 'Mrs. Ibe', 'Mr. Nnamdi', 'Mrs. Faruk',
    'Mr. Bassey', 'Mrs. Ogundele', 'Mr. Haliru', 'Mrs. Segun', 'Mr. Ifeanyi', 'Mrs. Jide',
    'Mr. Kunle', 'Mrs. Rasheed', 'Mr. Chidi', 'Mrs. Ojo', 'Mr. Suleiman', 'Mrs. Ajayi',
  ];
  static const List<String> _caregivers = [
    'Ada Obi', 'Eze Kalu', 'Okufu Rae', 'Adeboye M', 'Tunde Al',
    'Okun Ola', 'Bisi Nneka', 'Yusuf Bala', 'Grace Ekong', 'Musa Sani',
  ];
  static const List<String> _contacts = [
    'John', 'Mary', 'Paul', 'Aisha', 'Ali', 'Zara', 'Chidi', 'Ngozi', 'Ibrahim', 'Funke',
  ];

  static List<Map<String, String>> _buildClients() {
    final list = <Map<String, String>>[
      {
        'name': 'Mrs. Johnson', 'id': 'LC-0001', 'age': '78', 'careLevel': 'High Care',
        'room': 'Room 2B', 'phone': '0803 123 4567', 'caregiver': 'Ada Obi', 'status': 'Active',
        'blood': 'O+', 'allergies': 'Penicillin', 'conditions': 'Diabetes, Hypertension',
        'ecName': 'John Johnson', 'ecRel': 'Son', 'ecPhone': '0803 000 1111',
        'careNotes': 'Daily physio. Low-salt diet. Review monthly.',
      },
      {
        'name': 'Mr. Williams', 'id': 'LC-0002', 'age': '67', 'careLevel': 'Medium Care',
        'room': 'Room 1A', 'phone': '0803 222 3344', 'caregiver': 'Eze Kalu', 'status': 'Active',
        'blood': 'A+', 'allergies': 'None', 'conditions': 'Arthritis',
        'ecName': 'Mary Williams', 'ecRel': 'Wife', 'ecPhone': '0803 000 2222',
        'careNotes': 'Assisted mobility twice daily.',
      },
      {
        'name': 'Mrs. Clark', 'id': 'LC-0003', 'age': '82', 'careLevel': 'High Care',
        'room': 'Room 3C', 'phone': '0803 555 6677', 'caregiver': 'Okufu Rae', 'status': 'Active',
        'blood': 'B+', 'allergies': 'Sulfa', 'conditions': 'Dementia',
        'ecName': 'Paul Clark', 'ecRel': 'Son', 'ecPhone': '0803 000 3333',
        'careNotes': '24-hour supervision. Memory activities.',
      },
      {
        'name': 'Mr. Bello', 'id': 'LC-0004', 'age': '71', 'careLevel': 'Medium Care',
        'room': 'Room 2A', 'phone': '0803 888 9900', 'caregiver': 'Adeboye M', 'status': 'Active',
        'blood': 'O-', 'allergies': 'None', 'conditions': 'Heart disease',
        'ecName': 'Aisha Bello', 'ecRel': 'Daughter', 'ecPhone': '0803 000 4444',
        'careNotes': 'Cardiac meds at 08:00 and 20:00.',
      },
      {
        'name': 'Mrs. Fatima', 'id': 'LC-0005', 'age': '69', 'careLevel': 'Low Care',
        'room': 'Room 4B', 'phone': '0803 111 2233', 'caregiver': 'Tunde Al', 'status': 'Active',
        'blood': 'AB+', 'allergies': 'None', 'conditions': 'None',
        'ecName': 'Ali Fatima', 'ecRel': 'Husband', 'ecPhone': '0803 000 5555',
        'careNotes': 'Independent with light assistance.',
      },
      {
        'name': 'Mr. Ibrahim', 'id': 'LC-0006', 'age': '76', 'careLevel': 'High Care',
        'room': 'Room 3B', 'phone': '0803 444 5566', 'caregiver': 'Okun Ola', 'status': 'Active',
        'blood': 'A-', 'allergies': 'Latex', 'conditions': 'Stroke recovery',
        'ecName': 'Zara Ibrahim', 'ecRel': 'Daughter', 'ecPhone': '0803 000 6666',
        'careNotes': 'Speech therapy Tue/Thu. Fall precautions.',
      },
    ];

    for (var k = 0; k < _names.length; k++) {
      final n = k + 7;
      list.add({
        'name': _names[k],
        'id': 'LC-${n.toString().padLeft(4, '0')}',
        'age': '${58 + (k * 3) % 35}',
        'careLevel': const ['High Care', 'Medium Care', 'Low Care'][k % 3],
        'room': 'Room ${((k % 4) + 1)}${'ABCD'[k % 4]}',
        'phone': '0803 ${100 + k} ${2000 + k}',
        'caregiver': _caregivers[k % _caregivers.length],
        'status': (k % 9 == 8) ? 'Discharged' : 'Active',
        'blood': const ['O+', 'A+', 'B+', 'AB+', 'O-', 'A-'][k % 6],
        'allergies': const ['None', 'Penicillin', 'Sulfa', 'Latex', 'None'][k % 5],
        'conditions': const ['Diabetes', 'Hypertension', 'Arthritis', 'None', 'Dementia'][k % 5],
        'ecName': '${_contacts[k % _contacts.length]} ${_names[k].split(' ').last}',
        'ecRel': const ['Son', 'Daughter', 'Wife', 'Husband'][k % 4],
        'ecPhone': '0803 9${100 + k} ${3000 + k}',
        'careNotes': 'Standard care plan. Review monthly.',
      });
    }
    return list;
  }

  int _selected = 0;
  int _nextNum = _buildClients().length + 1;

  /// Client-id -> uploaded photo bytes.
  final Map<String, Uint8List> _photos = {};

  static const String _kRecords = 'lc_clients_v1';
  static const String _kPhotoPrefix = 'lc_photo_v1_';

  @override
  void initState() {
    super.initState();
    _loadPersisted();
  }

  /// Downscale + JPEG-compress so photos stay small enough for browser storage.
  Uint8List _compress(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;
      final resized = img.copyResize(decoded,
          width: 400, height: 400, interpolation: img.Interpolation.average);
      return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
    } catch (_) {
      return bytes;
    }
  }

  Future<void> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(_kRecords);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final loaded = decoded
            .map((e) => Map<String, String>.from(e as Map))
            .where((m) => m['id'] != null)
            .toList();
        if (loaded.isNotEmpty) {
          var maxNum = 0;
          for (final c in loaded) {
            final n = int.tryParse(c['id']!.replaceAll('LC-', '')) ?? 0;
            if (n > maxNum) maxNum = n;
          }
          setState(() {
            _clients
              ..clear()
              ..addAll(loaded);
            _nextNum = maxNum + 1;
            if (_selected >= _clients.length) _selected = 0;
          });
        }
      }

      var loadedPhoto = false;
      for (final key in prefs.getKeys().toList()) {
        if (key.startsWith(_kPhotoPrefix)) {
          final b64 = prefs.getString(key);
          if (b64 != null) {
            try {
              _photos[key.substring(_kPhotoPrefix.length)] = base64Decode(b64);
              loadedPhoto = true;
            } catch (_) {}
          }
        }
      }
      if (loadedPhoto && mounted) setState(() {});
    } catch (_) {
      // Ignore corrupted/unavailable storage — fall back to the seeded roster.
    }
  }

  Future<void> _persistRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRecords, jsonEncode(_clients));
    } catch (_) {}
  }

  Future<void> _persistPhoto(String id, Uint8List? bytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (bytes == null) {
        await prefs.remove('$_kPhotoPrefix$id');
      } else {
        final ok = await prefs.setString('$_kPhotoPrefix$id', base64Encode(bytes));
        if (!ok && mounted) {
          AppNav.toast(context, 'Photo saved for this session only (browser storage full)');
        }
      }
    } catch (_) {}
  }

  /// Single place that sets/removes a photo, refreshes UI and persists it.
  void _setPhoto(String id, Uint8List? bytes) {
    setState(() {
      if (bytes == null) {
        _photos.remove(id);
      } else {
        _photos[id] = bytes;
      }
    });
    _persistPhoto(id, bytes);
  }

  Future<Uint8List?> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.isNotEmpty && res.files.single.bytes != null) {
      return _compress(res.files.single.bytes!);
    }
    return null;
  }

  Future<void> _uploadForSelected() async {
    final bytes = await _pickImage();
    if (!mounted || bytes == null) return;
    _setPhoto(_clients[_selected]['id']!, bytes);
    AppNav.toast(context, 'Photo uploaded');
  }

  void _save(int i, Map<String, String> updated) {
    setState(() => _clients[i] = updated);
    _persistRecords();
    AppNav.toast(context, '${updated['name']}’s record saved');
  }

  void _saveSection(int i, Map<String, String> patch) {
    setState(() => _clients[i] = {..._clients[i], ...patch});
    _persistRecords();
    AppNav.toast(context, 'Details saved for ${_clients[i]['name']}');
  }

  void _addClient(String name, String phone, String careLevel, [Uint8List? photo]) {
    setState(() {
      final id = 'LC-${(_nextNum++).toString().padLeft(4, '0')}';
      _clients.add({
        'name': name, 'id': id,
        'age': '—', 'careLevel': careLevel, 'room': 'Unassigned', 'phone': phone,
        'caregiver': '—', 'status': 'Active',
        'blood': '—', 'allergies': '—', 'conditions': '—',
        'ecName': '—', 'ecRel': '—', 'ecPhone': '—', 'careNotes': '—',
      });
      if (photo != null) _photos[id] = photo;
      _selected = _clients.length - 1;
    });
    _persistRecords();
    if (photo != null) _persistPhoto(_clients[_selected]['id']!, photo);
    AppNav.toast(context, '$name added');
  }

  void _openAdd() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final careC = TextEditingController(text: 'Medium Care');
    Uint8List? newPhoto;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Add Client', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter the new client’s basic details to create a record.',
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
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final b = await _pickImage();
                                  if (b != null) setDlg(() => newPhoto = b);
                                },
                                icon: const Icon(Icons.upload_outlined, size: 16),
                                label: const Text('Upload'),
                              ),
                              if (newPhoto != null) ...[
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: () => setDlg(() => newPhoto = null),
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
                _field('Phone', phoneC, Icons.phone_outlined),
                _field('Care level', careC, Icons.favorite_outline),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final n = nameC.text.trim();
                if (n.isEmpty) return;
                Navigator.of(ctx).pop();
                _addClient(n, phoneC.text.trim().isEmpty ? '—' : phoneC.text.trim(),
                    careC.text.trim().isEmpty ? 'Medium Care' : careC.text.trim(), newPhoto);
              },
              child: const Text('Create client'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(int i) {
    final c = _clients[i];
    final clientId = c['id']!;
    final nameC = TextEditingController(text: c['name']);
    final ageC = TextEditingController(text: c['age']);
    final phoneC = TextEditingController(text: c['phone']);
    final roomC = TextEditingController(text: c['room']);
    final careC = TextEditingController(text: c['careLevel']);
    final caregiverC = TextEditingController(text: c['caregiver']);
    final statusC = TextEditingController(text: c['status']);
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final photo = _photos[clientId];
          return AlertDialog(
            title: Text('Edit ${c['name']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Avatar(name: c['name']!, radius: 28, image: photo),
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
                                        _setPhoto(clientId, b);
                                        setDlg(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.upload_outlined, size: 16),
                                    label: const Text('Upload'),
                                  ),
                                  if (photo != null) ...[
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: () {
                                        _setPhoto(clientId, null);
                                        setDlg(() {});
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
                    _field('Age', ageC, Icons.cake_outlined),
                    _field('Phone', phoneC, Icons.phone_outlined),
                    _field('Room / location', roomC, Icons.location_on_outlined),
                    _field('Care level', careC, Icons.favorite_outline),
                    _field('Primary caregiver', caregiverC, Icons.badge_outlined),
                    _field('Status', statusC, Icons.circle_outlined),
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
                    ...c,
                    'name': nameC.text.trim().isEmpty ? c['name']! : nameC.text.trim(),
                    'age': ageC.text.trim(),
                    'phone': phoneC.text.trim(),
                    'room': roomC.text.trim(),
                    'careLevel': careC.text.trim(),
                    'caregiver': caregiverC.text.trim(),
                    'status': statusC.text.trim().isEmpty ? 'Active' : statusC.text.trim(),
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

  void _openSection(int i, String kind) {
    final c = _clients[i];
    final title = c['name']!;
    List<MapEntry<String, TextEditingController>> fields;
    void Function(Map<String, String>) commit;
    String heading;

    if (kind == 'care') {
      heading = 'Care plan';
      final notes = TextEditingController(text: c['careNotes']);
      fields = [MapEntry('Care plan notes', notes)];
      commit = (m) => _saveSection(i, {'careNotes': m['Care plan notes']!});
    } else if (kind == 'medical') {
      heading = 'Medical information';
      final blood = TextEditingController(text: c['blood']);
      final allergies = TextEditingController(text: c['allergies']);
      final conditions = TextEditingController(text: c['conditions']);
      fields = [
        MapEntry('Blood type', blood),
        MapEntry('Allergies', allergies),
        MapEntry('Conditions', conditions),
      ];
      commit = (m) => _saveSection(i, {
            'blood': m['Blood type']!,
            'allergies': m['Allergies']!,
            'conditions': m['Conditions']!,
          });
    } else {
      heading = 'Emergency contacts';
      final name = TextEditingController(text: c['ecName']);
      final rel = TextEditingController(text: c['ecRel']);
      final phone = TextEditingController(text: c['ecPhone']);
      fields = [
        MapEntry('Contact name', name),
        MapEntry('Relationship', rel),
        MapEntry('Phone', phone),
      ];
      commit = (m) => _saveSection(i, {
            'ecName': m['Contact name']!,
            'ecRel': m['Relationship']!,
            'ecPhone': m['Phone']!,
          });
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$title — $heading',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final e in fields) _field(e.key, e.value, Icons.edit_outlined),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              commit({for (final e in fields) e.key: e.value.text});
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sel = _clients[_selected];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Clients',
          subtitle: 'Manage client records and access care information.',
          trailing: FilledButton.icon(
            onPressed: _openAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Client'),
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
                    Row(
                      children: const [
                        _Dropdown(label: 'All Locations'),
                        SizedBox(width: 10),
                        _Dropdown(label: 'All Care Levels'),
                        SizedBox(width: 10),
                        _Dropdown(label: 'Active'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _HeaderRow(
                      cols: const ['Client', 'Age', 'Care level', 'Location', 'Status', 'Actions'],
                      widths: const [4, 1, 2, 2, 2, 2],
                    ),
                    const Divider(height: 20),
                    for (var i = 0; i < _clients.length; i++)
                      _ClientRow(
                        client: _clients[i],
                        photo: _photos[_clients[i]['id']],
                        selected: i == _selected,
                        onTap: () => setState(() => _selected = i),
                        onEdit: () => _openEdit(i),
                      ),
                    const SizedBox(height: 12),
                    Text('Showing all ${_clients.length} clients',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: _ClientProfile(
                client: sel,
                photo: _photos[sel['id']],
                onEdit: () => _openEdit(_selected),
                onUploadPhoto: _uploadForSelected,
                onCare: () => _openSection(_selected, 'care'),
                onMedical: () => _openSection(_selected, 'medical'),
                onEmergency: () => _openSection(_selected, 'emergency'),
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

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _ClientRow extends StatelessWidget {
  const _ClientRow({
    required this.client,
    required this.photo,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final Map<String, String> client;
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
                  Avatar(name: client['name']!, image: photo),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client['name']!,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('(${client['id']})',
                          style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: Text(client['age']!, style: const TextStyle(fontSize: 13))),
            Expanded(flex: 2, child: Text(client['careLevel']!, style: const TextStyle(fontSize: 13))),
            Expanded(flex: 2, child: Text(client['room']!, style: const TextStyle(fontSize: 13))),
            Expanded(
                flex: 2,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: statusBadge(client['status'] ?? 'Active'))),
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

class _ClientProfile extends StatelessWidget {
  const _ClientProfile({
    required this.client,
    required this.photo,
    required this.onEdit,
    required this.onUploadPhoto,
    required this.onCare,
    required this.onMedical,
    required this.onEmergency,
  });

  final Map<String, String> client;
  final Uint8List? photo;
  final VoidCallback onEdit;
  final VoidCallback onUploadPhoto;
  final VoidCallback onCare;
  final VoidCallback onMedical;
  final VoidCallback onEmergency;

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
                      Avatar(name: client['name']!, radius: 34, image: photo),
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
                Text(client['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('(${client['id']})', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 8),
                statusBadge(client['status'] ?? 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.cake_outlined, label: 'Age', value: client['age']!),
          _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: client['phone']!),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: client['room']!),
          _InfoRow(icon: Icons.favorite_outline, label: 'Care level', value: client['careLevel']!),
          _InfoRow(icon: Icons.badge_outlined, label: 'Caregiver', value: client['caregiver']!),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Client Info'),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 6),
          _LinkRow(label: 'Care plan', icon: Icons.description_outlined, onTap: onCare),
          _LinkRow(label: 'Medical information', icon: Icons.medical_information_outlined, onTap: onMedical),
          _LinkRow(label: 'Emergency contacts', icon: Icons.contact_emergency_outlined, onTap: onEmergency),
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

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.body),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
