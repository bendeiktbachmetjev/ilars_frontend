import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/api_service.dart';
import '../../../theme/apple_style.dart';
import 'pill_button.dart';

/// Login form embedded on the dashboard when no patient code is stored yet.
///
/// Logic is intentionally kept 1:1 with the original implementation — only
/// the visual shell has changed.
class InlineLoginForm extends StatefulWidget {
  const InlineLoginForm({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  State<InlineLoginForm> createState() => _InlineLoginFormState();
}

class _InlineLoginFormState extends State<InlineLoginForm> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _agreedToTerms = false;
  bool _agreedToPromos = false;
  bool _isSubmitting = false;

  Future<void> _submit(AppLocalizations l10n) async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error('Please enter a patient code'))),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error(l10n.agreeToTerms))),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final api = ApiService();

      // 1. Validate the code
      final validateResponse = await api.validatePatientCode(patientCode: code);
      if (validateResponse['status'] != 'ok') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validateResponse['detail'] != null
                ? l10n.error(validateResponse['detail'])
                : l10n.error('Invalid patient code')),
            backgroundColor: Colors.red[700],
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // 2. Update the profile with email and consents
      final email = _emailController.text.trim();
      await api.updatePatientProfile(
        patientCode: code,
        email: email.isEmpty ? null : email,
        agreedToTerms: _agreedToTerms,
        agreedToPromos: _agreedToPromos,
      );

      // 3. Save the code locally
      await api.savePatientCode(code);

      // 4. Trigger dashboard reload
      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.error(e.toString())),
          backgroundColor: Colors.red[700],
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppleStyle.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.pleaseSetPatientCode,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppleStyle.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _codeController,
            decoration: AppleStyle.appleInputDecoration(
              l10n.enterYourCode,
              label: l10n.patientCode,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: AppleStyle.appleInputDecoration(
              l10n.emailOptional,
              label: l10n.emailAddress,
            ),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: Text(
              l10n.agreeToTerms,
              style: const TextStyle(fontSize: 14),
            ),
            value: _agreedToTerms,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppleStyle.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onChanged: (bool? value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: Text(
              l10n.agreeToPromos,
              style: const TextStyle(fontSize: 14),
            ),
            value: _agreedToPromos,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppleStyle.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onChanged: (bool? value) {
              setState(() {
                _agreedToPromos = value ?? false;
              });
            },
          ),
          const SizedBox(height: 16),
          PillButton(
            label: l10n.logIn,
            icon: _isSubmitting ? null : Icons.arrow_forward_rounded,
            onPressed: _isSubmitting ? () {} : () => _submit(l10n),
            style: PillButtonStyle.primary,
          ),
          if (_isSubmitting) ...[
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
