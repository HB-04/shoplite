class ApiConstants {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String productsEndpoint = '/posts'; // Mock endpoint
  static const String authEndpoint = '/users/1'; // Mock auth endpoint
  
  // Cache constants
  static const int cacheTimeoutMinutes = 30;
  static const String productsCacheKey = 'products_cache';
  static const String authTokenKey = 'auth_token';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
}
