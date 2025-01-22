import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/currency_bloc.dart';
import '../bloc/currency_event.dart';
import '../bloc/currency_state.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  String? _fromCurrency;
  String? _toCurrency;
  Map<String, String> _symbols = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSymbols();
  }

  Future<void> _loadSymbols() async {
    try {
      final result = await context.read<CurrencyBloc>().repository.getSymbols();
      print('Symbols Result: $result');
      result.fold(
        (failure) {
          print('Failed to load symbols: $failure');
          setState(() => _isLoading = false);
        },
        (symbols) {
          print('Loaded symbols: $symbols');
          setState(() {
            _symbols = symbols;
            _fromCurrency = symbols.keys.first;
            _toCurrency = symbols.keys.elementAt(1);
            _isLoading = false;
            _convertCurrency();
          });
        },
      );
    } catch (e) {
      print('Error loading symbols: $e');
      setState(() => _isLoading = false);
    }
  }

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
        fromCurrency: _fromCurrency!,
        toCurrency: _toCurrency!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                    items: _symbols.entries.map((e) => 
                      DropdownMenuItem(value: e.key, child: Text(e.key))
                    ).toList(),
                    onChanged: _fromCurrency == null ? null : (value) {
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
                    items: _symbols.entries.map((e) => 
                      DropdownMenuItem(value: e.key, child: Text(e.key))
                    ).toList(),
                    onChanged: _toCurrency == null ? null : (value) {
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