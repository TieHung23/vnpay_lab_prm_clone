import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'vnpay_config.dart';

/// Mở cổng thanh toán VNPAY trong WebView.
/// Khi VNPAY redirect về [VNPayConfig.returnUrl], màn hình tự đóng
/// và trả về URL đầy đủ (có chứa kết quả) cho caller.
class VNPayWebViewPage extends StatefulWidget {
  final String paymentUrl;

  const VNPayWebViewPage({super.key, required this.paymentUrl});

  @override
  State<VNPayWebViewPage> createState() => _VNPayWebViewPageState();
}

class _VNPayWebViewPageState extends State<VNPayWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            // Chặn khi VNPAY redirect về returnUrl của merchant
            if (req.url.startsWith(VNPayConfig.returnUrl)) {
              Navigator.of(context).pop(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (err) {
            // Bỏ qua lỗi do custom scheme myapp:// không load được
            if (err.url?.startsWith(VNPayConfig.returnUrl) == true) return;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPAY'),
        backgroundColor: const Color(0xFF003087),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
          tooltip: 'Hủy thanh toán',
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF003087)),
              ),
            ),
        ],
      ),
    );
  }
}
