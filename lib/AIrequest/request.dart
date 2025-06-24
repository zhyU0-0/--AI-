import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class AIService{
  static String Api_key = 'sk-8304f07190544c7682b42db3c894a3d6';
  static String Api_Url = 'https://api.deepseek.com/v1';
  static String chat_api = '/chat/completions';
  List<Map<String,String>> message_history = [];

  Future<String> getChatCompletion(String prompt) async {
    try {
      // 添加用户的新消息到对话历史
      message_history = await getHistory();
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
        saveHistory(message_history);
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
    message_history.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('my_History', '');
  }

  saveHistory(List<Map<String,String>> list)async{
    try {
      final prefs = await SharedPreferences.getInstance();

      // 将List<Map>转换为JSON字符串
      String jsonString = jsonEncode(list);
      logger.d("存History"+jsonString);
      // 存储到SharedPreferences
      return await prefs.setString('my_History', jsonString);
    } catch (e) {
      print('保存失败: $e');
      return false;
    }
  }
  Future<List<Map<String,String>>>getHistory()async{

    try {
      final prefs = await SharedPreferences.getInstance();

      // 从SharedPreferences获取JSON字符串
      String? jsonString = prefs.getString('my_History');

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      // 将JSON字符串转换为List<dynamic>
      List<dynamic> jsonList = jsonDecode(jsonString);

      // 转换为List<Map<String, String>>
      List<Map<String,String>> result = jsonList.map((item) => Map<String, String>.from(item)).toList();
      logger.d("取History"+result.toString());
      return result;
    } catch (e) {
      print('读取失败: $e');
      return [];
    }
  }

}