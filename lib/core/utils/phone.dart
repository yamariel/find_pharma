import 'package:url_launcher/url_launcher.dart';

/// Ouvre le composeur du téléphone sur [phoneNumber].
///
/// Sans application d'appel — sur le web, par exemple — la fonction ne fait
/// rien : le numéro reste affiché à l'écran, l'utilisateur le compose à la main.
Future<void> launchPhoneCall(String phoneNumber) async {
  final Uri uri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(' ', ''));
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}