import 'package:flutter/widgets.dart';
import '../helpers/app_strings_helper.dart';

class AppStrings {
  static String translate(BuildContext context, String key) {
    return AppStringsHelper.translate(context, key);
  }

  static String appName(BuildContext context) => translate(context, 'appName');
  static String loading(BuildContext context) => translate(context, 'loading');
  static String error(BuildContext context) => translate(context, 'error');
  static String retry(BuildContext context) => translate(context, 'retry');
  static String ok(BuildContext context) => translate(context, 'ok');
  static String cancel(BuildContext context) => translate(context, 'cancel');
  static String save(BuildContext context) => translate(context, 'save');
  static String delete(BuildContext context) => translate(context, 'delete');
  static String login(BuildContext context) => translate(context, 'loginTitle');
  static String logout(BuildContext context) => translate(context, 'logout');
  static String email(BuildContext context) => translate(context, 'emailField');
  static String password(BuildContext context) => translate(context, 'passwordField');
  static String loginError(BuildContext context) => translate(context, 'loginError');
  static String loginSuccess(BuildContext context) => translate(context, 'loginSuccess');
  static String products(BuildContext context) => translate(context, 'catalogTitle');
  static String searchProducts(BuildContext context) => translate(context, 'searchHint');
  static String noProductsFound(BuildContext context) => translate(context, 'noProductsFound');
  static String loadMore(BuildContext context) => translate(context, 'loadMore');
  static String pullToRefresh(BuildContext context) => translate(context, 'pullToRefresh');
  static String category(BuildContext context) => translate(context, 'category');
  static String allCategories(BuildContext context) => translate(context, 'categoryAll');
  static String productDetails(BuildContext context) => translate(context, 'productDetails');
  static String addToCart(BuildContext context) => translate(context, 'addToCart');
  static String addedToCart(BuildContext context) => translate(context, 'addedToCart');
  static String addToFavorites(BuildContext context) => translate(context, 'addToFavorites');
  static String removeFromFavorites(BuildContext context) => translate(context, 'removeFromFavorites');
  static String rating(BuildContext context) => translate(context, 'rating');
  static String reviews(BuildContext context) => translate(context, 'reviews');
  static String description(BuildContext context) => translate(context, 'description');
  static String cart(BuildContext context) => translate(context, 'cartLabel');
  static String emptyCart(BuildContext context) => translate(context, 'emptyCart');
  static String cartTotal(BuildContext context) => translate(context, 'cartTotal');
  static String checkout(BuildContext context) => translate(context, 'checkout');
  static String quantity(BuildContext context) => translate(context, 'quantity');
  static String removeFromCart(BuildContext context) => translate(context, 'removeFromCart');
  static String updateQuantity(BuildContext context) => translate(context, 'updateQuantity');
  static String placeOrder(BuildContext context) => translate(context, 'placeOrder');
  static String orderPlaced(BuildContext context) => translate(context, 'orderSuccess');
  static String orderSummary(BuildContext context) => translate(context, 'orderSummary');
  static String totalAmount(BuildContext context) => translate(context, 'totalAmount');
  static String paymentMethod(BuildContext context) => translate(context, 'paymentMethod');
  static String creditCard(BuildContext context) => translate(context, 'creditCard');
  static String offline(BuildContext context) => translate(context, 'offline');
  static String offlineMessage(BuildContext context) => translate(context, 'offlineBanner');
  static String noInternetConnection(BuildContext context) => translate(context, 'noInternetConnection');
  static String checkConnectionAndRetry(BuildContext context) => translate(context, 'checkConnectionAndRetry');
  static String somethingWentWrong(BuildContext context) => translate(context, 'error');
  static String networkError(BuildContext context) => translate(context, 'networkError');
  static String serverError(BuildContext context) => translate(context, 'serverError');
  static String authenticationRequired(BuildContext context) => translate(context, 'authenticationRequired');
  static String unauthorizedAccess(BuildContext context) => translate(context, 'unauthorizedAccess');
  static String settings(BuildContext context) => translate(context, 'settings');
  static String theme(BuildContext context) => translate(context, 'theme');
  static String lightTheme(BuildContext context) => translate(context, 'lightTheme');
  static String darkTheme(BuildContext context) => translate(context, 'darkTheme');
  static String systemTheme(BuildContext context) => translate(context, 'systemTheme');
  static String changeLanguage(BuildContext context) => translate(context, 'languageToggle');
}
