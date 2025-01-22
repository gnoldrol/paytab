import 'package:dartz/dartz.dart';
import '../../../../core/error/custom_errors.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_remote_datasource.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;

  CurrencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<BaseError, Map<String, String>>> getSymbols() async {
    final result = await remoteDataSource.getSymbols();
    return result;
  }

  @override
  Future<Either<BaseError, double>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    print('Repository: Converting $amount from $fromCurrency to $toCurrency');
    final result = await remoteDataSource.getExchangeRate(fromCurrency, toCurrency);
    return result.fold(
      (error) {
        print('Repository: Error type: ${error.runtimeType}');
        print('Repository: Error message: ${error.message}');
        return Left(error);  // Pass through the original error
      },
      (rate) => Right(amount * rate),
    );
  }
} 