// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
//
// class SignupPharmacyPage extends ConsumerStatefulWidget {
//   const SignupPharmacyPage({super.key});
//
//   @override
//   ConsumerState<SignupPharmacyPage> createState() => _SignupPharmacyPageState();
// }
//
// class _SignupPharmacyPageState extends ConsumerState<SignupPharmacyPage> {
//   final _nomCtrl = TextEditingController();
//   final _responsableCtrl = TextEditingController();
//   final _contactCtrl = TextEditingController();
//   final _localisationCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//
//   File? _verificationFile;
//
//   bool _loading = false;
//   String? _error;
//
//   Future<void> _pickDocument() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//
//     if (result != null) {
//       setState(() {
//         _verificationFile = File(result.files.single.path!);
//       });
//     }
//   }
//
//   Future<void> _signup() async {
//     if (_verificationFile == null) {
//       setState(() => _error = "Veuillez ajouter un document PDF de vérification");
//       return;
//     }
//
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//
//     final signUp = ref.read(signUpPharmacyProvider);
//
//     try {
//       await signUp(
//         nom: _nomCtrl.text.trim(),
//         responsable: _responsableCtrl.text.trim(),
//         contact: _contactCtrl.text.trim(),
//         localisation: _localisationCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         password: _passwordCtrl.text.trim(),
//         verificationDocumentPath: _verificationFile!.path,
//       );
//
//       context.go('/pharmacy');
//     } catch (e) {
//       setState(() => _error = "Erreur : $e");
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Inscription pharmacie")),
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 500),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: ListView(
//               children: [
//                 TextField(controller: _nomCtrl, decoration: const InputDecoration(labelText: "Nom de la pharmacie")),
//                 const SizedBox(height: 12),
//                 TextField(controller: _responsableCtrl, decoration: const InputDecoration(labelText: "Nom du responsable")),
//                 const SizedBox(height: 12),
//                 TextField(controller: _contactCtrl, decoration: const InputDecoration(labelText: "Contact")),
//                 const SizedBox(height: 12),
//                 TextField(controller: _localisationCtrl, decoration: const InputDecoration(labelText: "Localisation")),
//                 const SizedBox(height: 12),
//                 TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email")),
//                 const SizedBox(height: 12),
//                 TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
//                 const SizedBox(height: 16),
//
//                 ElevatedButton(
//                   onPressed: _pickDocument,
//                   child: const Text("Ajouter document PDF de vérification"),
//                 ),
//
//                 if (_verificationFile != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text("Document sélectionné : ${_verificationFile!.path.split('/').last}"),
//                   ),
//
//                 const SizedBox(height: 16),
//
//                 if (_error != null)
//                   Text(_error!, style: const TextStyle(color: Colors.red)),
//
//                 const SizedBox(height: 16),
//
//                 ElevatedButton(
//                   onPressed: _loading ? null : _signup,
//                   child: _loading
//                       ? const CircularProgressIndicator()
//                       : const Text("Créer le compte pharmacie"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
