
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../providers/app_state_provider.dart';
import '../widgets/cart_item_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.cart(context)),
        actions: [
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              if (appState.cartItems.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearCartDialog(appState),
                  child: const Text('Clear'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.isCartLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (appState.cartError != null) {
            return _buildErrorState(appState);
          }

          if (appState.cartItems.isEmpty) {
            return _buildEmptyCartState(context);
          }

          return _buildCartContent(appState);
        },
      ),
      bottomNavigationBar: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.cartItems.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildCheckoutBar(context, appState);
        },
      ),
    );
  }

  Widget _buildErrorState(AppStateProvider appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            appState.cartError ?? AppStrings.somethingWentWrong(context),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Reload cart
              appState.clearCartError();
            },
            icon: const Icon(Icons.refresh),
            label: Text(AppStrings.retry(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.emptyCart(context),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Browse our products and add items to your cart',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(AppStateProvider appState) {
    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = appState.cartItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CartItemCard(
                  cartItem: cartItem,
                  onQuantityChanged: (quantity) => _handleQuantityChange(
                    appState,
                    cartItem.product.id,
                    quantity,
                  ),
                  onRemove: () => _handleRemoveItem(
                    appState,
                    cartItem.product.id,
                  ),
                ),
              );
            },
          ),
        ),

        // Cart summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal (${appState.cartItemsCount} items)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${appState.cartTotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, AppStateProvider appState) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handleCheckout(context, appState),
          icon: const Icon(Icons.payment),
          label: Text('${AppStrings.checkout(context)} - \$${appState.cartTotal.toStringAsFixed(2)}'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  void _handleQuantityChange(AppStateProvider appState, int productId, int quantity) async {
    if (quantity <= 0) {
      _handleRemoveItem(appState, productId);
      return;
    }

    final success = await appState.updateCartQuantity(productId, quantity);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.cartError ?? 'Failed to update quantity'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleRemoveItem(AppStateProvider appState, int productId) async {
    final success = await appState.removeFromCart(productId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.removeFromCart(context)),
          duration: Duration(seconds: 1),
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.cartError ?? 'Failed to remove item'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleCheckout(BuildContext context, AppStateProvider appState) {
    // Mock checkout process
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.orderSummary(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${appState.cartItemsCount}'),
            const SizedBox(height: 8),
            Text('Total: \$${appState.cartTotal.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('This is a demo checkout. In a real app, you would integrate with a payment processor.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(context)),
          ),
          ElevatedButton(
            onPressed: () => _processOrder(context, appState),
            child: Text(AppStrings.placeOrder(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder(BuildContext context, AppStateProvider appState) async {
    try {
      Navigator.pop(context); // Close confirmation dialog

      // Show processing dialog with animation
      BuildContext? dialogContext;
      await showDialog(
      context: context,
      barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
            onWillPop: () async {
              // Allow back navigation during processing
              final shouldPop = await showDialog<bool>(
                context: context,
      builder: (context) => AlertDialog(
                  title: const Text('Cancel Order?'),
                  content: const Text('Are you sure you want to cancel the order processing?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('NO'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('YES'),
                    ),
                  ],
                ),
              ) ?? false;
              return shouldPop;
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loading animation with rotating and scaling icon
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 2 * 3.14159),
                                duration: const Duration(seconds: 2),
                                curve: Curves.linear,
                                builder: (context, rotation, child) {
                                  return Transform.rotate(
                                    angle: rotation,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                            blurRadius: 16,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context).colorScheme.primary,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.8, end: 1.2),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeInOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 24,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Processing your order...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait while we confirm your order',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
          ],
        ),
      ),
            ),
          );
        },
    );

      // Simulate processing time and clear cart
    await Future.delayed(const Duration(seconds: 2));
      await appState.clearCart();

      // Close processing dialog if still mounted and dialog context exists
      if (mounted && dialogContext != null) {
        Navigator.of(dialogContext!).pop(); // Close processing dialog

        // Show success dialog with animation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success icon with animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Order Placed Successfully!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.orderPlaced(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Thank you for shopping with us!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to catalog
                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(
                            'Continue Shopping',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process order: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showClearCartDialog(AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appState.clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
