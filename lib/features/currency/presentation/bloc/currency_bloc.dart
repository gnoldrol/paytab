import '../../data/models/api_error.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/currency_repository.dart';
import 'currency_event.dart';
import 'currency_state.dart';

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
      (failure) {
        if (failure is ApiError) {
          emit(CurrencyError(failure.message));
        } else {
          emit(const CurrencyError('Failed to convert currency'));
        }
      },
      (convertedAmount) => emit(CurrencyLoaded(convertedAmount)),
    );
  }
} 