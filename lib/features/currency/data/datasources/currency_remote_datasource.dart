import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/currency/data/models/api_error.dart';

abstract class CurrencyRemoteDataSource {
  Future<Map<String, String>> getSymbols();
  Future<double> getExchangeRate(String from, String to);
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final http.Client client;

  CurrencyRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, String>> getSymbols() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/symbols?access_key=${ApiConstants.accessKey}')
    );

    print('Symbols Response Status: ${response.statusCode}');
    print('Symbols Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
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
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/latest?access_key=${ApiConstants.accessKey}&base=$from&symbols=$to')
    );

    print('Exchange Rate Response Status: ${response.statusCode}');
    print('Exchange Rate Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('Parsed Exchange Rate JSON: $jsonResponse');
      
      if (jsonResponse['success'] == true) {
        final rate = jsonResponse['rates'][to].toDouble();
        print('Exchange Rate $from to $to: $rate');
        return rate;
      } else {
        final error = ApiError.fromJson(jsonResponse['error']);
        throw ServerException(error.message);
      }
    } else {
      throw ServerException('Server error occurred');
    }
  }
} 