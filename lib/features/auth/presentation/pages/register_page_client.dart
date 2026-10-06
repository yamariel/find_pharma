import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_controller.dart';

class RegisterPageClient extends ConsumerStatefulWidget {
  final bool pharmacy;

  const RegisterPageClient({super.key, this.pharmacy = false});

  @override
  ConsumerState<RegisterPageClient> createState() => _RegisterPageClientState();
}

class _RegisterPageClientState extends ConsumerState<RegisterPageClient> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authOperation = ref.watch(authControllerProvider);
    final isLoading = authOperation.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (!context.mounted) return;

          debugPrint('Inscription impossible : $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inscription impossible!!'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // LOGO + TITRE
                Column(
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: Image.asset('assets/images/find_pharma_icon.png'),
                    ),
                    const Text(
                      "FindPharma",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.pharmacy
                          ? "Créer un compte pharmacie"
                          : "Créer un compte",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.pharmacy
                          ? "Référencez votre officine et gérez ses disponibilités."
                          : "Rejoignez FindPharma pour enregistrer vos pharmacies et médicaments favoris.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // GOOGLE BUTTON
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                    ref
                        .read(authControllerProvider.notifier)
                        .signUpWithGoogle();
                  },
                  icon: Image.asset('assets/images/google.png', height: 22),
                  label: const Text("S’inscrire avec Google"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text("ou avec une adresse e-mail"),
                const SizedBox(height: 20),

                // NOM COMPLET
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Nom complet",
                    hintText: "ex. Marc Dubois",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre nom complet";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // EMAIL
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: "Adresse e-mail",
                    hintText: "nom@exemple.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre e-mail";
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return "E-mail invalide";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // MOT DE PASSE
                TextFormField(
                  controller: passCtrl,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    hintText: "8 caractères minimum",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un mot de passe";
                    }
                    if (value.length < 8) {
                      return "8 caractères minimum";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // CONFIRMATION MOT DE PASSE
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirmer le mot de passe",
                    hintText: "Répétez le mot de passe",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez confirmer votre mot de passe";
                    }
                    if (value != passCtrl.text) {
                      return "Les mots de passe ne correspondent pas";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // BOUTON INSCRIPTION

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      final controller =
                          ref.read(authControllerProvider.notifier);
                      if (widget.pharmacy) {
                        controller.signUpPharmacy(
                          nameCtrl.text.trim(),
                          emailCtrl.text.trim(),
                          passCtrl.text,
                        );
                      } else {
                        controller.signUpClient(
                          nameCtrl.text.trim(),
                          emailCtrl.text.trim(),
                          passCtrl.text,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(widget.pharmacy
                          ? 'Créer mon compte pharmacie'
                          : 'Créer mon compte'),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous avez déjà un compte ?',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPagePharmacy extends RegisterPageClient {
  const RegisterPagePharmacy({super.key}) : super(pharmacy: true);
}
