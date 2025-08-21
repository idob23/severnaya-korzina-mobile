// lib/screens/payment/payment_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_success_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentId;

  const PaymentWebViewScreen({
    Key? key,
    required this.paymentUrl,
    required this.paymentId,
  }) : super(key: key);

  @override
  _PaymentWebViewScreenState createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
            _checkUrlForCompletion(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrlForCompletion(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrlForCompletion(String url) {
    // Проверяем различные варианты успешного завершения оплаты
    if (_isPaymentSuccessUrl(url)) {
      _handlePaymentSuccess();
    } else if (_isPaymentErrorUrl(url)) {
      _handlePaymentError();
    }
  }

  bool _isPaymentSuccessUrl(String url) {
    return url.contains('payment-success') ||
        url.contains('status=success') ||
        url.contains('sevkorzina.ru') && url.contains('success');
  }

  bool _isPaymentErrorUrl(String url) {
    return url.contains('payment-error') ||
        url.contains('status=error') ||
        url.contains('status=cancelled');
  }

  void _handlePaymentSuccess() {
    if (!mounted) return;

    // Переходим к экрану успеха
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(),
      ),
    );
  }

  void _handlePaymentError() {
    if (!mounted) return;

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Ошибка оплаты'),
          ],
        ),
        content: Text('Платеж был отменен или произошла ошибка.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Оплата заказа'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            _showExitConfirmation();
          },
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Загрузка платежной формы...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Отменить оплату?'),
        content: Text(
          'Вы уверены, что хотите отменить процесс оплаты?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Продолжить оплату'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
              Navigator.pop(context); // Закрыть WebView
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Отменить'),
          ),
        ],
      ),
    );
  }
}
