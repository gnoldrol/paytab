import 'package:hive/hive.dart';

part 'exchange_history_model.g.dart';

@HiveType(typeId: 0)
class ExchangeHistoryModel extends HiveObject {
  @HiveField(0)
  final double fromAmount;

  @HiveField(1)
  final String fromCurrency;

  @HiveField(2)
  final String toCurrency;

  @HiveField(3)
  final double toAmount;

  @HiveField(4)
  final int timestampMillis;

  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(timestampMillis);

  ExchangeHistoryModel({
    required this.fromAmount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.toAmount,
    DateTime? timestamp,
  }) : timestampMillis = timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;

  @override
  String toString() {
    return 'ExchangeHistoryModel(timestamp: $timestamp, fromAmount: $fromAmount, fromCurrency: $fromCurrency, toCurrency: $toCurrency, toAmount: $toAmount)';
  }
} 