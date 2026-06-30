import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<Database?> get database async {
    if (!isSupported) return null;
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'smart_crm.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache_leads(
            id INTEGER PRIMARY KEY,
            json TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE cache_oportunidades(
            id INTEGER PRIMARY KEY,
            json TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'synced'
          )
        ''');
      },
    );
  }
}
