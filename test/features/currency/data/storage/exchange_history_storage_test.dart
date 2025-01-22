import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pay_tab/features/currency/data/models/exchange_history_model.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => './test/tmp';
  
  @override
  Future<String?> getApplicationCachePath() async => './test/tmp/cache';
  
  @override
  Future<String?> getApplicationSupportPath() async => './test/tmp/support';
  
  @override
  Future<String?> getDownloadsPath() async => './test/tmp/downloads';
  
  @override
  Future<List<String>?> getExternalCachePaths() async => ['./test/tmp/external/cache'];
  
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => 
    ['./test/tmp/external/storage'];
  
  @override
  Future<String?> getExternalStoragePath() async => './test/tmp/external';
  
  @override
  Future<String?> getLibraryPath() async => './test/tmp/library';
  
  @override
  Future<String?> getTemporaryPath() async => './test/tmp/temp';
}

void main() {
  late Box<ExchangeHistoryModel> box;

  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProvider();
    await Hive.initFlutter('./test/tmp');
    if (!Hive.isAdapterRegistered(ExchangeHistoryModelAdapter().typeId)) {
      Hive.registerAdapter(ExchangeHistoryModelAdapter());
    }
  });

  setUp(() async {
    box = await Hive.openBox<ExchangeHistoryModel>('exchange_history_test');
  });

  tearDown(() async {
    if (box.isOpen) {
      await box.clear();
      await box.close();
    }
    await Hive.deleteBoxFromDisk('exchange_history_test');
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('Exchange History Storage', () {
    test('should save exchange history entry', () async {
      // arrange
      final historyEntry = ExchangeHistoryModel(
        fromAmount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        toAmount: 92.5,
        timestamp: DateTime(2024, 3, 20, 10, 30),
      );

      // act
      await box.add(historyEntry);

      // assert
      final savedEntry = box.values.first;
      expect(savedEntry.fromAmount, 100);
      expect(savedEntry.fromCurrency, 'USD');
      expect(savedEntry.toCurrency, 'EUR');
      expect(savedEntry.toAmount, 92.5);
      expect(savedEntry.timestamp, DateTime(2024, 3, 20, 10, 30));
    });

    test('should retrieve multiple entries in chronological order', () async {
      // arrange
      final entries = [
        ExchangeHistoryModel(
          fromAmount: 100,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          toAmount: 92.5,
          timestamp: DateTime(2024, 3, 20, 10, 30),
        ),
        ExchangeHistoryModel(
          fromAmount: 50,
          fromCurrency: 'EUR',
          toCurrency: 'GBP',
          toAmount: 42.8,
          timestamp: DateTime(2024, 3, 20, 10, 35),
        ),
        ExchangeHistoryModel(
          fromAmount: 200,
          fromCurrency: 'GBP',
          toCurrency: 'USD',
          toAmount: 254.6,
          timestamp: DateTime(2024, 3, 20, 10, 40),
        ),
      ];

      // act
      for (var entry in entries) {
        await box.add(entry);
      }

      // assert
      final savedEntries = box.values.toList();
      expect(savedEntries.length, 3);
      
      // Check first entry
      expect(savedEntries[0].fromAmount, 100);
      expect(savedEntries[0].fromCurrency, 'USD');
      expect(savedEntries[0].toCurrency, 'EUR');
      expect(savedEntries[0].toAmount, 92.5);
      expect(savedEntries[0].timestamp, DateTime(2024, 3, 20, 10, 30));

      // Check last entry
      expect(savedEntries[2].fromAmount, 200);
      expect(savedEntries[2].fromCurrency, 'GBP');
      expect(savedEntries[2].toCurrency, 'USD');
      expect(savedEntries[2].toAmount, 254.6);
      expect(savedEntries[2].timestamp, DateTime(2024, 3, 20, 10, 40));
    });

    test('should handle empty box', () async {
      // act & assert
      expect(box.values.isEmpty, true);
      expect(box.length, 0);
    });

    test('should clear all entries', () async {
      // arrange
      final entry = ExchangeHistoryModel(
        fromAmount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        toAmount: 92.5,
        timestamp: DateTime(2024, 3, 20, 10, 30),
      );
      await box.add(entry);
      expect(box.length, 1);

      // act
      await box.clear();

      // assert
      expect(box.values.isEmpty, true);
      expect(box.length, 0);
    });

    test('should handle large number of entries', () async {
      // arrange
      final now = DateTime.now();
      final entries = List.generate(100, (index) => 
        ExchangeHistoryModel(
          fromAmount: 100.0 + index,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          toAmount: 92.5 + index,
          timestamp: now.add(Duration(minutes: index)),
        )
      );

      // act
      for (var entry in entries) {
        await box.add(entry);
      }

      // assert
      expect(box.length, 100);
      final firstEntry = box.values.first;
      final lastEntry = box.values.last;
      expect(firstEntry.fromAmount, 100.0);
      expect(lastEntry.fromAmount, 199.0);
      expect(lastEntry.timestamp.difference(firstEntry.timestamp).inMinutes, 99);
    });
  });
} 