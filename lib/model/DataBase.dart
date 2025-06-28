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
            db.execute("CREATE TABLE users("
                "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "name TEXT NOT NULL UNIQUE,"
                "email TEXT NOT NULL,"
                "password TEXT NOT NULL,"
                "image TEXT NOT NULL"
                ")"),
            db.execute("CREATE TABLE photos("
                "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                "title TEXT,file_path TEXT NOT NULL,"
                "created_at TEXT NOT NULL,"
                "is_favorite INTEGER DEFAULT 0,"
                "discription TEXT"
                ")"),
            db.execute("CREATE TABLE histories("
                "id TEXT NOT NULL, "
                "name TEXT NOT NULL,"
                "history TEXT"
                ")"),
          ]);
        }
    );



  }
  // 插入照片记录
  Future<int> insertPhoto(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert("photos", row);
  }
  Future<int> insertHistory(String history,String name,String id) async {
    logger.d("insert::");
    final db = await instance.database;
    DateTime now = DateTime.now();
    return await db.insert("histories", {"id":id,"history":history,"name":name});
  }
  Future<int> insertUser(String name,String password,String image,String email) async {
    final db = await instance.database;
    try{
      return await db.insert("users", {
        "name":name,
        "password":password,
        "email":email,
        "image":image
      });
    }catch(e){
      return -1;
    }
  }
  // 获取所有照片
  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    final db = await instance.database;
    return await db.query("photos", orderBy: 'created_at DESC');
  }

  Future<List<Map<String,dynamic>>> getAllHistory(String name) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      "histories",
      where: "name = ?",
      whereArgs: [name]
    );
    return maps;
  }

  Future<String> getPassword(String name) async{
    final db = await instance.database;
    final List<Map<String,Object?>> result = await db.query(
      "users",
      whereArgs: [name],
      where: "name = ?"
    );
    logger.d(result);
    return result[0]["password"].toString();
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

  Future<int> AddHistory(int id,String name,String newH) async {
    logger.d("00");
    final db = await instance.database;
    logger.d("11  id::"+id.toString());
    return await db.update(
      "histories",
      {"history":newH},
      where: 'id = ? AND name = ?',
      whereArgs: [id,name],
    );
  }

}