import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'vnpay_config.dart';

class VNPayHelper {
  /// Ký HMAC-SHA512 — key là HashSecret, data là chuỗi hash
  static String _hmacSHA512(String key, String data) {
    final hmac = Hmac(sha512, utf8.encode(key));
    return hmac.convert(utf8.encode(data)).toString();
  }

  /// Xây chuỗi hash: sort key → key=urlEncode(value)&...
  static String _buildHashData(Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    return sortedKeys
        .where((k) => params[k]!.isNotEmpty)
        .map((k) => '$k=${Uri.encodeQueryComponent(params[k]!)}')
        .join('&');
  }

  /// Xây query string cho URL: sort key → urlEncode(key)=urlEncode(value)&...
  static String _buildQueryString(Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    return sortedKeys
        .where((k) => params[k]!.isNotEmpty)
        .map((k) =>
            '${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(params[k]!)}')
        .join('&');
  }

  /// Tạo URL thanh toán VNPAY đã ký.
  ///
  /// [amountVnd] : số tiền đơn vị VND (ví dụ 50000 = 50.000 VNĐ)
  /// [orderInfo] : mô tả đơn hàng (tiếng Việt không dấu để tránh encode phức tạp)
  /// [txnRef]   : mã giao dịch duy nhất của merchant
  /// [ipAddr]   : IP client (demo dùng 127.0.0.1)
  static String createPaymentUrl({
    required int amountVnd,
    required String orderInfo,
    required String txnRef,
    String ipAddr = '127.0.0.1',
  }) {
    final now = DateTime.now();

    final params = <String, String>{
      'vnp_Version': VNPayConfig.version,
      'vnp_Command': VNPayConfig.command,
      'vnp_TmnCode': VNPayConfig.tmnCode,
      // VNPAY yêu cầu nhân 100 (không có dấu phân cách)
      'vnp_Amount': (amountVnd * 100).toString(),
      'vnp_CurrCode': VNPayConfig.currCode,
      'vnp_TxnRef': txnRef,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_Locale': VNPayConfig.locale,
      'vnp_ReturnUrl': VNPayConfig.returnUrl,
      'vnp_IpAddr': ipAddr,
      'vnp_CreateDate': _formatDate(now),
      'vnp_ExpireDate': _formatDate(now.add(const Duration(minutes: 15))),
    };

    final hashData = _buildHashData(params);
    final secureHash = _hmacSHA512(VNPayConfig.hashSecret, hashData);

    final query = _buildQueryString(params);
    return '${VNPayConfig.baseUrl}?$query&vnp_SecureHash=$secureHash';
  }

  /// Format: yyyyMMddHHmmss
  static String _formatDate(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}${p(dt.month)}${p(dt.day)}'
        '${p(dt.hour)}${p(dt.minute)}${p(dt.second)}';
  }
}
