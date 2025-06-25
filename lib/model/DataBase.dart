import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:summer_assessment/main.dart';

import 'Class.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if(_database != null)return _database!;
    _database = await _initDB('node.db');

    if((await DatabaseService.instance.getAllHistory()).length == 0){
      DatabaseService.instance.insertHistory(jsonEncode([]));
    }
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,filePath);

    return await openDatabase(
        path,
        version: 6,
        onCreate: (db,version){
          return Future.wait([
            db.execute("CREATE TABLE photos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT,file_path TEXT NOT NULL,created_at TEXT NOT NULL,is_favorite INTEGER DEFAULT 0)"),
            db.execute("CREATE TABLE histories(id INTEGER PRIMARY KEY AUTOINCREMENT, history TEXT)"),
          ]);
        }
    );



  }
  // 插入照片记录
  Future<int> insertPhoto(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert("photos", row);
  }
  Future<int> insertHistory(String history) async {
    final db = await instance.database;
    DateTime now = DateTime.now();
    return await db.insert("histories", {"history":history});
  }

  // 获取所有照片
  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    final db = await instance.database;
    return await db.query("photos", orderBy: 'created_at DESC');
  }

  Future<List<Map<String,dynamic>>> getAllHistory() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      "histories",
    );
    return maps;
  }

  // 删除照片
  Future<int> deletePhoto(int id) async {
    final db = await instance.database;
    return await db.delete(
      "photos",
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHistory(int id) async {
    final db = await instance.database;
    return await db.delete(
      "histories",
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> AddHistory(String oldH,String newH) async {
    logger.d(oldH+"   "+newH);
    final db = await instance.database;
    return await db.update(
      "histories",
      {"history":newH},
      where: 'history = ?',
      whereArgs: [oldH],
    );
  }

}