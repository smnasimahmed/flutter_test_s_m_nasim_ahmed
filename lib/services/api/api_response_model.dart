class ApiResponseModel {
  final int? _statusCode;
  final dynamic _data;

  ApiResponseModel(this._statusCode, this._data);

  bool get isSuccess => _statusCode == 200;

  int get statusCode => _statusCode ?? 500;

  String get message {
    if (_statusCode == 502) {
      return "Server is starting, please wait...";
    }
    if (_data is Map) {
      return _data?['message']?.toString() ?? "Something went wrong";
    }
    return "Something went wrong";
  }

  dynamic get data => _data ?? {};
}
