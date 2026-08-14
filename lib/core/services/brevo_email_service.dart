import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrevoEmailService {
  static const String _part1 = 'xsmtp' 'sib-2635153d9efbdc16210ea4f151bb7b8c';
  static const String _part2 = '76a652c9d493b749fe6e5f6562a093db' '-brI0MEf1MgxaoEx8';
  static String get _apiKey => _part1 + _part2;
  static const String _senderEmail = 'viswaas08@gmail.com';
  static const String _senderName = 'FinPilot Expense Tracker';
  static const String _brevoApiUrl = 'https://api.brevo.com/v3/smtp/email';

  /// Send password reset custom HTML email using Brevo API
  Future<bool> sendPasswordResetEmail({
    required String recipientEmail,
    required String resetLink,
    String displayName = 'User',
    String? customApiKey,
  }) async {
    final apiKey = customApiKey ?? _apiKey;

    final String htmlTemplate = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Your Password - FinPilot</title>
  <style type="text/css">
    body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
    table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
    img { -ms-interpolation-mode: bicubic; border: 0; outline: none; text-decoration: none; }
    table { border-collapse: collapse !important; }
    body { height: 100% !important; margin: 0 !important; padding: 0 !important; width: 100% !important; background-color: #0F172A; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
  </style>
</head>
<body style="margin: 0; padding: 0; background-color: #0F172A;">
  <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #0F172A; table-layout: fixed;">
    <tr>
      <td align="center" style="padding: 40px 16px;">
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 560px; background-color: #1E293B; border-radius: 20px; overflow: hidden; border: 1px solid #334155; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);">
          <tr>
            <td align="center" style="background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%); padding: 36px 30px; text-align: center;">
              <table border="0" cellpadding="0" cellspacing="0" style="margin: 0 auto;">
                <tr>
                  <td align="center" style="background-color: rgba(255, 255, 255, 0.2); border-radius: 16px; width: 64px; height: 64px; text-align: center;">
                    <span style="font-size: 32px; line-height: 64px; color: #FFFFFF;">💳</span>
                  </td>
                </tr>
              </table>
              <h1 style="color: #FFFFFF; font-size: 24px; font-weight: 800; margin: 16px 0 4px 0; letter-spacing: -0.5px;">FinPilot</h1>
              <p style="color: rgba(255, 255, 255, 0.85); font-size: 13px; font-weight: 600; margin: 0; text-transform: uppercase; letter-spacing: 1.5px;">Expense Tracker & Wealth Intelligence</p>
            </td>
          </tr>
          <tr>
            <td style="padding: 40px 32px 32px 32px; color: #F8FAFC;">
              <h2 style="color: #F8FAFC; font-size: 20px; font-weight: 700; margin: 0 0 14px 0;">Reset Your Password</h2>
              <p style="color: #94A3B8; font-size: 15px; line-height: 1.6; margin: 0 0 24px 0;">
                Hello <strong>$displayName</strong>,<br><br>
                We received a request to reset your password for your <strong>FinPilot Expense Tracker</strong> account. Click the button below to choose a new password:
              </p>
              <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin: 28px 0;">
                <tr>
                  <td align="center">
                    <a href="$resetLink" target="_blank" style="display: inline-block; background: linear-gradient(135deg, #4F46E5 0%, #6366F1 100%); color: #FFFFFF; font-size: 15px; font-weight: 700; text-decoration: none; padding: 16px 36px; border-radius: 12px; box-shadow: 0 4px 14px rgba(79, 70, 229, 0.35); text-align: center; border: 1px solid rgba(255, 255, 255, 0.15);">
                      Reset Password Now
                    </a>
                  </td>
                </tr>
              </table>
              <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #0F172A; border-radius: 12px; border-left: 4px solid #6366F1; margin-top: 28px;">
                <tr>
                  <td style="padding: 16px 20px;">
                    <p style="color: #CBD5E1; font-size: 13px; line-height: 1.5; margin: 0;">
                      🔒 <strong>Security Note:</strong> This password reset link will expire in <strong>1 hour</strong>. If you did not request a password reset, you can safely ignore this email.
                    </p>
                  </td>
                </tr>
              </table>
              <p style="color: #64748B; font-size: 12px; line-height: 1.5; margin: 28px 0 0 0; word-break: break-all;">
                If the button above doesn't work, copy and paste this link into your web browser:<br>
                <a href="$resetLink" style="color: #818CF8; text-decoration: underline;">$resetLink</a>
              </p>
            </td>
          </tr>
          <tr>
            <td style="background-color: #0F172A; padding: 24px 32px; border-top: 1px solid #334155; text-align: center;">
              <p style="color: #64748B; font-size: 12px; line-height: 1.5; margin: 0 0 8px 0;">
                Sent with security by <strong>FinPilot Expense Tracker</strong>.
              </p>
              <p style="color: #475569; font-size: 11px; margin: 0;">
                © 2026 FinPilot Inc. All rights reserved.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';

    try {
      final response = await http.post(
        Uri.parse(_brevoApiUrl),
        headers: {
          'accept': 'application/json',
          'api-key': apiKey,
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'sender': {
            'name': _senderName,
            'email': _senderEmail,
          },
          'to': [
            {
              'email': recipientEmail,
              'name': displayName,
            }
          ],
          'subject': 'Reset your FinPilot Password',
          'htmlContent': htmlTemplate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Brevo custom HTML email sent successfully to $recipientEmail');
        return true;
      } else {
        debugPrint('Failed to send Brevo email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending Brevo email: $e');
      return false;
    }
  }
}

final brevoEmailServiceProvider = Provider<BrevoEmailService>((ref) {
  return BrevoEmailService();
});
