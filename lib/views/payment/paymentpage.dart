import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment success
    print("Payment Success: ${response.paymentId}");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful! ID: ${response.paymentId}"))
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment failed
    print("Payment Failed: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: ${response.message}"))
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selected
    print("External Wallet: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External Wallet: ${response.walletName}"))
    );
  }

  void openCheckout() {
    var options = {
      'key': 'YOUR_KEY_ID', // Test key from Razorpay dashboard
      'amount': 50000, // Amount in paise = ₹500
      'name': 'Flutter Shop',
      'description': 'Test Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Razorpay Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: openCheckout,
          child: Text("Pay ₹500"),
        ),
      ),
    );
  }
}
