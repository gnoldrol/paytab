import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'features/currency/presentation/bloc/currency_bloc.dart';
import 'features/currency/data/repositories/currency_repository_impl.dart';
import 'features/currency/data/datasources/currency_remote_datasource.dart';
import 'features/currency/presentation/pages/currency_converter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => CurrencyBloc(
          repository: CurrencyRepositoryImpl(
            remoteDataSource: CurrencyRemoteDataSourceImpl(
              client: http.Client(),
            ),
          ),
        ),
        child: const CurrencyConverterScreen(),
      ),
    );
  }
}
