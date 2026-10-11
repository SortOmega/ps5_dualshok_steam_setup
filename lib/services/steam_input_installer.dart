import 'dart:io';

import '../models/verification_result.dart';

export '../models/verification_result.dart';

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

  static const _directories = [
    '/usr/lib/udev/rules.d',
    '/etc/udev/rules.d',
  ];

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
