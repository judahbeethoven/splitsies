import 'package:url_launcher/url_launcher.dart';

/// Builds and fires UPI deep links (`upi://pay?...`). Stateless — just a
/// couple of static helpers around the standard UPI intent spec.
class UpiService {
  const UpiService._();

  /// A `upi://pay` URI a UPI app can open directly to pay [vpa] the exact
  /// [amount]. This is what gets encoded into the QR each ower scans, and
  /// what "open UPI app" launches straight from the same device.
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

  /// Opens [upiUri] in whatever UPI app the phone has. Returns false if
  /// nothing on the device can handle it.
  static Future<bool> launch(String upiUri) async {
    final uri = Uri.tryParse(upiUri);
    if (uri == null) return false;
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
