import 'package:dio/dio.dart';
import 'package:esdcustomer/config/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = GetStorage().read(ApiConstants.storageToken);
          if (token != null && token.toString().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;

  Future<Map<String, dynamic>> get(String url, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(url, queryParameters: query);
      return _asMap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String url, {Map<String, dynamic>? data}) async {
    try {
      final res = await _dio.post(url, data: data);
      return _asMap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(String url, {Map<String, dynamic>? data}) async {
    try {
      final res = await _dio.put(url, data: data);
      return _asMap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String url) async {
    try {
      final res = await _dio.delete(url);
      return _asMap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> postForm(String url, FormData data) async {
    try {
      final res = await _dio.post(url, data: data);
      return _asMap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _asMap(Response res) {
    if (res.data is Map<String, dynamic>) return res.data;
    return {'status': true, 'data': res.data};
  }

  ApiException _handleError(DioException e) {
    final code = e.response?.statusCode;
    String msg = 'Something went wrong. Please try again.';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      msg = 'Unable to connect. Check your internet connection.';
    } else if (e.response?.data is Map && e.response?.data['message'] != null) {
      msg = e.response?.data['message'];
    } else if (code == 401) {
      msg = 'Session expired. Please login again.';
    }
    return ApiException(msg, code);
  }
}