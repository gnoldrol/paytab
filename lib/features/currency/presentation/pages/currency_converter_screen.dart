import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../bloc/currency_bloc.dart';
import '../bloc/currency_event.dart';
import '../bloc/currency_state.dart';
import '../../data/models/exchange_history_model.dart';
import '../../../../core/error/custom_errors.dart';
import 'dart:async';
import 'exchange_history_screen.dart';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSymbols();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSymbols() async {
    try {
      final result = await context.read<CurrencyBloc>().repository.getSymbols();
      result.fold(
        (failure) {
          String title = 'Error';
          if (failure is ConnectivityError) {
            title = 'Connection Error';
          } else if (failure is ApiError) {
            title = 'API Error';
          } else {
            title = 'Unexpected Error';
          }
          _showErrorDialog(title, failure.message);
          setState(() => _isLoading = false);
        },
        (symbols) {
          setState(() {
            _symbols = symbols;
            _fromCurrency = symbols.containsKey('EUR') ? 'EUR' : symbols.keys.first;
            _toCurrency = symbols.keys.firstWhere((key) => key != _fromCurrency, orElse: () => symbols.keys.elementAt(1));
            _isLoading = false;
            _convertCurrency();
          });
        },
      );
    } catch (e) {
      _showErrorDialog('Network Error', 'Failed to connect to the server');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _convertCurrency() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_amountController.text.isEmpty || _fromCurrency == null || _toCurrency == null) return;
      
      final amount = double.tryParse(_amountController.text);
      if (amount == null) return;

      context.read<CurrencyBloc>().add(
        ConvertCurrency(
          amount: amount,
          fromCurrency: _fromCurrency!,
          toCurrency: _toCurrency!,
        ),
      );
    });
  }

  void _switchCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convertCurrency();
  }

  Widget _buildResultField() {
    return BlocConsumer<CurrencyBloc, CurrencyState>(
      listener: (context, state) async {
        if (state is CurrencyError) {
          String title;
          String message = state.message;
          
          if (message.startsWith('Connection Error')) {
            title = 'Connection Error';
            message = message.replaceFirst('Connection Error: ', '');
          } else if (message.startsWith('Unexpected error')) {
            title = 'Error';
          } else {
            title = 'API Error';
          }
          
          _showErrorDialog(title, message);
        } else if (state is CurrencyLoaded) {
          Box<ExchangeHistoryModel>? box;
          try {
            box = await Hive.openBox<ExchangeHistoryModel>('exchange_history');
            final amount = double.tryParse(_amountController.text);
            if (amount == null) {
              debugPrint('Error: Invalid amount ${_amountController.text}');
              return;
            }
            
            final historyEntry = ExchangeHistoryModel(
              fromAmount: amount,
              fromCurrency: _fromCurrency!,
              toCurrency: _toCurrency!,
              toAmount: state.result,
              timestamp: DateTime.now(),
            );
            
            debugPrint('Saving entry: timestamp=${historyEntry.timestamp}, '
                'fromAmount=${historyEntry.fromAmount}, '
                'fromCurrency=${historyEntry.fromCurrency}, '
                'toCurrency=${historyEntry.toCurrency}, '
                'toAmount=${historyEntry.toAmount}');
                
            await box.add(historyEntry);
            debugPrint('Successfully saved entry to Hive');
          } catch (e, stackTrace) {
            debugPrint('Error saving to Hive: $e');
            debugPrint('Stack trace: $stackTrace');
            _showErrorDialog('Storage Error', 'Failed to save conversion history');
          } finally {
            await box?.close();
          }
        }
      },
      builder: (context, state) {
        String displayText = '';
        String labelText = 'Amount';

        if (state is CurrencyLoading) {
          labelText = 'Converting...';
        } else if (state is CurrencyLoaded) {
          displayText = '${state.result.toStringAsFixed(2)} $_toCurrency';
        }

        return InputDecorator(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: labelText,
          ),
          child: Text(
            displayText,
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExchangeHistoryScreen(),
                ),
              );
            },
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
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: _symbols.entries.map((e) => 
                      DropdownMenuItem(value: e.key, child: Text(e.key))
                    ).toList(),
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
                    onChanged: (_) => _convertCurrency(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: IconButton(
                onPressed: _switchCurrencies,
                icon: const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.currency_exchange, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: _symbols.entries.map((e) => 
                      DropdownMenuItem(value: e.key, child: Text(e.key))
                    ).toList(),
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
                  child: _buildResultField(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 