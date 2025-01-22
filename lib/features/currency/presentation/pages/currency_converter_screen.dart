import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/currency_bloc.dart';
import '../bloc/currency_event.dart';
import '../bloc/currency_state.dart';
import 'dart:async';

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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _loadSymbols() async {
    try {
      final result = await context.read<CurrencyBloc>().repository.getSymbols();
      result.fold(
        (failure) {
          _showError('Failed to load currencies');
          setState(() => _isLoading = false);
        },
        (symbols) {
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
      _showError('Network error occurred');
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

  Widget _buildResultField() {
    return BlocConsumer<CurrencyBloc, CurrencyState>(
      listener: (context, state) {
        if (state is CurrencyError) {
          _showError(state.message);
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
            const Center(
              child: CircleAvatar(
                radius: 25,
                child: Icon(Icons.currency_exchange, size: 30),
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