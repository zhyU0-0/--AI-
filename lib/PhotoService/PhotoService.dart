import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class PhotoStorageService {
  static final ImagePicker _picker = ImagePicker();

  // 从相册选择图片
  static Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,  // 压缩质量
    );
  }

  // 保存图片到应用目录
  static Future<String> saveImageToAppDir(XFile imageFile) async {
    // 获取应用文档目录
    final appDir = await getApplicationDocumentsDirectory();

    // 创建photos子目录
    final photosDir = Directory('${appDir.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // 生成唯一文件名 (时间戳+随机数)
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final random = (10000 + DateTime.now().millisecond % 90000).toString();
    final extension = path.extension(imageFile.path);
    final newFileName = 'photo_${timestamp}_$random$extension';

    // 保存文件
    final newFile = File('${photosDir.path}/$newFileName');
    await newFile.writeAsBytes(await imageFile.readAsBytes());

    return newFile.path;
  }

  // 删除本地图片文件
  static Future<void> deleteImageFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}