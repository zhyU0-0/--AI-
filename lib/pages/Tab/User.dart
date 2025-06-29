import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';


class User_page extends StatefulWidget {
  const User_page({super.key});

  @override
  State<User_page> createState() => _User_pageState();
}

class _User_pageState extends State<User_page> {
  bool is_show_data = false;
  bool is_show_language = false;
  bool is_show_IP = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10,right: 0),
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    UserLanding(),
                    Expanded(child: ListView(
                      children: [
                        ListTile(
                          title: Column(
                            children: [
                              SizedBox(height: 20,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  Get.toNamed("/DetailPage",arguments: "5");
                                }, child:Row(children: [Text("lank".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 60), // 设置固定尺寸
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
                              ),
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  Get.toNamed("/DetailPage",arguments: "1");
                                }, child: Row(children: [Text("data".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 60), // 设置固定尺寸
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
                              ),
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  Get.toNamed("/DetailPage",arguments: "2");
                                }, child:Row(children: [Text("language".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 60), // 设置固定尺寸
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
                              ),
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  Get.toNamed("/DetailPage",arguments: "6");
                                }, child:Row(children: [Text("updatePassword".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 60), // 设置固定尺寸
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
                              ),
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  Get.toNamed("/DetailPage",arguments: "4");
                                }, child:Row(children: [Text("关于"),ImageIcon(AssetImage("images/icons/goto.png"))],),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 60), // 设置固定尺寸
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
                              ),
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  Get.toNamed("/DetailPage",arguments: "3");
                                }, child:Row(children: [Text("ipAddress".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 60), // 设置固定尺寸
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
                              ),
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  _showInputDialog(context);
                                }, child:Row(children: [Text("exit".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 60), // 设置固定尺寸
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
                              ),

                            ],
                          ),
                        )
                      ],
                    )
                    )
                  ],
                ),
              ),
            ]
        )
    );
  }
  Future<void> _showInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                exit();
                Navigator.of(context).pop();

                Get.toNamed("/land");
              },
              child: Text('确认'),
            ),
          ],
        );
      },
    );
  }
  exit()async{
    final prefs = await SharedPreferences.getInstance();
   await prefs.setBool("is_land",false);
    await prefs.setString("user_email",'');
    await prefs.setBool("is_auth",false);
  }
}
class UserLanding extends StatefulWidget {

  UserLanding({super.key});

  @override
  State<UserLanding> createState() => _UserLandingState();
}

class _UserLandingState extends State<UserLanding> {

  String user_name = '';
  String image = '';
  String email = '';
  bool is_landing = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //init();
  }
  init()async{
    final prefs = await SharedPreferences.getInstance();
    var a = (await prefs.getBool("is_land"))??false;
    email = await prefs.getString("user_email")??"";
    var ip = await prefs.getString("ip")??"";
    setState(() {
      is_landing = a;
    });
    logger.d("ip ::: "+ip+"  "+email);
    final response = await http.get(
        Uri.parse("${ip}/get_user_by_email?email=${email}"),
        headers:{'Content-Type': 'application/json'},
    );
    logger.d(response.body);
    final decodedData = utf8.decode(response.bodyBytes);
    final jsonMap = json.decode(decodedData) as Map<String, dynamic>;
    final message = jsonMap['message'] as List<dynamic>;
    setState(() {
      image = message[4] == "0" ? message[4] + ".png":message[4] + ".jpg" ;
      user_name = message[1].toString();
    });
    logger.d("image::"+image+user_name);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius:BorderRadius.circular(10),
          border:Border.all(
              color: Color(0xFF728873),
              width: 2,
              style: BorderStyle.solid
          )
      ),
      child: Column(
        children: [
          if(is_landing)
            GestureDetector(
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80)
                    ),
                    child:ClipOval(
                      child: image != ''?Image.asset("images/user/$image"):Image.asset("images/user/1.jpg"),
                    ),
                  ),

                  Row(
                    children: [
                      Text("用户名："),
                      Text(user_name,style: TextStyle(fontSize: 30))
                    ],
                  ),
                ],
              ),
              onTap: (){
              },
            ),
          if(!is_landing)
            Container(
              width: 350,
              height: 80,
              child:GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("未登录",style: TextStyle(fontSize: 40,color: Colors.green),)
                  ],
                ),
                onTap: (){
                  Get.offNamed("/land");
                },
              ),
            )
        ],
      ),
    );
  }
}
