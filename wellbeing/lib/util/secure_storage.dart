import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._internal();

  static final SecureStorageService instance = SecureStorageService._internal();

  factory SecureStorageService() => instance;

  /// 🔐 Storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ==========================
  // 🔹 BASIC METHODS
  // ==========================

  Future<void> write(String key, String value) async {
    log("🔐 Write → $key");
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    log("🔐 Read → $key");
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    log("🗑 Delete → $key");
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    log("🗑 Delete ALL");
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // ==========================
  // 🔹 JSON / OBJECT METHODS
  // ==========================

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await write(key, jsonString);
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    final data = await read(key);
    if (data == null) return null;

    try {
      return jsonDecode(data);
    } catch (e) {
      log("❌ JSON Decode Error: $e");
      return null;
    }
  }

  // ==========================
  // 🔹 LIST SUPPORT
  // ==========================

  Future<void> writeList(String key, List<dynamic> value) async {
    await write(key, jsonEncode(value));
  }

  Future<List<dynamic>?> readList(String key) async {
    final data = await read(key);
    if (data == null) return null;

    try {
      return jsonDecode(data);
    } catch (e) {
      log("❌ List Decode Error: $e");
      return null;
    }
  }
}
