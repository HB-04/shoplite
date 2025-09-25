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
        title: const Text(AppStrings.cart),
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
            appState.cartError ?? AppStrings.somethingWentWrong,
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
            label: const Text(AppStrings.retry),
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
            AppStrings.emptyCart,
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
          label: Text('${AppStrings.checkout} - \$${appState.cartTotal.toStringAsFixed(2)}'),
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
        const SnackBar(
          content: Text(AppStrings.removeFromCart),
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
        title: const Text(AppStrings.orderSummary),
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
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => _processOrder(context, appState),
            child: const Text(AppStrings.placeOrder),
          ),
        ],
      ),
    );
  }

  void _processOrder(BuildContext context, AppStateProvider appState) async {
    Navigator.pop(context); // Close dialog

    // Mock order processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing order...'),
          ],
        ),
      ),
    );

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      // Clear cart
      await appState.clearCart();

      // Show success
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed!'),
            content: const Text(AppStrings.orderPlaced),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to catalog
                },
                child: const Text(AppStrings.ok),
              ),
            ],
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
            child: const Text(AppStrings.cancel),
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
