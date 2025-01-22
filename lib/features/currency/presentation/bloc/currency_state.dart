import 'package:equatable/equatable.dart';

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