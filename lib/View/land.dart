
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:summer_assessment/model/DataBase.dart';


var logger = Logger();

class Land extends StatefulWidget {
  const Land({super.key});

  @override
  State<Land> createState() => _LandState();
}

class _LandState extends State<Land> {
  TextEditingController pass_word = new TextEditingController();
  TextEditingController user_name = new TextEditingController();
  bool is_auth = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   init();
  }
  init()async{

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
                      label: Text("username".tr),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("自动登录"),
                    Checkbox(value: is_auth, onChanged: (bool? value) {
                      setState(() {
                        is_auth = !is_auth;
                      });
                    },
                      fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Color(0xFF728873);
                        }
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.white;
                        }
                        return Colors.white;
                      },
                    ),
                    ),
                    SizedBox(width: 30,)
                  ],
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
    //var username = await prefs.getString("user_name");
    var password = await DatabaseService.instance.getPassword(user_name.text);
    logger.d(password + pass_word.text);
    if(password == pass_word.text){
      if(is_auth){
        prefs.setBool("is_land", true);
      }
      prefs.setString("user_name", user_name.text);
      Get.showSnackbar(GetSnackBar(
        message:"登陆成功,登陆成功",
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ));
      Get.toNamed("/home");
    }else {
      Get.showSnackbar(GetSnackBar(
          message:"登陆失败，或密码错误",
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ));
    }
  }

}
//politeness