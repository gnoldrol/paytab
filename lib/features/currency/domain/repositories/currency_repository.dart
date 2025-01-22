import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, Map<String, String>>> getSymbols();
  Future<Either<Failure, double>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  });
} 