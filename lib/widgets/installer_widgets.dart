import 'package:flutter/material.dart';

import '../models/verification_result.dart';

class InstallerHeader extends StatelessWidget {
  const InstallerHeader({
    super.key,
    required this.spanish,
    required this.onLanguageChanged,
  });

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

class InstallerHero extends StatelessWidget {
  const InstallerHero({super.key, required this.spanish});

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
                    'PS5 DualSense + Steam Input',
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

class SteamMissingBanner extends StatelessWidget {
  const SteamMissingBanner({super.key, required this.spanish});

  final bool spanish;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff4a2028),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.redAccent, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                spanish
                    ? 'Steam no está instalado. Instala Steam para habilitar la configuración de Steam Input.'
                    : 'Steam is not installed. Install Steam to enable Steam Input setup.',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IntroCard extends StatelessWidget {
  const IntroCard({super.key, required this.spanish});

  final bool spanish;

  @override
  Widget build(BuildContext context) {
    return InstallerPanel(
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

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.result,
    required this.spanish,
  });

  final VerificationResult result;
  final bool spanish;

  @override
  Widget build(BuildContext context) {
    return InstallerPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckRow(
            icon: Icons.videogame_asset,
            title: 'Steam',
            detail: result.steamInstalled
                ? (spanish ? 'Encontrado en el sistema' : 'Found on this system')
                : (spanish ? 'No se encontró Steam' : 'Steam was not found'),
            ok: result.steamInstalled,
          ),
          const Divider(height: 28),
          CheckRow(
            icon: Icons.description_outlined,
            title: '60-steam-input.rules',
            detail: result.has60
                ? (spanish ? 'Ya existe' : 'Already exists')
                : (spanish ? 'Falta y se puede añadir' : 'Missing and can be added'),
            ok: result.has60,
          ),
          const SizedBox(height: 14),
          CheckRow(
            icon: Icons.description_outlined,
            title: '70-steam-input.rules',
            detail: result.has70
                ? (spanish ? 'Ya existe' : 'Already exists')
                : (spanish ? 'Falta y se puede añadir' : 'Missing and can be added'),
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

class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
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

class InstallerPanel extends StatelessWidget {
  const InstallerPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff191925),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

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

class ReadyBanner extends StatelessWidget {
  const ReadyBanner({super.key, required this.spanish});

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
