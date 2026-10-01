import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';
import '../providers/sign_in_provider.dart';


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final signIn = ref.read(signInProvider);

    try {
      final user = await signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (user == null) {
        setState(() => _error = "Identifiants incorrects");
        return;
      }

      switch (user.role) {
        case "client":
          context.go('/client');
          break;
        case "pharmacy":
          context.go('/pharmacy');
          break;
        case "admin":
          context.go('/admin');
          break;
        default:
          context.go('/');
      }
    } catch (e) {
      setState(() => _error = "Erreur : $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    authState.when(
      data: (user) {
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (user.role) {
              case "client":
                context.go('/client');
                break;
              case "pharmacy":
                context.go('/pharmacy');
                break;
              case "admin":
                context.go('/admin');
                break;
              default:
                context.go('/');
            }
          });
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Mot de passe"),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text("Se connecter"),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/signup-client'),
                  child: const Text("Créer un compte client"),
                ),
                TextButton(
                  onPressed: () => context.go('/signup-pharmacy'),
                  child: const Text("Inscription pharmacie"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
