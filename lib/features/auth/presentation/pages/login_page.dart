import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';

/// Page de connexion et d'inscription (AU-1 / AU-2).
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
  bool _isRegisterMode = false;

  Future<void> _authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    
    // Check if device supports biometrics
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

    if (canAuthenticate) {
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to log in',
          options: const AuthenticationOptions(biometricOnly: false),
        );
        
        if (didAuthenticate) {
          // Perform login logic here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication successful')),
          );
          // Redirect to home/dashboard
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometrics not supported')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    setState(() => _obscureMotDePasse = !_obscureMotDePasse);
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _formKey.currentState?.reset();
    });
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      final email = _emailController.text.trim();
      final password = _motDePasseController.text;

      if (_isRegisterMode) {
        auth.register(email, password);
      } else {
        auth.login(email, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: !_isRegisterMode ? AppColors.lightBackgroundGradient : null,
          color: _isRegisterMode ? theme.scaffoldBackgroundColor : null,
        ),
        child: SafeArea(
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
                        const Icon(
                          Icons.nfc_rounded,
                          size: 80,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FINTECH',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          _isRegisterMode
                              ? 'Create your secure account'
                              : 'Secure. Fast. Effortless.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 40),

                        // Message d'erreur
                        if (auth.status == AuthStatus.error && auth.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    auth.errorMessage!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 13),
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
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Invalid email address';
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
                              return 'Please enter your password';
                            }
                            if (_isRegisterMode && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        if (!_isRegisterMode) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // ── Bouton Principal ──
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.status == AuthStatus.loading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: auth.status == AuthStatus.loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_isRegisterMode ? 'Sign Up' : 'Login'),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (!_isRegisterMode) ...[
                          const Text('OR', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 24),

                          // ── Biométrie ──
                          OutlinedButton.icon(
                            onPressed: _authenticateWithBiometrics,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Use Biometrics'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),

                        // ── Toggle Mode ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRegisterMode
                                  ? "Already have an account? "
                                  : "Don't have an account? ",
                              style: theme.textTheme.bodySmall,
                            ),
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isRegisterMode ? 'Login' : 'Sign Up',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
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
      ),
    );
  }
}
