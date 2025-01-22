import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/exchange_history_model.dart';
import 'package:intl/intl.dart';

class ExchangeHistoryScreen extends StatefulWidget {
  const ExchangeHistoryScreen({super.key});

  @override
  State<ExchangeHistoryScreen> createState() => _ExchangeHistoryScreenState();
}

class _ExchangeHistoryScreenState extends State<ExchangeHistoryScreen> {
  Box<ExchangeHistoryModel>? _box;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    try {
      _box = await Hive.openBox<ExchangeHistoryModel>('exchange_history');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error opening Hive box: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';
    try {
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Unknown Time';
    try {
      return DateFormat('HH:mm:ss').format(date);
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return 'Invalid Time';
    }
  }

  Map<String, List<ExchangeHistoryModel>> _groupByDate(List<ExchangeHistoryModel> history) {
    final grouped = <String, List<ExchangeHistoryModel>>{};
    for (var entry in history) {
      try {
        final date = _formatDate(entry.timestamp);
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(entry);
      } catch (e) {
        debugPrint('Error grouping entry: $e');
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_box == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error loading exchange history'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _box!.listenable(),
        builder: (context, Box<ExchangeHistoryModel> box, _) {
          try {
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  'No exchange history yet',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final allEntries = box.values.toList();
            debugPrint('Total entries: ${allEntries.length}');
            
            // Debug print each entry
            for (var i = 0; i < allEntries.length; i++) {
              final entry = allEntries[i];
              debugPrint('Entry $i: timestamp=${entry.timestamp}, '
                  'fromAmount=${entry.fromAmount}, '
                  'fromCurrency=${entry.fromCurrency}, '
                  'toCurrency=${entry.toCurrency}, '
                  'toAmount=${entry.toAmount}');
            }

            if (allEntries.isEmpty) {
              return const Center(
                child: Text(
                  'No exchange history entries',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            try {
              allEntries.sort((a, b) {
                final aTime = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
                final bTime = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bTime.compareTo(aTime);
              });
            } catch (e) {
              debugPrint('Error sorting entries: $e');
            }

            final groupedHistory = _groupByDate(allEntries);

            if (groupedHistory.isEmpty) {
              return const Center(
                child: Text(
                  'Could not process exchange history',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedHistory.length,
              itemBuilder: (context, index) {
                final date = groupedHistory.keys.elementAt(index);
                final entries = groupedHistory[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(date),
                    ...entries.map((entry) => _buildHistoryItem(
                      time: _formatTime(entry.timestamp),
                      fromAmount: entry.fromAmount,
                      fromCurrency: entry.fromCurrency,
                      toCurrency: entry.toCurrency,
                      toAmount: entry.toAmount,
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          } catch (e, stackTrace) {
            debugPrint('Error in build: $e');
            debugPrint('Stack trace: $stackTrace');
            return Center(
              child: Text(
                'Error loading history: $e',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }
        },
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