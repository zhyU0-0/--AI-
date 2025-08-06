import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/model/DataBase.dart';
import '../main.dart';

class AIService{
  static String Api_key = '';
  static String Api_Url = 'https://api.deepseek.com/v1';
  static String chat_api = '/chat/completions';
  List<Map<String,String>> message_history = [];
  AIService(){
    //String o_str = "{\"id\":\"ea274062-cca8-428d-b069-fd65c07b5343\",\"object\":\"chat.completion\",\"created\":1754359388,\"model\":\"deepseek-chat\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":\"```c\n#include <stdio.h>\n\nint main() {\n    printf(\"你会\\n\");\n    return 0;\n}\n```\"},\"logprobs\":null,\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":14,\"completion_tokens\":25,\"total_tokens\":39,\"prompt_tokens_details\":{\"cached_tokens},\"prompt_cache_hit_tokens\":0,\"prompt_cache_miss_tokens\":14},\"system_fingerprint\":\"fp_8802369eaa_prod0623_fp8_kvcache\"}";
    init();
    const apiKey = String.fromEnvironment('ARK_API_KEY');
    logger.d('API Key: $apiKey');
    Api_key = apiKey;
    logger.d('API Key: $Api_key');
  }
  init()async{
    String? apiKey = Platform.environment['ARK_API_KEY'];
    print(apiKey);

  }
  Future<String> getChatCompletion(String prompt, int id, int style) async {
    try {
      // 添加用户的新消息到对话历史
      message_history = await getHistory(id);
      message_history.add({
        'role': 'user',
        'content': getStyle(style)+prompt
      });
      logger.d(message_history);
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
        RegExp exp = RegExp("\"content\":\"(.*?)\"},\"");
        var result = exp.firstMatch(decodedBody);
        logger.d(result!.group(0).toString());
        var real_result = result!.group(0).toString().split("\":\"")[1].split("\"},")[0];
        logger.d("解析后：："+real_result);
        final data = jsonDecode(response.body);
        final assistantReply = data['choices'][0]['message']['content'];
        message_history.removeLast();
        message_history.add({
          'role': 'user',
          'content': prompt
        });
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

  getStyle(int style){
    switch(style){
      case 0:
        return "用正常的风格回答问题：";
      case 1:
        return "用冷漠的风格回答问题：";
      case 2:
        return "用热情的风格回答问题：";
      case 3:
        return "用认真的风格回答问题：";
      default:
        return "";
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

/*
{"id":"73d174f2-b88f-41f4-878f-7084fcccc19e",
"object":"chat.completion","created":1754358970,
"model":"deepseek-chat",
"choices":[
{"index":0,"message":
{"role":"assistant",
"content":
"```c\n#include <stdio.h>\n\nint main() {\n    int a, b;\n    scanf(\"%d%d\", &a, &b);\n    printf(\"%d\\n\", a + b);\n    return 0;\n}\n```\n\n程序功能：输入两个整数，输出它们的和。"},"logprobs":null,"finish_reason":"stop"}],"usage":{"prompt_tokens":324,"completion_tokens":58,"total_tokens":382,"prompt_tokens_details":{"cached_tokens":192},"prompt_cache_hit_tokens":192,"prompt_cache_miss_tokens":132},"system_fingerprint":"fp_8802369eaa_prod0623_fp8_kvcache"}*/
//{"id":"ea274062-cca8-428d-b069-fd65c07b5343","object":"chat.completion","created":1754359388,"model":"deepseek-chat","choices":[{"index":0,"message":{"role":"assistant","content":"```c\n#include <stdio.h>\n\nint main() {\n    printf(\"你会\\n\");\n    return 0;\n}\n```"},"logprobs":null,"finish_reason":"stop"}],"usage":{"prompt_tokens":14,"completion_tokens":25,"total_tokens":39,"prompt_tokens_details":{"cached_tokens":0},"prompt_cache_hit_tokens":0,"prompt_cache_miss_tokens":14},"system_fingerprint":"fp_8802369eaa_prod0623_fp8_kvcache"}