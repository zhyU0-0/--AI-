
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// 发送邮箱验证码
int SendWaitTime = 10;

var logger = Logger();


class Land extends StatefulWidget {
  const Land({super.key});

  @override
  State<Land> createState() => _LandState();
}

class _LandState extends State<Land> {
  TextEditingController pass_word = new TextEditingController();
  TextEditingController user_name = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.all(10),
          child:SizedBox(
            width: 400,
            height: double.infinity,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start,
                children: [BackButton(onPressed: (){Get.back();},)],),
                Container(width: double.infinity,height: 300,
                child: Image.asset("images/logo.png"),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.only(left: 20,right: 20),
                  height: 40,
                  width: double.infinity,
                  child: TextField(controller: user_name,
                  decoration: InputDecoration(
                      label: Text("email".tr),
                      border: OutlineInputBorder()
                  ),
                ),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.only(left: 20,right: 20),
                  height: 40,
                  width: double.infinity,
                  child: TextField(controller: pass_word,
                  decoration: InputDecoration(
                      label: Text("password".tr),
                      border: OutlineInputBorder()
                  ),
                ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(onPressed: (){
                      if(pass_word.text.isNotEmpty&&user_name.text.isNotEmpty){
                        land();
                      }
                    }, child: Text("land".tr),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(220, double.infinity), // 设置固定尺寸
                        side: BorderSide(
                          color: Color(0xFF728873),      // 边框颜色
                          width: 1.5,             // 边框宽度
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 圆角
                        ),
                        elevation: 4,             // 阴影高度
                        backgroundColor: Colors.white, // 背景色
                        foregroundColor: Color(0xFF728873),   // 文字颜色
                      ),
                    ),
                    ElevatedButton(onPressed: (){Get.toNamed("/register");},
                      child: Text("register".tr),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(100, double.infinity), // 设置固定尺寸
                        side: BorderSide(
                          color: Color(0xFF728873),      // 边框颜色
                          width: 1.5,             // 边框宽度
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 圆角
                        ),
                        elevation: 4,             // 阴影高度
                        backgroundColor: Colors.white, // 背景色
                        foregroundColor: Color(0xFF728873),   // 文字颜色
                      ),),
                  ],
                )
              ],
            ),
          )
        )
      );
  }
  land()async{
    final prefs = await SharedPreferences.getInstance();

    var ip = prefs.getString("ip");
    logger.d(ip);
    final response = await http.post(
      Uri.parse('$ip/land'),
      body: jsonEncode({"email":user_name.text,'password':pass_word.text }),
      headers: {'Content-Type': 'application/json'},
    );
    logger.d(response.statusCode);
    if(response.statusCode == 200){
      prefs.setBool("is_land", true);
      prefs.setString("user_email", user_name.text);
      Get.snackbar("登陆成功", "登陆成功");
      Get.toNamed("/");
    }else {
      Get.snackbar("登陆失败", "邮箱或密码错误");
    }
  }

}
//politeness