import 'package:summer_assessment/model/DataBase.dart';

class QuestionEditor{
  save(int id,String name,String description,int type)async{
    await DatabaseService.instance.updateQuestion(id, name, description, type.toString());
  }
}