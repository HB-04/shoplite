import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_product.dart';
import '../models/api_response.dart';
import '../../core/helpers/app_exceptions.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';
  static const int defaultTimeout = 5;

  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Get products with pagination and optional search/category filters
  Future<ProductsResponse> getProducts({
    int limit = 20,
    int skip = 0,
    String? search,
    String? category,
  }) async {
    try {
      String endpoint = '/products';
      Map<String, String> queryParams = {
        'limit': limit.toString(),
        'skip': skip.toString(),
      };

      // Handle search vs category filtering
      if (search != null && search.isNotEmpty) {
        endpoint = '/products/search';
        queryParams['q'] = search;
      } else if (category != null && category.isNotEmpty && category != 'All Categories') {
        endpoint = '/products/category/$category';
        // Category endpoint doesn't need additional params for filtering
        queryParams = {
          'limit': limit.toString(),
          'skip': skip.toString(),
        };
      }

      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: defaultTimeout));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProductsResponse.fromJson(json);
      } else {
        throw ServerException(
          message: 'Failed to fetch products: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network error occurred',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // Get single product by ID
  Future<ApiProduct> getProduct(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$id');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: defaultTimeout));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiProduct.fromJson(json);
      } else {
        throw ServerException(
          message: 'Failed to fetch product: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network error occurred',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/products/categories');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: defaultTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
        
        // DummyJSON returns objects with "name" property, extract the names
        final categories = json
            .map((category) => category['name'] as String)
            .toList();
        
        // Add "All Categories" at the beginning
        return ['All Categories', ...categories];
      } else {
        throw ServerException(
          message: 'Failed to fetch categories: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network error occurred',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // Mock login - using DummyJSON auth endpoint
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15)); // Longer timeout for login

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(json);
      } else {
        throw AuthenticationException(
          message: 'Invalid credentials',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw const NetworkException(
        message: 'Login request timed out. Please check your connection and try again.',
      );
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Network error occurred',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
