import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:daraz_task/constant/api/api_end_point.dart';
import 'package:daraz_task/services/log/api_log.dart';
import 'package:daraz_task/services/storage/storage_service.dart';
import 'api_response_model.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static final Dio _dio = _getMyDio();

  /// ========== [ HTTP METHODS ] ========== ///
  static Future<ApiResponseModel> post(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "POST", body: body, header: header);

  static Future<ApiResponseModel> get(String url, {Map<String, String>? header}) =>
      _request(url, "GET", header: header);

  static Future<ApiResponseModel> put(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "PUT", body: body, header: header);

  static Future<ApiResponseModel> patch(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "PATCH", body: body, header: header);

  static Future<ApiResponseModel> delete(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "DELETE", body: body, header: header);

  static Future<ApiResponseModel> multipart(
    String url, {
    Map<String, String> header = const {},
    Map<String, String> body = const {},
    String method = "POST",
    String imageName = 'image',
    String? imagePath,
  }) async {
    FormData formData = FormData.fromMap(body);

    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        String fileName = file.path.split('/').last;
        String? mimeType = lookupMimeType(file.path);
        formData.files.add(
          MapEntry(
            imageName,
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          ),
        );
      }
    }

    return _request(url, method, body: formData, header: header);
  }

  /// ========== [ API REQUEST HANDLER ] ========== ///
  static Future<ApiResponseModel> _request(
    String url,
    String method, {
    dynamic body,
    Map<String, String>? header,
  }) async {
    try {
      final response = await _dio.request(
        url,
        data: body,
        options: Options(method: method, headers: header),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponseModel _handleResponse(Response response) {
    if (response.statusCode == 201) {
      return ApiResponseModel(200, response.data);
    }
    return ApiResponseModel(response.statusCode, response.data);
  }

  static ApiResponseModel _handleError(dynamic error) {
    try {
      return _handleDioException(error);
    } catch (e) {
      return ApiResponseModel(500, {});
    }
  }

  static ApiResponseModel _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiResponseModel(408, {"message": "Request timed out"});
      case DioExceptionType.badResponse:
        return ApiResponseModel(error.response?.statusCode, error.response?.data);
      case DioExceptionType.connectionError:
        return ApiResponseModel(503, {"message": "No internet connection"});
      default:
        return ApiResponseModel(400, {});
    }
  }
}

/// ========== [ DIO INSTANCE WITH INTERCEPTORS ] ========== ///
Dio _getMyDio() {
  final storage = AppStorage();

  Dio dio = Dio();

  dio.interceptors.add(apiLog());

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = storage.getToken();
        options
          ..headers["Authorization"] ??= token.isNotEmpty ? "Bearer $token" : null
          ..headers["Content-Type"] ??= "application/json"
          ..connectTimeout = const Duration(seconds: 30)
          ..sendTimeout = const Duration(seconds: 30)
          ..receiveDataWhenStatusError = true
          ..responseType = ResponseType.json
          ..receiveTimeout = const Duration(seconds: 30)
          ..baseUrl = options.baseUrl.startsWith("http") ? "" : ApiEndPoint.baseUrl;
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );

  return dio;
}
