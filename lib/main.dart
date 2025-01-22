import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/currency/presentation/bloc/currency_bloc.dart';
import 'features/currency/data/repositories/currency_repository_impl.dart';
import 'features/currency/data/datasources/currency_remote_datasource.dart';
import 'features/currency/presentation/pages/currency_converter_screen.dart';
import 'features/currency/data/models/exchange_history_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Close any open boxes
  await Hive.close();
  
  // Delete all boxes
  await Hive.deleteFromDisk();
  
  // Register the adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ExchangeHistoryModelAdapter());
  }
  
  // Open the box
  await Hive.openBox<ExchangeHistoryModel>('exchange_history');
  
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
              dio: Dio(),
            ),
          ),
        ),
        child: const CurrencyConverterScreen(),
      ),
    );
  }
}
