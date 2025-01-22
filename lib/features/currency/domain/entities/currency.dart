import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code;
  final double amount;

  const Currency({
    required this.code,
    required this.amount,
  });

  @override
  List<Object?> get props => [code, amount];
} 