import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final Map<String, double> _rates = {
    'USD_EGP': 30.90,
    'EGP_USD': 0.032,
  };

  @override
  Future<Either<Failure, double>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final String rateKey = '${fromCurrency}_${toCurrency}';
      final double? rate = _rates[rateKey];
      
      if (rate == null) {
        return Left(CacheFailure());
      }

      final result = amount * rate;
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
} 