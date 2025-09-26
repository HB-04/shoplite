import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static const String _testUrl = 'https://dummyjson.com/products?limit=1';
  static const Duration _timeout = Duration(seconds: 5);
  
  final http.Client _client;
  final Connectivity _connectivity;
  StreamSubscription? _subscription;
  
  ConnectivityService({
    http.Client? client,
    Connectivity? connectivity,
  }) : _client = client ?? http.Client(),
       _connectivity = connectivity ?? Connectivity();

  Future<bool> checkConnectivity() async {
    try {
      // First check device connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Then try a DNS lookup
      try {
        final lookupResult = await InternetAddress.lookup('dummyjson.com');
        if (lookupResult.isEmpty || lookupResult[0].rawAddress.isEmpty) {
          return false;
        }
      } on SocketException {
        return false;
      }

      // Finally try a real API request
      try {
        final response = await _client
            .get(Uri.parse(_testUrl))
            .timeout(_timeout);
        
        return response.statusCode == 200;
      } on TimeoutException {
        return false;
      } on SocketException {
        return false;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result == ConnectivityResult.none) {
        return false;
      }
      return checkConnectivity();
    });
  }

  void startListening(void Function(bool) onConnectivityChanged) {
    _subscription?.cancel();
    _subscription = this.onConnectivityChanged.listen(onConnectivityChanged);
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
    _client.close();
  }
}