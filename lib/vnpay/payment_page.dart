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
  // Dữ liệu đơn hàng demo
  static const _orderItems = [
    _OrderItem('Khóa học Flutter cơ bản', 299000),
    _OrderItem('Khóa học VNPAY Integration', 199000),
  ];

  static const _totalAmount =
      299000 + 199000; // = 498.000 VNĐ

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: const Color(0xFF003087),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ thông tin đơn hàng
            _SectionCard(
              title: 'Thông tin đơn hàng',
              child: Column(
                children: [
                  ..._orderItems.map(
                    (item) => _ItemRow(name: item.name, price: item.price),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatVnd(_totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF003087),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thẻ phương thức thanh toán
            _SectionCard(
              title: 'Phương thức thanh toán',
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003087),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'VN\nPAY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Thanh toán qua cổng VNPAY (Sandbox)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle,
                      color: Color(0xFF003087), size: 20),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nút thanh toán
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _paying ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003087),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _paying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text('Thanh toán ${_formatVnd(_totalAmount)}'),
              ),
            ),

            // Kết quả thanh toán
            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultCard(result: _result!),
            ],
          ],
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
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            _formatVnd(price),
            style: const TextStyle(fontSize: 14),
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
    final color = result.isSuccess ? Colors.green : Colors.red;
    final icon =
        result.isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(77)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _ResultRow('Mã giao dịch VNPAY', result.transactionNo ?? '-'),
            _ResultRow('Mã đơn hàng', result.txnRef ?? '-'),
            _ResultRow('Số tiền', result.displayAmount),
            _ResultRow('Ngân hàng', result.bankCode ?? '-'),
            _ResultRow('Thời gian', _formatPayDate(result.payDate)),
            _ResultRow(
              'ResponseCode',
              result.responseCode ?? '-',
            ),
            _ResultRow(
              'TransactionStatus',
              result.transactionStatus ?? '-',
            ),
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
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
  return '${amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )} VNĐ';
}

String _formatPayDate(String? raw) {
  if (raw == null || raw.length < 14) return raw ?? '-';
  // yyyyMMddHHmmss → dd/MM/yyyy HH:mm:ss
  return '${raw.substring(6, 8)}/${raw.substring(4, 6)}/${raw.substring(0, 4)} '
      '${raw.substring(8, 10)}:${raw.substring(10, 12)}:${raw.substring(12, 14)}';
}
