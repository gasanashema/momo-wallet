
import 'package:flutter/material.dart';

import 'models/wallet_transaction.dart';
import 'states/wallet_state.dart';

void main() {
  runApp(
    WalletScope(
      notifier: WalletState(),
      child: const MoMoWalletApp(),
    ),
  );
}

class WalletScope extends InheritedNotifier<WalletState> {
  const WalletScope({
    super.key,
    required WalletState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static WalletState of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<WalletScope>();

    assert(scope != null, 'WalletScope not found in widget tree.');

    return scope!.notifier!;
  }
}

class MoMoWalletApp extends StatelessWidget {
  const MoMoWalletApp({super.key});

  static const Color primaryColor = Color(0xFF087F5B);

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

enum WalletFilter { all, incoming, outgoing }

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  WalletFilter _filter = WalletFilter.all;

  @override
  Widget build(BuildContext context) {
    final wallet = WalletScope.of(context);

    final transactions = wallet.transactions.reversed.where((t) {
      switch (_filter) {
      case WalletFilter.all:
      return true;
      case WalletFilter.incoming:
      return t.type == TransactionType.incoming;
      case WalletFilter.outgoing:
      return t.type == TransactionType.outgoing;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(
            Icons.account_balance_wallet,
            color: MoMoWalletApp.primaryColor,
          ),
        ),
        title: const Text(
          'MoMo Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh wallet',
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildBalanceCard(wallet),
          const SizedBox(height: 24),
          _buildStatistics(wallet),
          const SizedBox(height: 28),
          const Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAction(
                  icon: Icons.send_rounded,
                  label: 'Send money',
                  color: const Color(0xFF087F5B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SendMoneyScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAction(
                  icon: Icons.payments_rounded,
                  label: 'Cash out',
                  color: const Color(0xFFB45309),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CashOutScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text('${transactions.length} records'),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilters(),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            _buildEmptyState()
          else
            ...transactions.map(_buildTransactionTile),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(WalletState wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MoMoWalletApp.primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'AVAILABLE BALANCE',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_formatMoney(wallet.balance)} RWF',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your money, under control.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(WalletState wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wallet statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total IN',
                wallet.totalIn,
                Icons.arrow_downward,
                const Color(0xFF15803D),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'Total OUT',
                wallet.totalOut,
                Icons.arrow_upward,
                const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildStatCard(
          'Lowest balance reached',
          wallet.lowestBalance,
          Icons.trending_down,
          const Color(0xFFB45309),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label,
      int amount,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            _formatMoney(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      children: [
        _filterChip('All', WalletFilter.all),
        _filterChip('IN', WalletFilter.incoming),
        _filterChip('OUT', WalletFilter.outgoing),
      ],
    );
  }

  Widget _filterChip(String label, WalletFilter filter) {
    final selected = _filter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }

  Widget _buildTransactionTile(WalletTransaction transaction) {
    final incoming = transaction.type == TransactionType.incoming;
    final color = incoming ? const Color(0xFF15803D) : const Color(0xFFDC2626);

    return Card(
    color: Colors.white,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
    leading: CircleAvatar(
    backgroundColor: color.withValues(alpha: 0.1),
    child: Icon(
    incoming ? Icons.arrow_downward : Icons.arrow_upward,
    color: color,
    ),
    ),
    title: Text(
    transaction.description,
    style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(_formatDate(transaction.createdAt)),
    trailing: Text(
    '${incoming ? '+' : '-'}${_formatMoney(transaction.amount)}',
    style: TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.black38),
          SizedBox(height: 12),
          Text(
            'No transactions found',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Try another filter or make a transaction.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);

    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

// Temporary navigation placeholders.
// We will implement these screens in Phases 4 and 5.
class SendMoneyScreen extends StatelessWidget {
  const SendMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: const Center(child: Text('Send Money — Phase 4')),
    );
  }
}

class CashOutScreen extends StatelessWidget {
  const CashOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash out')),
      body: const Center(child: Text('Cash Out — Phase 5')),
    );
  }
}
