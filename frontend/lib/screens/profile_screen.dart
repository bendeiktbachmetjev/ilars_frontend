import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onPatientCodeChanged;
  
  const ProfileScreen({super.key, this.onPatientCodeChanged});

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
      // Always refresh dashboard after saving patient code
      // This ensures chart and questionnaire data are updated with latest data from server
      // Add small delay to ensure SharedPreferences is fully updated
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
    // Always refresh dashboard after clearing patient code
    // This ensures chart shows "No patient code set" message immediately
    if (widget.onPatientCodeChanged != null) {
      widget.onPatientCodeChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                            l10n.patientCode,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _codeController,
                              decoration: InputDecoration(
                              hintText: l10n.enterYourCode,
                              border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _save,
                                child: Text(l10n.save),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: _clear,
                                child: Text(l10n.logout),
                                ),
                              ],
                            ),
                            if (_savedCode != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              if (_email?.isNotEmpty == true) ...[
                                Text(
                                  '${l10n.emailAddress}: $_email',
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_agreedToPromos) ...[
                                TextButton.icon(
                                  onPressed: _loading ? null : _unsubscribe,
                                  icon: const Icon(Icons.unsubscribe, size: 18),
                                  label: Text(l10n.unsubscribePromos),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red[700],
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  l10n.subscribePromos,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: l10n.emailAddress,
                                    isDense: true,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _loading ? null : _subscribe,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 40),
                                  ),
                                  child: Text(l10n.subscribePromos),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                    ],
                  ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(l10n.termsOfUse),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TermsOfUseScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: Text(l10n.privacyPolicy),
                            trailing: const Icon(Icons.chevron_right),
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

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
} 

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsOfUse),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/legal/terms_of_use.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load Terms of Use.',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: SelectableText(
                snapshot.data ?? '',
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/legal/privacy_policy.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load Privacy Policy.',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: SelectableText(
                snapshot.data ?? '',
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
          );
        },
      ),
    );
  }
} 