import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/currency/data/models/api_error.dart';

abstract class CurrencyRemoteDataSource {
  Future<Map<String, String>> getSymbols();
  Future<double> getExchangeRate(String from, String to);
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final Dio dio;

  CurrencyRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, String>> getSymbols() async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/symbols',
      queryParameters: {'access_key': ApiConstants.accessKey},
    );

    print('Symbols Response Status: ${response.statusCode}');
    print('Symbols Response Body: ${response.data}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = response.data;
      print('Parsed JSON: $jsonResponse');
      
      if (jsonResponse['success'] == true) {
        final Map<String, dynamic> symbols = jsonResponse['symbols'];
        return Map<String, String>.from(symbols);
      } else {
        print('API Error: ${jsonResponse['error']}');
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<double> getExchangeRate(String from, String to) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/latest',
      queryParameters: {
        'access_key': ApiConstants.accessKey,
        'base': from,
        'symbols': to,
      },
    );

    print('Exchange Rate Response: ${response.data}');
    final Map<String, dynamic> jsonResponse = response.data;
    
    if (jsonResponse['success'] == true) {
      final rate = jsonResponse['rates'][to].toDouble();
      return rate;
    } else {
      final error = ApiError.fromJson(jsonResponse['error']);
      print('API Error: ${error.message}'); // Debug print
      throw ServerException(error.message);
    }
  }
} 