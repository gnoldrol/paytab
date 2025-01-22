import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/currency_repository.dart';
import 'currency_event.dart';
import 'currency_state.dart';

// Events
abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class ConvertCurrency extends CurrencyEvent {
  final double amount;
  final String fromCurrency;
  final String toCurrency;

  const ConvertCurrency({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [amount, fromCurrency, toCurrency];
}

// States
abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {}
class CurrencyLoading extends CurrencyState {}
class CurrencyLoaded extends CurrencyState {
  final double result;
  const CurrencyLoaded(this.result);

  @override
  List<Object?> get props => [result];
}
class CurrencyError extends CurrencyState {
  final String message;
  const CurrencyError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository repository;

  CurrencyBloc({required this.repository}) : super(CurrencyInitial()) {
    on<ConvertCurrency>(_onConvertCurrency);
  }

  Future<void> _onConvertCurrency(
    ConvertCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(CurrencyLoading());
    
    final result = await repository.convertCurrency(
      amount: event.amount,
      fromCurrency: event.fromCurrency,
      toCurrency: event.toCurrency,
    );

    result.fold(
      (failure) => emit(const CurrencyError('Failed to convert currency')),
      (convertedAmount) => emit(CurrencyLoaded(convertedAmount)),
    );
  }
} 