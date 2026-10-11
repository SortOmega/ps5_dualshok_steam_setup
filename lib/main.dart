import 'dart:io';

import 'package:flutter/material.dart';

void main() {
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

class InstallerPage extends StatefulWidget {
  const InstallerPage({
    super.key,
    required this.spanish,
    required this.installer,
    required this.onLanguageChanged,
  });

  final bool spanish;
  final SteamInputInstaller installer;
  final ValueChanged<bool> onLanguageChanged;

  @override
  State<InstallerPage> createState() => _InstallerPageState();
}

class _InstallerPageState extends State<InstallerPage> {
  VerificationResult? _result;
  bool _checking = false;
  bool _installing = false;
  String? _error;

  String get _checkLabel =>
      widget.spanish ? 'Comprobar de nuevo' : 'Check again';

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final result = await widget.installer.verify();
      if (mounted) setState(() => _result = result);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _install() async {
    final result = _result;
    if (result == null) return;
    setState(() {
      _installing = true;
      _error = null;
    });
    try {
      await widget.installer.install(result);
      final updated = await widget.installer.verify();
      if (mounted) {
        setState(() => _result = updated);
        await _showRestartDialog();
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _installing = false);
    }
  }

  Future<void> _showRestartDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.spanish ? 'Configuración completada' : 'Setup complete',
        ),
        content: Text(
          widget.spanish
              ? 'Las reglas udev se recargaron. Reinicia Steam para aplicar Steam Input.'
              : 'The udev rules were reloaded. Restart Steam to apply Steam Input.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.spanish ? 'Entendido' : 'Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final ready = result?.isReady ?? false;
    final hasMissingRules = result != null && result.missing.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  _Header(
                    spanish: widget.spanish,
                    onLanguageChanged: widget.onLanguageChanged,
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _Hero(spanish: widget.spanish),
                          const SizedBox(height: 28),
                          if (_error != null) _ErrorBanner(message: _error!),
                          if (result == null && _error == null)
                            _IntroCard(spanish: widget.spanish),
                          if (result != null)
                            _StatusCard(
                              result: result,
                              spanish: widget.spanish,
                            ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _checking || _installing
                                    ? null
                                    : _check,
                                icon: const Icon(Icons.refresh),
                                label: Text(_checkLabel),
                              ),
                              if (hasMissingRules) ...[
                                const SizedBox(width: 12),
                                FilledButton.icon(
                                  onPressed: _checking || _installing
                                      ? null
                                      : _install,
                                  icon: _installing
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.admin_panel_settings),
                                  label: Text(
                                    widget.spanish
                                        ? 'Añadir reglas faltantes'
                                        : 'Add missing rules',
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (ready) _ReadyBanner(spanish: widget.spanish),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    widget.spanish
                        ? 'Solo modifica reglas udev de Steam Input.'
                        : 'Only Steam Input udev rules are changed.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.spanish, required this.onLanguageChanged});

  final bool spanish;
  final ValueChanged<bool> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.gamepad, color: Color(0xff9f91ff), size: 30),
        const SizedBox(width: 10),
        Text(
          'Steam Input Setup',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('EN')),
            ButtonSegment(value: true, label: Text('ES')),
          ],
          selected: {spanish},
          onSelectionChanged: (selection) => onLanguageChanged(selection.first),
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.spanish});

  final bool spanish;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff1b1a2b),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xff6d5dfc).withValues(alpha: .18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.sports_esports,
                size: 62,
                color: Color(0xffb5adff),
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spanish
                        ? 'PS5 DualSense + Steam Input'
                        : 'PS5 DualSense + Steam Input',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spanish
                        ? 'Configura tu mando en Linux de forma segura y automática.'
                        : 'Configure your controller on Linux safely and automatically.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Text(
              'PS5',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.spanish});

  final bool spanish;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spanish ? 'Listo para comenzar' : 'Ready to get started',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            spanish
                ? 'Comprobaremos Steam y las reglas 60-steam-input.rules y 70-steam-input.rules antes de hacer cambios.'
                : 'We will check Steam and the 60-steam-input.rules and 70-steam-input.rules files before making changes.',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.result, required this.spanish});

  final VerificationResult result;
  final bool spanish;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CheckRow(
            icon: Icons.videogame_asset,
            title: 'Steam',
            detail: result.steamInstalled
                ? (spanish
                      ? 'Encontrado en el sistema'
                      : 'Found on this system')
                : (spanish ? 'No se encontró Steam' : 'Steam was not found'),
            ok: result.steamInstalled,
          ),
          const Divider(height: 28),
          _CheckRow(
            icon: Icons.description_outlined,
            title: '60-steam-input.rules',
            detail: result.has60
                ? (spanish ? 'Ya existe' : 'Already exists')
                : (spanish
                      ? 'Falta y se puede añadir'
                      : 'Missing and can be added'),
            ok: result.has60,
          ),
          const SizedBox(height: 14),
          _CheckRow(
            icon: Icons.description_outlined,
            title: '70-steam-input.rules',
            detail: result.has70
                ? (spanish ? 'Ya existe' : 'Already exists')
                : (spanish
                      ? 'Falta y se puede añadir'
                      : 'Missing and can be added'),
            ok: result.has70,
          ),
          if (result.missing.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              spanish ? 'Se añadirán:' : 'Will be added:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              result.missing.join(', '),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.ok,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ok ? Colors.greenAccent : Colors.orangeAccent),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(detail, style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ),
        Icon(
          ok ? Icons.check_circle : Icons.warning_amber_rounded,
          color: ok ? Colors.greenAccent : Colors.orangeAccent,
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff191925),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff3b2028),
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.redAccent),
        title: const Text('Unable to complete the check'),
        subtitle: Text(message),
      ),
    );
  }
}

class _ReadyBanner extends StatelessWidget {
  const _ReadyBanner({required this.spanish});

  final bool spanish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Text(
        spanish
            ? 'Todo está configurado. Reinicia Steam si acabas de conectar el mando.'
            : 'Everything is configured. Restart Steam if you just connected the controller.',
        style: const TextStyle(color: Colors.greenAccent),
      ),
    );
  }
}

class SteamInputInstaller {
  static const _rules = '''
# PS5 DualSense over USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"

# PS5 DualSense over Bluetooth
KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"

# DualSense Edge USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"

# DualSense Edge Bluetooth
KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
''';

  static const _directories = ['/usr/lib/udev/rules.d', '/etc/udev/rules.d'];

  Future<VerificationResult> verify() async {
    if (!Platform.isLinux) {
      throw UnsupportedError('This installer is supported on Linux only.');
    }
    final steam = await Process.run('sh', [
      '-c',
      'command -v steam || test -x "\$HOME/.local/share/Steam/steam"',
    ]);
    final existing = <String>{};
    for (final directory in _directories) {
      for (final name in ['60-steam-input.rules', '70-steam-input.rules']) {
        if (await File('$directory/$name').exists()) existing.add(name);
      }
    }
    final rulesDirectory = _directories.firstWhere(
      (directory) => File('$directory/60-steam-input.rules').existsSync(),
      orElse: () => _directories.first,
    );
    return VerificationResult(
      steamInstalled: steam.exitCode == 0,
      has60: existing.contains('60-steam-input.rules'),
      has70: existing.contains('70-steam-input.rules'),
      rulesDirectory: rulesDirectory,
    );
  }

  Future<void> install(VerificationResult result) async {
    if (!result.steamInstalled) {
      throw StateError(
        'Steam must be installed before configuring Steam Input.',
      );
    }
    final target60 = '${result.rulesDirectory}/60-steam-input.rules';
    final target70 = '${result.rulesDirectory}/70-steam-input.rules';
    final script = StringBuffer('set -eu\n');
    if (!result.has60) {
      script
        ..writeln("mkdir -p '${result.rulesDirectory}'")
        ..writeln("cat > '$target60.tmp' <<'RULES'")
        ..writeln(_rules)
        ..writeln('RULES')
        ..writeln("mv '$target60.tmp' '$target60'");
    }
    if (!result.has70) {
      script
        ..writeln("mkdir -p '${result.rulesDirectory}'")
        ..writeln("if test -f '$target60'; then")
        ..writeln("  cat > '$target70.tmp' <<'RULES'")
        ..writeln(_rules)
        ..writeln('RULES')
        ..writeln("  mv '$target70.tmp' '$target70'")
        ..writeln('fi');
    }
    script
      ..writeln('udevadm control --reload-rules')
      ..writeln('udevadm trigger');
    final process = await Process.run('pkexec', [
      'sh',
      '-c',
      script.toString(),
    ]);
    if (process.exitCode != 0) {
      throw StateError(
        (process.stderr as String).trim().isEmpty
            ? 'Administrator authorization was cancelled.'
            : (process.stderr as String).trim(),
      );
    }
  }
}

class VerificationResult {
  const VerificationResult({
    required this.steamInstalled,
    required this.has60,
    required this.has70,
    required this.rulesDirectory,
  });

  final bool steamInstalled;
  final bool has60;
  final bool has70;
  final String rulesDirectory;

  bool get isReady => steamInstalled && has60 && has70;

  List<String> get missing => [
    if (!steamInstalled) 'Steam',
    if (!has60) '60-steam-input.rules',
    if (!has70) '70-steam-input.rules',
  ];
}
