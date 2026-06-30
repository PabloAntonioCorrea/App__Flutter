import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/sync_status.dart';
import '../models/oportunidade.dart';

class OportunidadeCacheDao {
  static const String table = 'cache_oportunidades';

  Future<void> replaceSynced(List<Oportunidade> items) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;
    await db.delete(table, where: 'sync_status = ?', whereArgs: [SyncStatus.synced]);
    for (final item in items) {
      await upsert(item, SyncStatus.synced);
    }
  }

  Future<void> upsert(Oportunidade item, String syncStatus) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;
    await db.insert(
      table,
      {
        'id': item.id,
        'json': jsonEncode(item.toJson()),
        'sync_status': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById(int id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Oportunidade>> getAllVisible() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];
    final rows = await db.query(
      table,
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.pendingDelete],
      orderBy: 'id DESC',
    );
    return rows.map(_itemFromRow).toList();
  }

  Future<Oportunidade?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return null;
    final rows = await db.query(
      table,
      where: 'id = ? AND sync_status != ?',
      whereArgs: [id, SyncStatus.pendingDelete],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _itemFromRow(rows.first);
  }

  Future<int> nextLocalId() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return -1;
    final result = await db.rawQuery(
      'SELECT MIN(id) as min_id FROM $table WHERE id < 0',
    );
    final min = result.first['min_id'] as int?;
    return (min ?? 0) - 1;
  }

  Oportunidade _itemFromRow(Map<String, dynamic> row) {
    final map = jsonDecode(row['json'] as String) as Map<String, dynamic>;
    return Oportunidade.fromJson(map);
  }
}
