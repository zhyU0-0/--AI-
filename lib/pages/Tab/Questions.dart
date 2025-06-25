import 'dart:io';
import 'package:flutter/material.dart';
import '../../PhotoService/PhotoService.dart';
import '../../model/DataBase.dart';

class Questions extends StatefulWidget {
  const Questions({super.key});

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  List<Map<String, dynamic>> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await DatabaseService.instance.getAllPhotos();
    setState(() {
      _photos = photos;
    });
  }

  Future<void> _addPhoto() async {
    final pickedFile = await PhotoStorageService.pickImage();
    if (pickedFile != null) {
      // 保存图片到本地存储
      final savedPath = await PhotoStorageService.saveImageToAppDir(pickedFile);

      // 保存记录到数据库
      await DatabaseService.instance.insertPhoto({
        'title': '图片 ${_photos.length + 1}',
        'file_path': savedPath,
        'created_at': DateTime.now().toIso8601String(),
      });

      _loadPhotos(); // 刷新列表
    }
  }

  Future<void> _deletePhoto(int id, String filePath) async {
    // 从数据库删除记录
    await DatabaseService.instance.deletePhoto(id);

    // 删除本地文件
    await PhotoStorageService.deleteImageFile(filePath);

    _loadPhotos(); // 刷新列表
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('照片管理')),
      body: _photos.isEmpty
          ? Center(child: Text('暂无照片，请添加'))
          : ListView.builder(
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return ListTile(
            leading: Image.file(
              File(photo['file_path']),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(photo['title']),
            subtitle: Text(photo['created_at']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePhoto(
                  photo['id'],
                  photo['file_path']
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addPhoto,
      ),
    );
  }
}
