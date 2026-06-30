import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/sync_status.dart';
import '../models/lead.dart';

class LeadCacheDao {
  static const String table = 'cache_leads';

  Future<void> replaceSynced(List<Lead> leads) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;
    await db.delete(table, where: 'sync_status = ?', whereArgs: [SyncStatus.synced]);
    for (final lead in leads) {
      await upsert(lead, SyncStatus.synced);
    }
  }

  Future<void> upsert(Lead lead, String syncStatus) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;
    await db.insert(
      table,
      {
        'id': lead.id,
        'json': jsonEncode(lead.toJson()),
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

  Future<void> markPendingDelete(int id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;
    await db.update(
      table,
      {'sync_status': SyncStatus.pendingDelete},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Lead>> getAllVisible() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];
    final rows = await db.query(
      table,
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.pendingDelete],
      orderBy: 'id DESC',
    );
    return rows.map(_leadFromRow).toList();
  }

  Future<Lead?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return null;
    final rows = await db.query(
      table,
      where: 'id = ? AND sync_status != ?',
      whereArgs: [id, SyncStatus.pendingDelete],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _leadFromRow(rows.first);
  }

  Future<List<Lead>> getPending() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];
    final rows = await db.query(
      table,
      where: 'sync_status IN (?, ?, ?)',
      whereArgs: [
        SyncStatus.pendingCreate,
        SyncStatus.pendingUpdate,
        SyncStatus.pendingDelete,
      ],
    );
    return rows.map(_leadFromRow).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingRows() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];
    return db.query(
      table,
      where: 'sync_status IN (?, ?, ?)',
      whereArgs: [
        SyncStatus.pendingCreate,
        SyncStatus.pendingUpdate,
        SyncStatus.pendingDelete,
      ],
    );
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

  Lead _leadFromRow(Map<String, dynamic> row) {
    final map = jsonDecode(row['json'] as String) as Map<String, dynamic>;
    return Lead.fromJson(map);
  }
}
