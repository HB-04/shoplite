import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/catalog_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/product_detail_page.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/providers/app_state_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await ServiceLocator().init();
  
  runApp(const ShopLiteApp());
}

class ShopLiteApp extends StatelessWidget {
  const ShopLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStateProvider>(
      create: (context) => ServiceLocator().appStateProvider,
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            home: appState.isInitialized ? const CatalogPage() : const SplashPage(),
            routes: {
              AppConstants.loginRoute: (context) => const LoginPage(),
              AppConstants.catalogRoute: (context) => const CatalogPage(),
              AppConstants.cartRoute: (context) => const CartPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AppConstants.productDetailRoute) {
                final productId = settings.arguments as int;
                return MaterialPageRoute(
                  builder: (context) => ProductDetailPage(productId: productId),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}