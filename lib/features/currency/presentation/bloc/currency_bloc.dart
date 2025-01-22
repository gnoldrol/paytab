import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../../../core/error/custom_errors.dart';
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
        print('Failure type: ${failure.runtimeType}');
        if (failure is ConnectivityError) {
          emit(CurrencyError('Connection Error: No internet connection'));
        } else if (failure is ApiError) {
          emit(CurrencyError(failure.message));
        } else {
          emit(const CurrencyError('Unexpected error occurred'));
        }
      },
      (convertedAmount) => emit(CurrencyLoaded(convertedAmount)),
    );
  }
} 