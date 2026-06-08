import 'package:flutter/material.dart';

/// Page de connexion (AU-1).
///
/// Contient le formulaire e-mail / mot de passe et le bouton biométrie.
/// TODO: Connecter au AuthProvider / AuthCubit pour appeler LoginUseCase.
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
      // TODO: Appeler le provider/cubit pour déclencher LoginUseCase
      // context.read<AuthProvider>().login(
      //   _emailController.text.trim(),
      //   _motDePasseController.text,
      // );
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
            child: Form(
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
                  const SizedBox(height: 48),

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
                        // TODO: Navigation vers page de récupération
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Bouton Login ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onLogin,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Biométrie ──
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Appeler local_auth pour la biométrie
                    },
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use Biometrics'),
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
                          // TODO: Navigation vers page d'inscription
                        },
                        child: const Text('Sign Up'),
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
