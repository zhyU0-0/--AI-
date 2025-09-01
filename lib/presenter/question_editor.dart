import 'package:summer_assessment/model/DataBase.dart';

import 'photo_service.dart';

class QuestionEditor{
  save(Map<String,dynamic> map)async{
    await DatabaseService.instance.updateQuestion(map);
  }

  Future<String> updatePhoto() async {
    final pickedFile = await PhotoStorageService.pickImage();

    if (pickedFile != null) {
      // 保存图片到本地存储
      final savedPath = await PhotoStorageService.saveImageToAppDir(pickedFile);
      return savedPath;
    }
    return '';
  }
}