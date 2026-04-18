import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../theme/apple_style.dart';
import '../dashboard/widgets/pill_button.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_use_screen.dart';
import 'widgets/profile_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onPatientCodeChanged});

  final VoidCallback? onPatientCodeChanged;

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _savedCode;
  String? _email;
  bool _agreedToPromos = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final code = await ApiService().getPatientCode();
    String? email;
    bool promos = false;

    if (code != null && code.isNotEmpty) {
      try {
        final profile = await ApiService().getPatientProfile(patientCode: code);
        if (profile['status'] == 'ok') {
          email = profile['email'] as String?;
          promos = profile['agreed_to_promos'] == true;
        }
      } catch (e) {
        debugPrint('Failed to load profile: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _savedCode = code;
      _email = email;
      _agreedToPromos = promos;
      _codeController.text = code ?? '';
      _emailController.text = email ?? '';
      _loading = false;
    });
  }

  Future<void> _unsubscribe() async {
    if (_savedCode == null) return;

    setState(() => _loading = true);
    try {
      final api = ApiService();
      final response = await api.unsubscribePatient(patientCode: _savedCode!);

      if (response['status'] == 'ok') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.unsubscribed)),
        );
        await loadProfile();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[700],
        ),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _subscribe() async {
    if (_savedCode == null) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _loading = true);
    try {
      final api = ApiService();
      final response = await api.subscribePatient(
        patientCode: _savedCode!,
        email: email,
      );

      if (response['status'] == 'ok') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.subscribed)),
        );
        await loadProfile();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[700],
        ),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      final api = ApiService();
      final response = await api.validatePatientCode(patientCode: code);
      if (response['status'] != 'ok') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['detail'] != null
                ? 'Error: ${response['detail']}'
                : 'Invalid patient code'),
            backgroundColor: Colors.red[700],
          ),
        );
        setState(() {
          _loading = false;
        });
        return;
      }

      await api.savePatientCode(code);
      await loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.patientCodeSaved)),
      );
      // Always refresh dashboard after saving patient code.
      // Small delay so SharedPreferences is fully committed first.
      await Future.delayed(const Duration(milliseconds: 100));
      if (widget.onPatientCodeChanged != null) {
        widget.onPatientCodeChanged!();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: Colors.red[700],
        ),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    await ApiService().clearPatientCode();
    await loadProfile();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.patientCodeCleared)),
    );
    if (widget.onPatientCodeChanged != null) {
      widget.onPatientCodeChanged!();
    }
  }

  // ---- Visual helpers ------------------------------------------------------

  Widget _buildCardTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppleStyle.primaryText,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Material(
        color: AppleStyle.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Material(
      color: AppleStyle.surface,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Patient code card ------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: AppleStyle.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardTitle(l10n.patientCode),
                    TextField(
                      controller: _codeController,
                      decoration:
                          AppleStyle.appleInputDecoration(l10n.enterYourCode),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: l10n.save,
                            onPressed: _save,
                            style: PillButtonStyle.primary,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PillButton(
                            label: l10n.logout,
                            onPressed: _clear,
                            icon: Icons.logout_rounded,
                            style: PillButtonStyle.secondary,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---- Email / Promotions card (only when signed in) ---------
              if (_savedCode != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: AppleStyle.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardTitle(l10n.emailAddress),
                      if (_email?.isNotEmpty == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppleStyle.inputFill,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mail_outline_rounded,
                                size: 18,
                                color: AppleStyle.accent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _email!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppleStyle.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_agreedToPromos) ...[
                        PillButton(
                          label: l10n.unsubscribePromos,
                          onPressed: _loading ? () {} : _unsubscribe,
                          icon: Icons.unsubscribe_rounded,
                          style: PillButtonStyle.destructive,
                          height: 48,
                        ),
                      ] else ...[
                        Text(
                          l10n.subscribePromos,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppleStyle.secondaryText,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: AppleStyle.appleInputDecoration(
                              l10n.emailAddress),
                        ),
                        const SizedBox(height: 12),
                        PillButton(
                          label: l10n.subscribePromos,
                          onPressed: _loading ? () {} : _subscribe,
                          style: PillButtonStyle.primary,
                          height: 48,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // ---- Legal list card ---------------------------------------
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                decoration: AppleStyle.cardDecoration(),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ProfileListTile(
                      leadingIcon: Icons.description_outlined,
                      label: l10n.termsOfUse,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsOfUseScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 56,
                      color: Color(0xFFE5E5EA),
                    ),
                    ProfileListTile(
                      leadingIcon: Icons.shield_outlined,
                      label: l10n.privacyPolicy,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
