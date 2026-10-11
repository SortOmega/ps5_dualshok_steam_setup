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
