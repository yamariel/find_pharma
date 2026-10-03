import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VisitorHomePage extends StatelessWidget {
  const VisitorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // LOGO
              SizedBox(
                height: 100,
                width: 100,
                child: Image.asset('assets/images/find_pharma_icon.png'),
              ),

              const SizedBox(height: 10),
              const Text(
                "FindPharma",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Bienvenue sur FindPharma",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),
              const Text(
                "Recherchez des médicaments, trouvez des pharmacies\net découvrez nos services.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Se connecter"),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () => context.push('/signup-client'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Créer un compte"),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () => context.push('/signup-pharmacy'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Inscription pharmacie"),
              ),

              const Spacer(),

              const Text(
                "Accédez à plus de fonctionnalités en créant un compte.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
