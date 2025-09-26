import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/product.dart';
import '../providers/app_state_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/loading_shimmer.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    
    // Initialize search controller with current search query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      _searchController.text = appState.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        // Load more when near the bottom
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        if (appState.hasMoreProducts && !appState.isProductsLoading) {
          appState.loadMoreProducts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Remove unused variable
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Offline banner
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              if (appState.connectionStatus == AppConnectionStatus.offline) {
                return const OfflineBanner();
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Search bar
          _buildSearchBar(context),
          
          // Category filters
          _buildCategoryFilters(context),
          
          // Products grid
          Expanded(
            child: _buildProductsGrid(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppStrings.appName(context)),
      actions: [
        // Theme toggle
        Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            return IconButton(
              icon: Icon(
                appState.themeMode == ThemeMode.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              onPressed: () => appState.toggleTheme(),
              tooltip: 'Toggle theme',
            );
          },
        ),
        
        // Cart
        Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => _handleCartPressed(context, appState),
                ),
                if (appState.cartItemsCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${appState.cartItemsCount}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        
        // User menu
        Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            if (appState.isAuthenticated && appState.currentUser != null) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle_outlined),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text('Hello, ${appState.currentUser!.name}'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text(AppStrings.logout(context)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    appState.logout();
                  }
                },
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.login),
                onPressed: () => Navigator.pushNamed(context, AppConstants.loginRoute),
                tooltip: AppStrings.login(context),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppStrings.searchProducts(context),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_searchController.text == value) {
                  appState.setSearchQuery(value);
                }
              });
            },
            onSubmitted: (value) => appState.setSearchQuery(value),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: appState.categories.length,
            itemBuilder: (context, index) {
              final category = appState.categories[index];
              final isSelected = category == appState.selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    appState.setSelectedCategory(category);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // Handle loading state for initial load
        if (appState.products.isEmpty && appState.isProductsLoading) {
          return const LoadingShimmer();
        }

        // Handle error state
        if (appState.products.isEmpty && appState.productsError != null) {
          return _buildErrorState(context, appState);
        }

        // Handle empty state
        if (appState.products.isEmpty) {
          return _buildEmptyState(context);
        }

        // Handle products grid
        return RefreshIndicator(
          onRefresh: () => appState.refreshProducts(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ProductCard(
                        product: appState.products[index],
                        onTap: () => _handleProductTap(context, appState.products[index]),
                        onFavoriteToggle: () => _handleFavoriteToggle(appState, appState.products[index].id),
                        onAddToCart: () => _handleAddToCart(context, appState, appState.products[index]),
                      );
                    },
                    childCount: appState.products.length,
                  ),
                ),
              ),
              
              // Loading indicator for pagination
              if (appState.isProductsLoading && appState.products.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, AppStateProvider appState) {
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
            appState.productsError ?? AppStrings.somethingWentWrong(context),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => appState.refreshProducts(),
            icon: const Icon(Icons.refresh),
            label: Text(AppStrings.retry(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noProductsFound(context),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              appState.setSearchQuery('');
              appState.setSelectedCategory('All Categories');
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  void _handleCartPressed(BuildContext context, AppStateProvider appState) {
    if (!appState.isAuthenticated) {
      _showLoginRequired(context);
      return;
    }
    Navigator.pushNamed(context, AppConstants.cartRoute);
  }

  void _handleProductTap(BuildContext context, Product product) {
    Navigator.pushNamed(
      context,
      AppConstants.productDetailRoute,
      arguments: product.id,
    );
  }

  void _handleFavoriteToggle(AppStateProvider appState, int productId) async {
    final success = await appState.toggleFavorite(productId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.isProductFavorite(productId)
                ? AppStrings.addToFavorites(context)
                : AppStrings.removeFromFavorites(context),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleAddToCart(BuildContext context, AppStateProvider appState, Product product) async {
    if (!appState.isAuthenticated) {
      _showLoginRequired(context);
      return;
    }

    final success = await appState.addToCart(product);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(AppStrings.addedToCart(context)),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.cartRoute);
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.authenticationRequired(context)),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(context, AppConstants.loginRoute);
  }
}