import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/scaffold_parts.dart';
import '../widgets/common.dart';

class _Msg {
  _Msg({required this.sender, required this.text, required this.time, required this.out});
  final String sender;
  final String text;
  final String time;
  final bool out;
}

class _Conv {
  _Conv({
    required this.name,
    required this.subtitle,
    this.avatarText,
    this.members,
    this.unread = false,
    required this.msgs,
  });
  final String name;
  final String subtitle;
  final String? avatarText;
  final int? members;
  bool unread;
  final List<_Msg> msgs;
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<_Conv> _convs = [
    _Conv(
      name: 'Care Team',
      subtitle: '6 members',
      avatarText: 'CT',
      members: 6,
      unread: true,
      msgs: [
        _Msg(sender: 'Rita Menash', time: '9:47 AM', out: false,
            text: 'Shift update for tomorrow: Mrs. Johnson will now be on 8am - 4pm. Please confirm once you’ve seen this.'),
        _Msg(sender: 'You', time: '9:48 AM', out: true, text: 'Noted. I’ve updated my schedule. Thanks, Rita.'),
        _Msg(sender: 'Tunde Ogunmi', time: '9:47 AM', out: false,
            text: 'Great. Also, please remember to check medication for Mr. Bello.'),
        _Msg(sender: 'You', time: '9:49 AM', out: true, text: 'Will do.'),
      ],
    ),
    _Conv(
      name: 'Mrs. Adeyemi (Client)',
      subtitle: 'Client',
      msgs: [
        _Msg(sender: 'Mrs. Adeyemi', time: '9:35 AM', out: false, text: 'Thank you for your support today...'),
        _Msg(sender: 'You', time: '9:36 AM', out: true, text: 'You’re welcome! Let us know if you need anything at all.'),
        _Msg(sender: 'Mrs. Adeyemi', time: '9:40 AM', out: false, text: 'The nurse was very kind. I appreciate it.'),
      ],
    ),
    _Conv(
      name: 'Tunde Ogunmi',
      subtitle: 'Team member',
      unread: true,
      msgs: [
        _Msg(sender: 'Tunde Ogunmi', time: '9:12 AM', out: false, text: 'Please complete the incident report...'),
      ],
    ),
    _Conv(
      name: 'Agency Announcements',
      subtitle: 'Broadcast',
      avatarText: 'AA',
      msgs: [
        _Msg(sender: 'Agency', time: '8:30 AM', out: false, text: 'New policy update: 15 Oct 2025. Please review the handbook.'),
      ],
    ),
    _Conv(
      name: 'Rita Menash',
      subtitle: 'Coordinator',
      msgs: [
        _Msg(sender: 'Rita Menash', time: 'Yesterday', out: false, text: 'Can you confirm the schedule for next week?'),
      ],
    ),
    _Conv(
      name: 'Weekend Shift',
      subtitle: '4 members',
      avatarText: 'WS',
      members: 4,
      msgs: [
        _Msg(sender: 'Ada Obi', time: 'Yesterday', out: false, text: 'Happy Monday everyone!...'),
      ],
    ),
  ];

  int _selected = 0;
  final TextEditingController _input = TextEditingController();

  static const String _kConvs = 'lc_convs_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Map<String, dynamic> _convJson(_Conv c) => {
        'name': c.name,
        'subtitle': c.subtitle,
        'avatarText': c.avatarText,
        'members': c.members,
        'unread': c.unread,
        'msgs': [
          for (final m in c.msgs)
            {'sender': m.sender, 'text': m.text, 'time': m.time, 'out': m.out},
        ],
      };

  _Conv _convFromJson(Map<String, dynamic> j) => _Conv(
        name: j['name'] as String? ?? '',
        subtitle: j['subtitle'] as String? ?? '',
        avatarText: j['avatarText'] as String?,
        members: j['members'] as int?,
        unread: j['unread'] as bool? ?? false,
        msgs: [
          for (final x in (j['msgs'] as List? ?? const []))
            _Msg(
              sender: x['sender'] as String? ?? '',
              text: x['text'] as String? ?? '',
              time: x['time'] as String? ?? '',
              out: x['out'] as bool? ?? false,
            ),
        ],
      );

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kConvs, jsonEncode([for (final c in _convs) _convJson(c)]));
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kConvs);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final convs = list
          .map((e) => _convFromJson(Map<String, dynamic>.from(e as Map)))
          .where((c) => c.name.isNotEmpty)
          .toList();
      if (convs.isNotEmpty && mounted) {
        setState(() {
          _convs
            ..clear()
            ..addAll(convs);
          if (_selected >= _convs.length) _selected = 0;
        });
      }
    } catch (_) {
      // Corrupt/unavailable storage — keep the seeded conversations.
    }
  }

  void _select(int i) {
    setState(() {
      _selected = i;
      _convs[i].unread = false;
    });
    _persist();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _convs[_selected].msgs.add(_Msg(sender: 'You', text: text, time: 'Now', out: true));
      _input.clear();
    });
    _persist();
  }

  void _newMessage() {
    final toC = TextEditingController();
    final msgC = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New message', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf('To', toC, Icons.person_outline),
              _tf('Message', msgC, Icons.message_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final to = toC.text.trim();
              final msg = msgC.text.trim();
              Navigator.of(ctx).pop();
              if (msg.isEmpty) return;
              setState(() {
                _convs.insert(0, _Conv(
                      name: to.isEmpty ? 'New conversation' : to,
                      subtitle: 'Sent',
                      msgs: [_Msg(sender: 'You', text: msg, time: 'Now', out: true)],
                    ));
                _selected = 0;
              });
              _persist();
              AppNav.toast(context, 'Message sent');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conv = _convs[_selected];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageHeader(
          title: 'Messages',
          subtitle: 'Communicate with your team, clients and families.',
          trailing: FilledButton.icon(
            onPressed: _newMessage,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('New message'),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 620,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: const [
                            _Tab(label: 'Inbox (4)', active: true),
                            SizedBox(width: 16),
                            _Tab(label: 'Groups'),
                            SizedBox(width: 16),
                            _Tab(label: 'Archived'),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView(
                          children: [
                            for (var i = 0; i < _convs.length; i++)
                              _ConvTile(
                                conv: _convs[i],
                                selected: i == _selected,
                                onTap: () => _select(i),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ChatHeader(conv: conv),
                      const Divider(height: 1),
                      Expanded(
                        child: Container(
                          color: AppColors.surface,
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            children: [
                              for (final m in conv.msgs) ...[
                                if (m.out)
                                  _OutgoingBubble(text: m.text, time: m.time)
                                else
                                  _IncomingBubble(sender: m.sender, time: m.time, text: m.text),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      _MessageInput(controller: _input, onSend: _send),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _QuickActions(),
                    const SizedBox(height: 14),
                    _RecentFiles(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _tf(String label, TextEditingController c, IconData icon) {
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
  const _Tab({required this.label, this.active = false});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: active ? AppColors.primary : AppColors.body,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
        decoration: active ? TextDecoration.underline : null,
        decorationColor: AppColors.primary,
        decorationThickness: 2,
      ),
    );
  }
}

class _ConvTile extends StatelessWidget {
  const _ConvTile({required this.conv, required this.selected, required this.onTap});

  final _Conv conv;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = conv.msgs.isNotEmpty ? conv.msgs.last : null;
    final preview = last != null ? (last.out ? 'You: ' : '') + last.text : '';
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Avatar(name: conv.avatarText ?? conv.name, radius: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conv.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(preview,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(last?.time ?? '', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                if (conv.unread) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.conv});
  final _Conv conv;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Avatar(name: conv.avatarText ?? conv.name, radius: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conv.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(conv.subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
              onPressed: () => AppNav.dialog(
                context,
                title: 'Conversation options',
                fields: [
                  dialogInfo('Members', conv.members?.toString() ?? '1'),
                  dialogInfo('Notifications', 'On'),
                  dialogInfo('Muted', 'No'),
                ],
                confirmLabel: 'Done',
                onConfirm: () {},
              ),
              icon: const Icon(Icons.more_vert, color: AppColors.body)),
        ],
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  const _IncomingBubble({required this.sender, required this.time, required this.text});
  final String sender;
  final String time;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$sender  •  $time', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  const _OutgoingBubble({required this.text, required this.time});
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
        ),
        const SizedBox(height: 2),
        Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ],
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
              onPressed: () => AppNav.dialog(
                context,
                title: 'Attach a file',
                message: 'Choose a file to share in this conversation.',
                fields: [
                  dialogField('File', hint: 'Browse for a file\u2026', icon: Icons.attach_file),
                ],
                confirmLabel: 'Attach',
                onConfirm: () {},
              ),
              icon: const Icon(Icons.attach_file, color: AppColors.muted)),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: onSend,
            padding: EdgeInsets.zero,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _ActionRow(
            label: 'Send announcement',
            icon: Icons.campaign_outlined,
            onTap: () => AppNav.dialog(
              context,
              title: 'Send announcement',
              message: 'Broadcast a message to your team or clients.',
              fields: [
                dialogField('Audience', hint: 'All staff, a team, or a client', icon: Icons.people_outline),
                dialogField('Announcement', hint: 'Write your announcement\u2026', icon: Icons.campaign_outlined),
              ],
              confirmLabel: 'Send',
              onConfirm: () {},
            ),
          ),
          _ActionRow(
            label: 'Create group',
            icon: Icons.group_add_outlined,
            onTap: () => AppNav.dialog(
              context,
              title: 'Create group',
              message: 'Start a new group conversation.',
              fields: [
                dialogField('Group name', hint: 'e.g. Night Shift', icon: Icons.group_outlined),
                dialogField('Members', hint: 'Add team members', icon: Icons.people_outline),
              ],
              confirmLabel: 'Create',
              onConfirm: () {},
            ),
          ),
          _ActionRow(
            label: 'View all messages',
            icon: Icons.forum_outlined,
            onTap: () => AppNav.dialog(
              context,
              title: 'All messages',
              message: 'Jump to any conversation.',
              fields: [
                dialogInfo('Care Team', '6 members'),
                dialogInfo('Mrs. Adeyemi (Client)', 'Client'),
                dialogInfo('Tunde Ogunmi', 'Team member'),
                dialogInfo('Agency Announcements', 'Broadcast'),
              ],
              confirmLabel: 'Close',
              onConfirm: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.label, required this.icon, required this.onTap});
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
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _RecentFiles extends StatefulWidget {
  const _RecentFiles();

  @override
  State<_RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<_RecentFiles> {
  static const String _kFiles = 'lc_files_v1';

  List<Map<String, String>> _files = [
    {'name': 'Schedule-update.pdf', 'size': '2.4 MB'},
    {'name': 'Client-care-plan.docx', 'size': '1.1 MB'},
    {'name': 'Incident-report-form.pdf', 'size': '850 KB'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kFiles);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final files = list.map((e) => Map<String, String>.from(e as Map)).toList();
      if (mounted) setState(() => _files = files);
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFiles, jsonEncode(_files));
    } catch (_) {}
  }

  String _ext(String name) {
    final i = name.lastIndexOf('.');
    return i == -1 ? 'FILE' : name.substring(i + 1).toUpperCase();
  }

  IconData _iconFor(String name) {
    switch (_ext(name)) {
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'DOCX':
      case 'DOC':
        return Icons.article_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void _showActions(int i) {
    final f = _files[i];
    final name = f['name']!;
    final size = f['size']!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_ext(name)}  •  $size  •  Shared in this conversation',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const Divider(height: 24),
              _act(Icons.visibility_outlined, 'Preview file', AppColors.primary, () {
                Navigator.of(ctx).pop();
                _preview(i);
              }),
              _act(Icons.download_outlined, 'Download', AppColors.primary, () {
                Navigator.of(ctx).pop();
                AppNav.toast(context, 'Downloading $name…');
              }),
              _act(Icons.share_outlined, 'Share', AppColors.primary, () {
                Navigator.of(ctx).pop();
                _share(i);
              }),
              _act(Icons.delete_outline, 'Delete', AppColors.red, () {
                Navigator.of(ctx).pop();
                setState(() => _files.removeAt(i));
                _persist();
                AppNav.toast(context, '$name deleted');
              }),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  Widget _act(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 18, color: color),
      title: Text(label, style: TextStyle(fontSize: 14, color: color)),
      onTap: onTap,
    );
  }

  void _preview(int i) {
    final f = _files[i];
    final name = f['name']!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_iconFor(name), size: 44, color: AppColors.primary),
                    const SizedBox(height: 10),
                    Text('${_ext(name)} document',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Preview of $name (${f['size']})',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppNav.toast(context, 'Downloading $name…');
            },
            child: const Text('Download'),
          ),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _share(int i) {
    final name = _files[i]['name']!;
    final toC = TextEditingController();
    final noteC = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share file', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 12),
              _shareField('To', toC, Icons.person_outline),
              _shareField('Note', noteC, Icons.message_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final to = toC.text.trim();
              AppNav.toast(context, to.isEmpty ? 'File shared' : 'File shared with $to');
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent files', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Tap a file to preview, download, share or delete.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          if (_files.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No recent files.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
          for (var i = 0; i < _files.length; i++)
            _FileRow(
              name: _files[i]['name']!,
              size: _files[i]['size']!,
              icon: _iconFor(_files[i]['name']!),
              onTap: () => _showActions(i),
            ),
        ],
      ),
    );
  }
}

Widget _shareField(String label, TextEditingController c, IconData icon) {
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
            prefixIcon: Icon(icon, size: 18),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.name, required this.size, required this.icon, required this.onTap});
  final String name;
  final String size;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pdf = name.toLowerCase().endsWith('.pdf');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: pdf ? AppColors.redSoft : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, size: 18, color: pdf ? AppColors.red : AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(size, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
