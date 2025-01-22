import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/error/custom_errors.dart' as custom_errors;
import '../../../../core/error/custom_errors.dart' show BaseError;
import '../../../../features/currency/data/models/api_error.dart' as model_errors;

abstract class CurrencyRemoteDataSource {
  Future<Either<BaseError, Map<String, String>>> getSymbols();
  Future<Either<BaseError, double>> getExchangeRate(String from, String to);
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final Dio dio;

  CurrencyRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<BaseError, Map<String, String>>> getSymbols() async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/symbols',
        queryParameters: {'access_key': ApiConstants.accessKey},
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['success'] == true) {
          final symbols = jsonResponse['symbols'];
          return Right(Map<String, String>.from(symbols));
        } else {
          final error = model_errors.ApiError.fromJson(jsonResponse['error']);
          return Left(custom_errors.ApiError(error.message));
        }
      } else {
        return Left(custom_errors.ApiError('Failed to load symbols'));
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectionTimeout) {
        return Left(custom_errors.ConnectivityError('No internet connection'));
      }
      return Left(custom_errors.ApiError('Failed to load symbols'));
    } catch (e) {
      return Left(custom_errors.UnexpectedError('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<BaseError, double>> getExchangeRate(String from, String to) async {
    try {
      print('Fetching exchange rate from $from to $to');
      final response = await dio.get(
        '${ApiConstants.baseUrl}/latest',
        queryParameters: {
          'access_key': ApiConstants.accessKey,
          'base': from,
          'symbols': to,
        },
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['success'] == true) {
          final rate = jsonResponse['rates'][to].toDouble();
          print('Conversion rate: $rate');
          return Right(rate);
        } else {
          print('API Error: ${jsonResponse['error']}');
          final error = model_errors.ApiError.fromJson(jsonResponse['error']);
          print('Error message: ${error.message}');
          return Left(custom_errors.ApiError(error.message));
        }
      } else {
        print('Non-200 status code: ${response.statusCode}');
        return Left(custom_errors.ApiError('Failed to fetch exchange rate'));
      }
    } on DioError catch (e) {
      print('DioError: ${e.type} - ${e.message}');
      if (e.type == DioErrorType.connectionTimeout) {
        return Left(custom_errors.ConnectivityError('No internet connection'));
      }
      return Left(custom_errors.ApiError('Failed to fetch exchange rate'));
    } catch (e) {
      print('Unexpected error: $e');
      return Left(custom_errors.UnexpectedError('Unexpected error occurred'));
    }
  }
} 