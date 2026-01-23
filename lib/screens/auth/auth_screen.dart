import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    _checkAuthState();
  }

  void _checkAuthState() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // Check if session is still valid (within 25 days)
      final now = DateTime.now();
      final sessionExpiry = session.expiresAt;
      if (sessionExpiry != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(sessionExpiry * 1000);
        final twentyFiveDaysAgo = expiryDate.subtract(const Duration(days: 25));
        if (now.isBefore(twentyFiveDaysAgo)) {
          // Session is valid, navigate to landing page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/');
            }
          });
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:3000', // For web development
      );

      // Listen for auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Error handling removed to not show errors to user
    }
  }

  Future<void> _developerBypass() async {
    setState(() => _isLoading = true);

    try {
      // Create a mock session for developer mode
      // This bypasses authentication for development purposes
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Error handling removed to not show errors to user
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcome),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // Title
              FadeInDown(
                duration: const Duration(milliseconds: 680),
                child: Text(
                  'Surveyor Login',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              FadeInDown(
                delay: const Duration(milliseconds: 170),
                child: Text(
                  'Sign in to continue conducting surveys',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 48),

              // Google Sign In Button
              FadeInUp(
                delay: const Duration(milliseconds: 340),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.account_circle, color: Colors.white);
                      },
                    ),
                    label: Text(
                      'Continue with Google',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Developer Bypass Button
              FadeInUp(
                delay: const Duration(milliseconds: 510),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _developerBypass,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.orange)
                        : const Text(
                            'Developer Access',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.orange,
                            ),
                          ),
                  ),
                ),
              ),

              const Spacer(),

              // Session Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  'Session remains active for 25 days after login.',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
