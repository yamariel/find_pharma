import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VisitorClientNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVisitor;

  const VisitorClientNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isVisitor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (isVisitor && (index == 3 || index == 4)) {
          // Assistant ou Profil → visiteur → redirection
          context.push('/signup/client');
          return;
        }
        onTap(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: "Carte",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: "Médicaments",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: "Garde",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: "Assistant",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}
