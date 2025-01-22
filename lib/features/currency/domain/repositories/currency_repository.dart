import 'package:dartz/dartz.dart';
import '../../../../core/error/custom_errors.dart';

abstract class CurrencyRepository {
  Future<Either<BaseError, Map<String, String>>> getSymbols();
  Future<Either<BaseError, double>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  });
} 