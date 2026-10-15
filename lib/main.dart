
import 'package:flutter/material.dart';

void main() {
  runApp(const MoMoWalletApp());
}

class MoMoWalletApp extends StatelessWidget {
  const MoMoWalletApp({super.key});

  static const Color primaryColor = Color(0xFFFFCC08);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoMo Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7F6),
          foregroundColor: Color(0xFF172B24),
          elevation: 0,
        ),
      ),
      home: const WalletHomeScreen(),
    );
  }
}

class WalletHomeScreen extends StatelessWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoMo Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.account_balance_wallet),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 72,
              color: MoMoWalletApp.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Your money, under control.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Welcome to MoMo Wallet'),
          ],
        ),
      ),
    );
  }
}
