import 'package:flutter_test/flutter_test.dart';
import 'package:ps5_dualshok_steam_setup/main.dart';

class _FakeSteamInputInstaller extends SteamInputInstaller {
  @override
  Future<VerificationResult> verify() async => const VerificationResult(
        steamInstalled: true,
        has60: true,
        has70: true,
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
}
