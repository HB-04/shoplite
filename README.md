# ShopLite

A modern e-commerce app built with Flutter showcasing clean architecture, offline support, and a beautiful UI.

## Features

- 🛍️ Browse products with pagination
- 🔍 Search and filter by categories
- ⭐ Add/remove favorites (persists across restarts)
- 🛒 Cart management with quantity updates
- 💳 Mock checkout flow
- 🌐 Offline support with cached data
- 🎨 Dynamic theme support (light/dark)
- 🔐 Secure authentication
- 📱 Responsive design

## Architecture

The app follows Clean Architecture principles with the following layers:

```
lib/
├── core/           # Core utilities, constants, and helpers
├── data/           # Data layer (repositories, data sources)
├── domain/         # Business logic and entities
└── presentation/   # UI layer (pages, widgets, providers)
```

## State Management

The app uses Provider for state management because:
- Simple and intuitive API
- Built-in dependency injection
- Efficient rebuilds
- Great documentation and community support

## Getting Started

### Prerequisites

- Flutter 3.x or higher
- Dart 3.x or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/shoplite.git
cd shoplite
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

```bash
flutter test
```

## Caching Strategy

- Products are cached using local storage
- Images use CachedNetworkImage for efficient loading
- Favorites and cart data persist across sessions
- Offline banner shows when working without internet

## Known Limitations

- Uses mock data for products (can be replaced with real API)
- Basic error handling for network issues
- Limited payment options in checkout
- No push notifications

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.