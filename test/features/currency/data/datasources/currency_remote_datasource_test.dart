import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:pay_tab/core/error/exceptions.dart';
import 'package:pay_tab/core/network/api_constants.dart';
import 'package:pay_tab/features/currency/data/datasources/currency_remote_datasource.dart';

import 'currency_remote_datasource_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late CurrencyRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = CurrencyRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getSymbols', () {
    final tSymbolsResponse = {
      'success': true,
      'symbols': {
        'USD': 'United States Dollar',
        'EGP': 'Egyptian Pound'
      }
    };

    test(
      'should return currency symbols when the response is successful',
      () async {
        // arrange
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(tSymbolsResponse), 200),
        );

        // act
        final result = await dataSource.getSymbols();

        // assert
        expect(result, {
          'USD': 'United States Dollar',
          'EGP': 'Egyptian Pound'
        });
        verify(mockHttpClient.get(
          Uri.parse('${ApiConstants.baseUrl}/symbols?access_key=${ApiConstants.accessKey}'),
        ));
      },
    );

    test(
      'should throw ServerException when the response is unsuccessful',
      () async {
        // arrange
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('Something went wrong', 404),
        );

        // act
        final call = dataSource.getSymbols;

        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getExchangeRate', () {
    final tExchangeResponse = {
      'success': true,
      'rates': {
        'EGP': 30.90
      }
    };

    test(
      'should return exchange rate when the response is successful',
      () async {
        // arrange
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(tExchangeResponse), 200),
        );

        // act
        final result = await dataSource.getExchangeRate('USD', 'EGP');

        // assert
        expect(result, 30.90);
        verify(mockHttpClient.get(
          Uri.parse('${ApiConstants.baseUrl}/latest?access_key=${ApiConstants.accessKey}&base=USD&symbols=EGP'),
        ));
      },
    );

    test(
      'should throw ServerException when the response is unsuccessful',
      () async {
        // arrange
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('Something went wrong', 404),
        );

        // act
        final call = dataSource.getExchangeRate;

        // assert
        expect(() => call('USD', 'EGP'), throwsA(isA<ServerException>()));
      },
    );
  });
} 