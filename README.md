# PayTab Currency Converter

A modern Flutter application for currency conversion with a clean architecture approach and robust state management.

## Features

- Real-time currency conversion
- Exchange rate history tracking
- Clean and intuitive user interface
- Offline support with local storage
- Error handling with user-friendly messages

## Architecture

The application is built using Clean Architecture principles with the following layers:
- **Presentation**: UI components and BLoC state management
- **Domain**: Business logic and use cases
- **Data**: Data sources and repositories

## Tech Stack

- **Flutter SDK**: ^3.6.1
- **State Management**: flutter_bloc ^8.1.3
- **API Client**: dio ^5.0.0
- **Local Storage**: hive ^2.2.3
- **Functional Programming**: dartz ^0.10.1
- **Date Formatting**: intl ^0.19.0
- **Testing**: mockito ^5.4.4

## Getting Started

### Prerequisites
- Flutter SDK (^3.6.1)
- Dart SDK (^3.6.1)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:
```bash
git clone [[repository-url]](https://github.com/gnoldrol/paytab.git)
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running Tests

Execute the test suite with:
```bash
flutter test
```

## Project Structure

```
lib/
├── core/
│   ├── error/
│   └── network/
├── features/
│   └── currency/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```


## License

This project is licensed under the MIT License - see the LICENSE file for details.
