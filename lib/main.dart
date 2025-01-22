import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/currency/presentation/bloc/currency_bloc.dart';
import 'features/currency/data/repositories/currency_repository_impl.dart';

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
          repository: CurrencyRepositoryImpl(),
        ),
        child: const CurrencyConverterScreen(),
      ),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EGP';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convertCurrency() {
    if (_amountController.text.isEmpty) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    context.read<CurrencyBloc>().add(
      ConvertCurrency(
        amount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _convertCurrency,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Amount', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fromCurrency = value);
                        _convertCurrency();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '1.0',
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _convertCurrency(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Center(
              child: CircleAvatar(
                radius: 25,
                child: Icon(Icons.currency_exchange, size: 30),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Converted Amount', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _toCurrency = value);
                        _convertCurrency();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: BlocBuilder<CurrencyBloc, CurrencyState>(
                    builder: (context, state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: state is CurrencyLoading 
                              ? 'Converting...'
                              : 'Amount',
                        ),
                        child: Text(
                          state is CurrencyLoaded
                              ? state.result.toStringAsFixed(2)
                              : state is CurrencyError
                                  ? state.message
                                  : '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('CALCULATE'),
            ),
          ],
        ),
      ),
    );
  }
}
