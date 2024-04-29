// ignore_for_file: avoid_print, empty_catches

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  Stripe.publishableKey = '';
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Map<String, dynamic>? paymentIntent;

  void makePayment() async {
    try {
      paymentIntent = await createPaymentIntent();

      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "US", currencyCode: "US", testEnv: true);

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!['client_secret'],
        style: ThemeMode.dark,
        merchantDisplayName: 'Mirza Asjad Basharat',
        googlePay: gpay,
      ));

      showPaymentSheet();
    } catch (e) {}
  }

  void showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Done');
    } catch (e) {
      print('Failed');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent() async {
    try {
      String apiKey = '';
      Map<String, dynamic> body = {
        'amount': '1000',
        'currency': 'USD',
      };
      http.Response response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        // Payment Intent created successfully
        return json.decode(response.body);
      } else {
        // Payment Intent creation failed
        print('Failed to create Payment Intent: ${response.statusCode}');
        return Future.error(
            'Failed to create Payment Intent: ${response.statusCode}');
      }
    } catch (e) {
      // Error occurred during the request
      print('Error creating Payment Intent: $e');
      return Future.error('Error creating Payment Intent: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                makePayment();
              },
              child: const Text('Make Payment')),
        ),
      ),
    );
  }
}
