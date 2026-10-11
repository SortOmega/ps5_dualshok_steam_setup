import 'package:flutter/material.dart';

import '../screens/installer_page.dart';
import '../services/steam_input_installer.dart';

void runSteamInputApp() {
  runApp(const SteamInputInstallerApp());
}

class SteamInputInstallerApp extends StatefulWidget {
  const SteamInputInstallerApp({super.key, this.installer});

  final SteamInputInstaller? installer;

  @override
  State<SteamInputInstallerApp> createState() => _SteamInputInstallerAppState();
}

class _SteamInputInstallerAppState extends State<SteamInputInstallerApp> {
  bool _spanish = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steam Input Setup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff6d5dfc),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff10101a),
        useMaterial3: true,
      ),
      home: InstallerPage(
        spanish: _spanish,
        installer: widget.installer ?? SteamInputInstaller(),
        onLanguageChanged: (value) => setState(() => _spanish = value),
      ),
    );
  }
}
