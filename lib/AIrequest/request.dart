import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/model/DataBase.dart';
import 'package:web_socket_channel/status.dart';

import '../main.dart';

class AIService{
  static String Api_key = 'sk-8304f07190544c7682b42db3c894a3d6';
  static String Api_Url = 'https://api.deepseek.com/v1';
  static String chat_api = '/chat/completions';
  List<Map<String,String>> message_history = [];
  AIService(){
    init();
  }
  init()async{

  }
  Future<String> getChatCompletion(String prompt, int id) async {
    try {
      // 添加用户的新消息到对话历史
      message_history = await getHistory(id);
      List<Map<String, String>> old = await getHistory(id);
      message_history.add({
        'role': 'user',
        'content': prompt
      });

      final response = await http.post(
        Uri.parse(Api_Url+chat_api),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $Api_key',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': message_history,
        }),
      );

      if (response.statusCode == 200) {
        String decodedBody;
        try {
          // 先尝试UTF-8
          decodedBody = utf8.decode(response.bodyBytes);
        } catch (e) {
          // 如果UTF-8失败，尝试GBK或其他编码
          final gbk = Encoding.getByName('GBK');
          if (gbk != null) {
            decodedBody = gbk.decode(response.bodyBytes);
          } else {
            decodedBody = latin1.decode(response.bodyBytes); // 最后尝试Latin1
          }
        }

        logger.d('解码后的内容: $decodedBody');
        RegExp exp = RegExp("\"content\":\"(.*?)\"");
        var result = exp.firstMatch(decodedBody);
        var real_result = result!.group(0).toString().split(":")[1].split("\"")[1];
        logger.d("解析后：："+real_result);
        final data = jsonDecode(response.body);
        final assistantReply = data['choices'][0]['message']['content'];

        // 添加AI的回复到对话历史
        message_history.add({
          'role': 'assistant',
          'content':real_result
        });
        saveHistory(message_history,id);
        return assistantReply;
      } else {

        logger.d('Failed to load completion: ${response.statusCode}');
        logger.d("body:"+ jsonEncode({
          'model': 'deepseek-chat',
          'messages': message_history,
        }),);
        return 'fail';

      }
    } catch (e) {

      logger.d('Error: $e');
      return 'fail';
    }
  }

  clearConversation() async{
    logger.d(message_history.length);
    final prefs = await SharedPreferences.getInstance();
    var username = await prefs.getString("user_name");
    var len = (await DatabaseService.instance.getAllHistory(username.toString())).length;
    if(message_history.length != 0){
      print("insert");
      DatabaseService.instance.insertHistory(jsonEncode([]),username.toString(),(len+1).toString());
    }
    message_history.clear();
  }

  saveHistory(List<Map<String,String>> list,int id)async{
    try {
      final prefs = await SharedPreferences.getInstance();
      var username = await prefs.getString("user_name");
      // 将List<Map>转换为JSON字符串
      String jsonString = jsonEncode(list);
      logger.d("存History"+id.toString()+jsonString);
      // 存储到SharedPreferences
      logger.d("111");
      DatabaseService.instance.AddHistory(id+1,username.toString(),jsonString);
      return (await DatabaseService.instance.getAllHistory(username.toString()))[id]["history"];
    } catch (e) {
      print('保存失败: $e');
      return false;
    }
  }
  Future<List<Map<String,String>>>getHistory(int id)async{

    try {
      logger.d("000${id}");
      final prefs = await SharedPreferences.getInstance();
      var username = await prefs.getString("user_name");
      String? jsonString = (await DatabaseService.instance.getAllHistory(username.toString()))[id]["history"];
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Map<String,String>> result = jsonList.map((item) => Map<String, String>.from(item)).toList();
      logger.d("取History"+id.toString()+result.toString());
      return result;
    } catch (e) {
      print('读取失败: $e');
      return [];
    }

  }

}