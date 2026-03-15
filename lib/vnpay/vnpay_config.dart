/// Cấu hình sandbox VNPAY — demo only.
/// Thay YOUR_TMN_CODE và YOUR_HASH_SECRET bằng thông tin sandbox của bạn
/// (nhận từ VNPAY khi đăng ký tài khoản merchant sandbox).
class VNPayConfig {
  /// Mã website tại hệ thống VNPAY (sandbox)
  static const String tmnCode = 'UWGK65VP';

  /// Chuỗi bí mật dùng để tạo chữ ký HMAC-SHA512
  static const String hashSecret = 'H07GLVJXOTQ2JOZDD7M4K8Y9SUQ37R6L';

  /// URL cổng thanh toán VNPAY sandbox
  static const String baseUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';

  static const String version = '2.1.0';
  static const String command = 'pay';
  static const String currCode = 'VND';
  static const String locale = 'vn';

  /// Return URL để WebView chặn kết quả (demo — không cần backend)
  static const String returnUrl = 'myapp://payment-result';
}
