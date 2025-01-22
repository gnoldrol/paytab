import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:pay_tab/core/error/exceptions.dart';
import 'package:pay_tab/core/network/api_constants.dart';
import 'package:pay_tab/features/currency/data/datasources/currency_remote_datasource.dart';
import 'package:pay_tab/core/error/custom_errors.dart';
import 'package:dartz/dartz.dart';

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
        expect(result.isRight(), true);
        result.fold(
          (error) => fail('Should not return error'),
          (symbols) => expect(symbols, {
            'USD': 'United States Dollar',
            'EGP': 'Egyptian Pound'
          }),
        );
        verify(mockDio.get(
          '${ApiConstants.baseUrl}/symbols',
          queryParameters: {'access_key': ApiConstants.accessKey},
        ));
      },
    );

    test(
      'should return ApiError when API returns error response',
      () async {
        // arrange
        final errorResponse = {
          'success': false,
          'error': {
            'code': 105,
            'type': 'base_currency_access_restricted'
          }
        };
        
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
          (_) async => Response(
            data: errorResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await dataSource.getSymbols();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<ApiError>());
            expect(error.message, 'Base Currency Access Restricted, Please Upgrade your subscription');
          },
          (symbols) => fail('Should not return symbols'),
        );
      },
    );

    test(
      'should return ConnectivityError when connection timeout occurs',
      () async {
        // arrange
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
          DioError(
            type: DioErrorType.connectionTimeout,
            error: 'Connection timeout',
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await dataSource.getSymbols();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<ConnectivityError>());
            expect(error.message, 'No internet connection');
          },
          (symbols) => fail('Should not return symbols'),
        );
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
        expect(result.isRight(), true);
        result.fold(
          (error) => fail('Should not return error'),
          (rate) => expect(rate, 30.90),
        );
        verify(mockDio.get(
          '${ApiConstants.baseUrl}/latest',
          queryParameters: {'access_key': ApiConstants.accessKey, 'base': 'USD', 'symbols': 'EGP'},
        ));
      },
    );

    test(
      'should return ApiError when base currency is restricted',
      () async {
        // arrange
        final errorResponse = {
          'success': false,
          'error': {
            'code': 105,
            'type': 'base_currency_access_restricted'
          }
        };
        
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
          (_) async => Response(
            data: errorResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await dataSource.getExchangeRate('USD', 'EGP');

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<ApiError>());
            expect(error.message, 'Base Currency Access Restricted, Please Upgrade your subscription');
          },
          (rate) => fail('Should not return rate'),
        );
      },
    );

    test(
      'should return ConnectivityError when there is no internet',
      () async {
        // arrange
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
          DioError(
            type: DioErrorType.connectionTimeout,
            error: 'Connection timeout',
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await dataSource.getExchangeRate('USD', 'EGP');

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<ConnectivityError>());
            expect(error.message, 'No internet connection');
          },
          (rate) => fail('Should not return rate'),
        );
      },
    );

    test(
      'should return UnexpectedError for other errors',
      () async {
        // arrange
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(Exception('Unknown error'));

        // act
        final result = await dataSource.getExchangeRate('USD', 'EGP');

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<UnexpectedError>());
            expect(error.message, 'Unexpected error occurred');
          },
          (rate) => fail('Should not return rate'),
        );
      },
    );
  });
} 