// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExchangeHistoryModelAdapter extends TypeAdapter<ExchangeHistoryModel> {
  @override
  final int typeId = 0;

  @override
  ExchangeHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExchangeHistoryModel(
      fromAmount: fields[0] as double,
      fromCurrency: fields[1] as String,
      toCurrency: fields[2] as String,
      toAmount: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExchangeHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fromAmount)
      ..writeByte(1)
      ..write(obj.fromCurrency)
      ..writeByte(2)
      ..write(obj.toCurrency)
      ..writeByte(3)
      ..write(obj.toAmount)
      ..writeByte(4)
      ..write(obj.timestampMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
