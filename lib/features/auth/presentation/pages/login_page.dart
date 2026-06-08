import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Page de connexion (AU-1).
///
/// Contient le formulaire e-mail / mot de passe et le bouton biométrie.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _obscureMotDePasse = true;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    setState(() => _obscureMotDePasse = !_obscureMotDePasse);
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().login(
        _emailController.text.trim(),
        _motDePasseController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo / Titre ──
                      Icon(
                        Icons.nfc_rounded,
                        size: 64,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'FINTECH',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Secure. Fast. Effortless.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 32),

                      // Message d'erreur s'il existe
                      if (auth.status == AuthStatus.error && auth.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Champ Email ──
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre e-mail';
                          }
                          if (!value.contains('@')) {
                            return 'E-mail invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Champ Mot de passe ──
                      TextFormField(
                        controller: _motDePasseController,
                        obscureText: _obscureMotDePasse,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureMotDePasse
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: _toggleObscure,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // ── Mot de passe oublié ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Info de connexion par défaut pour aider l'utilisateur
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Compte démo : alex@example.com / password123'),
                              ),
                            );
                          },
                          child: const Text('Demo credentials?'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Bouton Login ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.status == AuthStatus.loading ? null : _onLogin,
                          child: auth.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_forward),
                                    SizedBox(width: 8),
                                    Text('Login'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Biométrie ──
                      OutlinedButton.icon(
                        onPressed: () {
                          // Simulation de la biométrie
                          _emailController.text = 'alex@example.com';
                          _motDePasseController.text = 'password123';
                          _onLogin();
                        },
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Use Biometrics (Demo)'),
                      ),
                      const SizedBox(height: 32),

                      // ── Lien inscription ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () {
                              // Auto-remplissage pour inscription
                              _emailController.text = 'alex@example.com';
                              _motDePasseController.text = 'password123';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Champs pré-remplis avec les accès démo !'),
                                ),
                              );
                            },
                            child: const Text('Get Demo Account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
