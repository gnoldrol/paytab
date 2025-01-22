import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:pay_tab/core/error/exceptions.dart';
import 'package:pay_tab/core/network/api_constants.dart';
import 'package:pay_tab/features/currency/data/datasources/currency_remote_datasource.dart';

import 'currency_remote_datasource_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late CurrencyRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = CurrencyRemoteDataSourceImpl(dio: mockDio);
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
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
          (_) async => Response(
            data: tSymbolsResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await dataSource.getSymbols();

        // assert
        expect(result, {
          'USD': 'United States Dollar',
          'EGP': 'Egyptian Pound'
        });
        verify(mockDio.get(
          '${ApiConstants.baseUrl}/symbols',
          queryParameters: {'access_key': ApiConstants.accessKey},
        ));
      },
    );

    test(
      'should throw ServerException when the response is unsuccessful',
      () async {
        // arrange
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
          (_) async => Response(
            data: 'Something went wrong',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
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
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
          (_) async => Response(
            data: tExchangeResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await dataSource.getExchangeRate('USD', 'EGP');

        // assert
        expect(result, 30.90);
        verify(mockDio.get(
          '${ApiConstants.baseUrl}/latest',
          queryParameters: {'access_key': ApiConstants.accessKey, 'base': 'USD', 'symbols': 'EGP'},
        ));
      },
    );

    test(
      'should throw ServerException when the response is unsuccessful',
      () async {
        // arrange
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
          (_) async => Response(
            data: {'success': false, 'error': {'code': 105, 'type': 'base_currency_access_restricted'}},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final call = dataSource.getExchangeRate;

        // assert
        expect(() => call('USD', 'EGP'), throwsA(isA<ServerException>()));
      },
    );
  });
} 