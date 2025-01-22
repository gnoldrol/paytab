import 'package:flutter/material.dart';

class ExchangeHistoryScreen extends StatelessWidget {
  const ExchangeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateHeader('2025-01-13'),
          _buildHistoryItem(
            time: '16:27:01',
            fromAmount: 1.00,
            fromCurrency: 'EGP',
            toCurrency: 'USD',
            toAmount: 0.02,
          ),
          _buildHistoryItem(
            time: '16:24:56',
            fromAmount: 50.51,
            fromCurrency: 'EGP',
            toCurrency: 'USD',
            toAmount: 1.00,
          ),
          _buildHistoryItem(
            time: '16:24:42',
            fromAmount: 1.00,
            fromCurrency: 'USD',
            toCurrency: 'EGP',
            toAmount: 50.51,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String time,
    required double fromAmount,
    required String fromCurrency,
    required String toCurrency,
    required double toAmount,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: $time'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  fromAmount.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  fromCurrency,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
                const SizedBox(width: 8),
                Text(
                  toCurrency,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  toAmount.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 