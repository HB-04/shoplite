import 'package:flutter/widgets.dart';
import '../../presentation/providers/app_state_provider.dart';

class AppStringsHelper {
  static String translate(BuildContext context, String key) {
    final provider = AppStateProvider.of(context, listen: false);
    return provider.translate(key);
  }
}
