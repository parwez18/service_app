import 'package:url_launcher/url_launcher.dart';

class HelperRepoServices {
  // Privacy Policy
  static Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      "https://privacy.creatorsmind.co.in/hello-dost-app-privacy-policy/",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Terms & Conditions
  static Future<void> openTermsAndConditions() async {
    final Uri url = Uri.parse(
      "https://listwr.com/live-terms-and-conditions&token=72898beedfa68d6002a79c7bec94af9258bb6e2c",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
