import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../l10n/app_localizations.dart';
import '../../theme/apple_style.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppleStyle.surface,
      appBar: AppBar(
        title: Text(
          l10n.termsOfUse,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: AppleStyle.surface,
        surfaceTintColor: AppleStyle.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppleStyle.primaryText,
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/legal/terms_of_use.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Failed to load Terms of Use.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppleStyle.cardDecoration(),
              child: SelectableText(
                snapshot.data ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: AppleStyle.primaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
