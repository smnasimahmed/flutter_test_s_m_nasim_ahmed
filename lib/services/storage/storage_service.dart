import 'package:get_storage/get_storage.dart';
import 'storage_keys.dart';

class AppStorage {
  static final AppStorage _instance = AppStorage._internal();
  factory AppStorage() => _instance;
  AppStorage._internal();

  final GetStorage _box = GetStorage();

  // ========== Token ==========
  String getToken() => _box.read(LocalStorageKeys.token) ?? "";
  Future<void> setToken(String value) => _box.write(LocalStorageKeys.token, value);

  // ========== Login ==========
  bool getLoginValue() => _box.read(LocalStorageKeys.isLogIn) ?? false;
  Future<void> setLoginValue(bool value) => _box.write(LocalStorageKeys.isLogIn, value);

  // ========== User ID ==========
  int getUserId() => _box.read(LocalStorageKeys.userId) ?? 0;
  Future<void> setUserId(int value) => _box.write(LocalStorageKeys.userId, value);

  // ========== User Name ==========
  String getUserName() => _box.read(LocalStorageKeys.myName) ?? "";
  Future<void> setUserName(String value) => _box.write(LocalStorageKeys.myName, value);

  // ========== User Email ==========
  String getUserEmail() => _box.read(LocalStorageKeys.myEmail) ?? "";
  Future<void> setUserEmail(String value) => _box.write(LocalStorageKeys.myEmail, value);

  // ========== Clear All ==========
  Future<void> clearAll() => _box.erase();
}
