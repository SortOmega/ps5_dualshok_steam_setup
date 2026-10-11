import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/steam_input_installer.dart';
import '../widgets/installer_widgets.dart';

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
  static final _repositoryUri = Uri.parse(
    'https://github.com/SortOmega/ps5_dualshok_steam_setup',
  );

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
    if (result == null || !result.steamInstalled) return;
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

  Future<void> _openRepository() async {
    final opened = await launchUrl(
      _repositoryUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.spanish
                ? 'No se pudo abrir el repositorio de GitHub.'
                : 'The GitHub repository could not be opened.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final ready = result?.isReady ?? false;
    final hasMissingRules =
        result != null && result.steamInstalled && result.missing.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  InstallerHeader(
                    spanish: widget.spanish,
                    onLanguageChanged: widget.onLanguageChanged,
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InstallerHero(spanish: widget.spanish),
                          const SizedBox(height: 28),
                          if (_error != null) ErrorBanner(message: _error!),
                          if (result == null && _error == null)
                            IntroCard(spanish: widget.spanish),
                          if (result != null)
                            StatusCard(result: result, spanish: widget.spanish),
                          if (result != null && !result.steamInstalled)
                            SteamMissingBanner(spanish: widget.spanish),
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
                          if (ready) ReadyBanner(spanish: widget.spanish),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        widget.spanish
                            ? 'Solo modifica reglas udev de Steam Input.'
                            : 'Only Steam Input udev rules are changed.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: Colors.white54),
                      ),
                      TextButton.icon(
                        onPressed: _openRepository,
                        icon: const Icon(Icons.code, size: 18),
                        label: const Text('GitHub repository'),
                      ),
                    ],
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
