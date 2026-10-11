import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ps5_dualshok_steam_setup/app/steam_input_app.dart';
import 'package:ps5_dualshok_steam_setup/services/steam_input_installer.dart';

class _FakeSteamInputInstaller extends SteamInputInstaller {
  @override
  Future<VerificationResult> verify() async => const VerificationResult(
    steamInstalled: true,
    has60: true,
    has70: true,
    rulesDirectory: '/usr/lib/udev/rules.d',
  );
}

class _SteamNotInstalledInstaller extends SteamInputInstaller {
  @override
  Future<VerificationResult> verify() async => const VerificationResult(
    steamInstalled: false,
    has60: false,
    has70: false,
    rulesDirectory: '/usr/lib/udev/rules.d',
  );
}

void main() {
  testWidgets('shows the Steam Input installer', (tester) async {
    await tester.pumpWidget(
      SteamInputInstallerApp(installer: _FakeSteamInputInstaller()),
    );

    expect(find.text('Steam Input Setup'), findsOneWidget);
    expect(find.text('PS5'), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);
    expect(find.text('GitHub repository'), findsOneWidget);
    expect(find.byIcon(Icons.code), findsOneWidget);
  });

  testWidgets('switches to Spanish', (tester) async {
    await tester.pumpWidget(
      SteamInputInstallerApp(installer: _FakeSteamInputInstaller()),
    );

    await tester.tap(find.text('ES'));
    await tester.pump();

    expect(find.text('Comprobar de nuevo'), findsOneWidget);
    expect(find.text('Check again'), findsNothing);
  });

  testWidgets('blocks setup when Steam is not installed', (tester) async {
    await tester.pumpWidget(
      SteamInputInstallerApp(installer: _SteamNotInstalledInstaller()),
    );
    await tester.pump();

    expect(
      find.text(
        'Steam is not installed. Install Steam to enable Steam Input setup.',
      ),
      findsOneWidget,
    );
    expect(find.text('Add missing rules'), findsNothing);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });
}
