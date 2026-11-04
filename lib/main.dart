import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'shell/home_shell.dart';

void main() {
  runApp(const LiveCareApp());
}

class LiveCareApp extends StatelessWidget {
  const LiveCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeShell(),
    );
  }
}
