import 'package:flutter/material.dart';
import 'vnpay_helper.dart';
import 'vnpay_result.dart';
import 'vnpay_webview_page.dart';

/// Màn hình demo thanh toán VNPAY.
/// Hiển thị thông tin đơn hàng giả, nút thanh toán, và kết quả trả về.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const _primary = Color(0xFF0B4FA9);
  static const _primaryDark = Color(0xFF0A2F63);
  static const _ink = Color(0xFF0F1A2C);

  // Dữ liệu đơn hàng demo
  static const _orderItems = [
    _OrderItem('Khóa học Flutter cơ bản', 299000),
    _OrderItem('Khóa học VNPAY Integration', 199000),
  ];

  static const _totalAmount = 299000 + 199000; // = 498.000 VNĐ

  bool _paying = false;
  VNPayResult? _result;

  Future<void> _pay() async {
    setState(() {
      _paying = true;
      _result = null;
    });

    // txnRef phải unique mỗi giao dịch — dùng timestamp cho demo
    final txnRef = DateTime.now().millisecondsSinceEpoch.toString();

    final paymentUrl = VNPayHelper.createPaymentUrl(
      amountVnd: _totalAmount,
      orderInfo: 'Thanh toan don hang $txnRef',
      txnRef: txnRef,
    );

    final returnedUrl = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => VNPayWebViewPage(paymentUrl: paymentUrl),
      ),
    );

    setState(() => _paying = false);

    if (returnedUrl == null) return; // Người dùng bấm X đóng WebView

    setState(() => _result = VNPayResult.fromUrl(returnedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FB),
      appBar: AppBar(title: const Text('Thanh toán đơn hàng')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F3FF), Color(0xFFF7FAFF), Color(0xFFF2F6FB)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primary, _primaryDark],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x330A2F63),
                      blurRadius: 22,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VNPAY Sandbox',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatVnd(_totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sẵn sàng thanh toán cho 2 sản phẩm',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Thông tin đơn hàng',
                subtitle: 'Chi tiết các khóa học đã chọn',
                icon: Icons.receipt_long_rounded,
                child: Column(
                  children: [
                    ..._orderItems.map(
                      (item) => _ItemRow(name: item.name, price: item.price),
                    ),
                    const Divider(height: 24, color: Color(0xFFDCE6F3)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          _formatVnd(_totalAmount),
                          style: const TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Phương thức thanh toán',
                subtitle: 'Kết nối cổng VNPAY trong môi trường test',
                icon: Icons.account_balance_wallet_rounded,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4E4F8)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_primary, _primaryDark],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'VN\nPAY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VNPAY',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Thanh toán qua cổng VNPAY (Sandbox)',
                              style: TextStyle(
                                color: Color(0xFF5E6C7D),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.verified_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _paying ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _paying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.6,
                          ),
                        )
                      : Text('Thanh toán ngay • ${_formatVnd(_totalAmount)}'),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                _ResultCard(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets nội bộ
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE6F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: _PaymentPageState._primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F1A2C),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF677789),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String name;
  final int price;

  const _ItemRow({required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF1A2637),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            _formatVnd(price),
            style: const TextStyle(
              color: Color(0xFF405163),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final VNPayResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.isSuccess
        ? const Color(0xFF18924E)
        : const Color(0xFFD63B3B);
    final icon = result.isSuccess
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.message,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFDCE6F3)),
          _ResultRow('Mã giao dịch VNPAY', result.transactionNo ?? '-'),
          _ResultRow('Mã đơn hàng', result.txnRef ?? '-'),
          _ResultRow('Số tiền', result.displayAmount),
          _ResultRow('Ngân hàng', result.bankCode ?? '-'),
          _ResultRow('Thời gian', _formatPayDate(result.payDate)),
          _ResultRow('ResponseCode', result.responseCode ?? '-'),
          _ResultRow('TransactionStatus', result.transactionStatus ?? '-'),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF68798E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1B2838),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _OrderItem {
  final String name;
  final int price;

  const _OrderItem(this.name, this.price);
}

String _formatVnd(int amount) {
  return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VNĐ';
}

String _formatPayDate(String? raw) {
  if (raw == null || raw.length < 14) return raw ?? '-';
  // yyyyMMddHHmmss → dd/MM/yyyy HH:mm:ss
  return '${raw.substring(6, 8)}/${raw.substring(4, 6)}/${raw.substring(0, 4)} '
      '${raw.substring(8, 10)}:${raw.substring(10, 12)}:${raw.substring(12, 14)}';
}
