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
      imageQuality: 85,
    );
  }


  static Future<String> saveImageToAppDir(XFile imageFile) async {

    final appDir = await getApplicationDocumentsDirectory();


    final photosDir = Directory('${appDir.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }


    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final random = (10000 + DateTime.now().millisecond % 90000).toString();
    final extension = path.extension(imageFile.path);
    final newFileName = 'photo_${timestamp}_$random$extension';

    final newFile = File('${photosDir.path}/$newFileName');
    await newFile.writeAsBytes(await imageFile.readAsBytes());

    return newFile.path;
  }

  static Future<void> deleteImageFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}