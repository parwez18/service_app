import 'package:url_launcher/url_launcher.dart';

class HelperRepoServices {
  // Privacy Policy
  static Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      "https://privacy.creatorsmind.co.in/khujo-app-privacy-policy/",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Terms & Conditions
  static Future<void> openTermsAndConditions() async {
    final Uri url = Uri.parse(
      "https://www.termsfeed.com/live/23b43d7d-1797-4bf2-b155-eb740f6e6f6c",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
