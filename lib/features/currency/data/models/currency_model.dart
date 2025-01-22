import '../../domain/entities/currency.dart';

class CurrencyModel extends Currency {
  const CurrencyModel({
    required String code,
    required double amount,
  }) : super(code: code, amount: amount);

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'],
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'amount': amount,
    };
  }
} 