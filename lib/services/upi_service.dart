import 'package:url_launcher/url_launcher.dart';

class UpiService {
  static String buildPayUri({
    required String vpa,
    required String payeeName,
    required double amount,
    String? note,
  }) {
    final params = <String, String>{
      'pa': vpa,
      'pn': payeeName,
      'am': amount.toStringAsFixed(2),
      'cu': 'INR',
      if (note != null && note.trim().isNotEmpty) 'tn': note.trim(),
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'upi://pay?$query';
  }

  static bool looksLikeUpiUri(String value) =>
      value.trim().toLowerCase().startsWith('upi://');

  static Future<bool> launch(String upiUri) async {
    final uri = Uri.tryParse(upiUri);
    if (uri == null) return false;
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
