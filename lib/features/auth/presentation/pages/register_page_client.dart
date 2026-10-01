import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/sign_up_client_provider.dart';


class RegisterPageClient extends ConsumerStatefulWidget {
  const RegisterPageClient({super.key});

  @override
  ConsumerState<RegisterPageClient> createState() => _RegisterPageClientState();
}

class _RegisterPageClientState extends ConsumerState<RegisterPageClient> {
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final signUp = ref.read(signUpClientProvider);

    try {
      await signUp(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        adresse: _adresseCtrl.text.trim().isEmpty ? null : _adresseCtrl.text.trim(),
      );

      context.go('/client');
    } catch (e) {
      setState(() => _error = "Erreur : $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription client")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(controller: _nomCtrl, decoration: const InputDecoration(labelText: "Nom")),
                const SizedBox(height: 12),
                TextField(controller: _prenomCtrl, decoration: const InputDecoration(labelText: "Prénom")),
                const SizedBox(height: 12),
                TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email")),
                const SizedBox(height: 12),
                TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
                const SizedBox(height: 12),
                TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Téléphone (optionnel)")),
                const SizedBox(height: 12),
                TextField(controller: _adresseCtrl, decoration: const InputDecoration(labelText: "Adresse (optionnel)")),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text("Créer le compte"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
