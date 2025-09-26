import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/pages/catalog_page.dart';
import '../../presentation/pages/cart_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/product_detail_page.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.catalogRoute:
        return MaterialPageRoute(builder: (_) => const CatalogPage());
      case AppConstants.cartRoute:
        return MaterialPageRoute(builder: (_) => const CartPage());
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppConstants.productDetailRoute:
        final productId = settings.arguments;
        if (productId is int) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(productId: productId),
          );
        }
        break;
      default:
        if (settings.name != null && settings.name!.startsWith('/product/')) {
          final idString = settings.name!.replaceFirst('/product/', '');
          final productId = int.tryParse(idString);
          if (productId != null) {
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: productId),
            );
          }
        }
    }
    return MaterialPageRoute(builder: (_) => const CatalogPage());
  }
}
