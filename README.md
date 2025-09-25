# ShopLite 🛍️

A modern, lightweight shopping app built with Flutter, featuring a clean layered architecture, offline support, and comprehensive state management.

## 📱 Features

### ✅ Implemented
- **Layered Architecture**: Clean separation of concerns with data, domain, presentation, and core layers
- **Theme Management**: Light/Dark theme toggle with system theme support
- **Basic UI Foundation**: Catalog page with product grid and search functionality
- **Testing**: Widget tests with CI/CD integration
- **CI/CD Pipeline**: GitHub Actions for automated testing and building

### 🚧 In Progress
- Authentication with mock login and secure token storage
- Product catalog with pagination, search, filters, and pull-to-refresh
- Product detail page with image carousel, ratings, and favorites
- Shopping cart and checkout functionality
- Offline support with caching and TTL strategy

### 📋 Planned
- Hero animations between screens
- Push notifications
- Order history
- User profile management

## 🏗️ Architecture

ShopLite follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities and constants
│   ├── constants/          # App constants, API endpoints, strings
│   ├── helpers/            # Utilities, exceptions, result wrappers
│   └── network/            # Network configuration and interceptors
├── data/                   # Data layer
│   ├── datasources/        # API clients and local data sources
│   ├── models/             # Data models with JSON serialization
│   └── repositories/       # Repository implementations
├── domain/                 # Business logic layer
│   ├── entities/           # Core business entities
│   └── usecases/           # Business use cases and rules
└── presentation/           # UI layer
    ├── bloc/               # State management (BLoC pattern)
    ├── pages/              # Screen widgets
    ├── widgets/            # Reusable UI components
    └── theme/              # App theming and styling
```

### State Management
- **Pattern**: BLoC (Business Logic Component)
- **Library**: flutter_bloc ^8.1.3
- **Rationale**: Provides predictable state management with clear separation of business logic from UI, excellent for testing and scalability

### Data Flow
1. **UI Events** → BLoC Events
2. **BLoC** → Use Cases (Domain Layer)
3. **Use Cases** → Repositories (Data Layer)
4. **Repositories** → Data Sources (API/Cache)
5. **Data Sources** → Models → Entities → BLoC States → **UI Updates**

## 🔧 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.3        # State management
  equatable: ^2.0.5           # Value equality
  dio: ^4.0.6                 # HTTP client
  hive: ^2.2.3               # Local database
  hive_flutter: ^1.1.0       # Flutter integration
  flutter_secure_storage: ^6.1.0  # Secure token storage
  cached_network_image: ^3.2.3    # Image caching
  path_provider: ^2.0.15     # File system paths
  json_annotation: ^4.7.0    # JSON serialization

dev_dependencies:
  json_serializable: ^6.5.4  # Code generation
  build_runner: ^2.3.3       # Build system
  hive_generator: ^1.1.3     # Hive adapters
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.13.0 or later
- Dart SDK 2.19.6 or later
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd shoplite
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (when adding dependencies)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Commands

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Format code
flutter format .

# Analyze code
flutter analyze

# Build APK
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## 🧪 Testing Strategy

### Test Types
- **Unit Tests**: Business logic, repositories, use cases
- **Widget Tests**: UI components and user interactions
- **Integration Tests**: End-to-end user journeys

### Coverage Goals
- Minimum 80% code coverage
- All critical user flows tested
- All business logic thoroughly tested

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/presentation/pages/catalog_page_test.dart

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 💾 Data & Caching Strategy

### Caching Architecture
- **Primary Cache**: Hive (Local NoSQL database)
- **Image Cache**: CachedNetworkImage with LRU eviction
- **TTL Strategy**: 30-minute timeout for API data

### Offline Support
1. **Cache-First Strategy**: Always check cache before network
2. **Background Sync**: Update cache when network is available
3. **Offline Indicator**: Visual feedback when offline
4. **Graceful Degradation**: Show cached data with offline banner

### Data Storage
```dart
// Product cache with TTL
CacheBox<Product> products = await Hive.openBox('products');

// User favorites (persistent)
FavoritesBox favorites = await Hive.openBox('favorites');

// Shopping cart (persistent)
CartBox cart = await Hive.openBox('cart');

// Secure token storage
AuthTokenStorage secureStorage = FlutterSecureStorage();
```

## 🎨 Design System

### Color Palette
- **Primary**: #2196F3 (Material Blue)
- **Secondary**: #FF9800 (Material Orange)
- **Error**: #E53E3E
- **Success**: #38A169
- **Warning**: #ED8936

### Typography
- **Headlines**: Material Design Typography 2018
- **Body**: Roboto font family
- **Responsive**: Scales with system font size

### Component Library
- Material Design 3 components
- Consistent 8dp spacing grid
- Rounded corners (8dp buttons, 12dp cards)
- Elevation system for depth

## 🔐 Security Considerations

### Authentication
- JWT tokens stored in secure storage
- Auto-refresh token mechanism
- Secure logout with token cleanup

### Data Protection
- Sensitive data encrypted at rest
- Network communication over HTTPS
- Input validation and sanitization

## 📊 Performance Optimizations

### UI Performance
- `const` constructors for static widgets
- Selective rebuilds with BlocBuilder
- Image optimization and caching
- Lazy loading for large lists

### Network Performance
- Request/response caching
- Compression for API responses
- Background data prefetching
- Retry mechanisms with exponential backoff

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow
- **Trigger**: Push to main, develop, feat/* branches
- **Steps**:
  1. Code formatting verification
  2. Static analysis (flutter analyze)
  3. Unit and widget tests
  4. Coverage reporting
  5. APK build and artifact upload

### Build Artifacts
- **APK**: Available in GitHub Actions artifacts
- **Coverage Reports**: Uploaded to Codecov
- **Build Logs**: Accessible in Actions tab

## 🐛 Known Issues & Limitations

1. **Dependencies**: Some packages require newer Dart SDK versions
2. **Mock API**: Currently uses placeholder endpoints
3. **Authentication**: Mock implementation, not production-ready
4. **Image Loading**: Placeholder images until API integration

## 🔄 Development Roadmap

### Phase 1: Foundation (Current)
- [x] Project structure and architecture
- [x] Basic UI components and theme
- [x] CI/CD pipeline setup
- [ ] Mock data services

### Phase 2: Core Features
- [ ] Authentication flow
- [ ] Product catalog with search/filter
- [ ] Product details with favorites
- [ ] Shopping cart functionality

### Phase 3: Advanced Features
- [ ] Offline caching implementation
- [ ] Push notifications
- [ ] Order management
- [ ] User profile and settings

### Phase 4: Polish & Optimization
- [ ] Performance optimizations
- [ ] Accessibility improvements
- [ ] Comprehensive testing
- [ ] Production deployment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

### Commit Convention
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation updates
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions or updates
- `chore:` Build process or auxiliary tool changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions or support, please open an issue in the GitHub repository or contact the development team.

---

**ShopLite** - A modern Flutter shopping app with clean architecture and offline-first approach.