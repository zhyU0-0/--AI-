import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/model/DataBase.dart';

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
      backgroundColor: Color(0xFFE8E6E0),
        body:Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10,right: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 50,),
                        UserLanding(),
                        SizedBox(height: 30,),
                        dataShow(),

                      ],
                    ),
                    Container(
                        height: 400,
                        child: ListView(
                      children: [
                        ListTile(
                          title: Column(
                            children: [
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  Get.toNamed("/Chart");
                                }, child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text("data".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
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
                                }, child:Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text("language".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
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
                                }, child:Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text("关于"),ImageIcon(AssetImage("images/icons/goto.png"))],),
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
                              /*SizedBox(height: 5,),
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
                              ),*/
                              SizedBox(height: 5,),
                              Container(
                                child: ElevatedButton(onPressed: (){
                                  _showInputDialog(context);
                                }, child:Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text("exit".tr),ImageIcon(AssetImage("images/icons/goto.png"))],),
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
    init();

  }
  init()async{
    /*final prefs = await SharedPreferences.getInstance();
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
    logger.d("image::"+image+user_name);*/
    final prefs = await SharedPreferences.getInstance();
    var a = (await prefs.getBool("is_land"))??false;
    var _image = "";
    var _user_name = await prefs.getString("user_name")??"";
    final userList = await DatabaseService.instance.getAllUser();
    logger.d(userList);
    for(var a in userList){
      if(_user_name == a["name"]){
        _image = a["image"];
        logger.d(_image);
      }
    }
    setState(() {
      is_landing = a;
      image = _image;
      user_name = _user_name;
    });
    logger.d(image);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 120,
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8,),
                      Container(
                        alignment: Alignment.center,
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80)
                        ),
                        child:ClipOval(
                          child: image != ''?(image == "0"?Image.asset("images/user/0.png"):Image.asset("images/user/$image.jpg")):Image.asset("images/user/1.jpg"),
                        ),
                      )
                    ],
                  ),

                  Row(
                    children: [
                      Text("userName".tr+":",style: TextStyle(fontSize: 1)),
                      Text(user_name,style: TextStyle(fontSize: 20))
                    ],
                  ),

                  IconButton(onPressed: (){
                    Get.toNamed("/DetailPage",arguments: "6");
                  }, icon: Icon(Icons.settings,color: Color(0xFF637864),))
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

class dataShow extends StatefulWidget {
  const dataShow({super.key});

  @override
  State<dataShow> createState() => _dataShowState();
}

class _dataShowState extends State<dataShow> {

  int data = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  init()async{
    final p = await SharedPreferences.getInstance();
    var n = p.getString("user_name");
    var v = await DatabaseService.instance.getAllQuestion(n.toString());
    setState(() {
      data = v.length;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 130,
      child:Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("错题数据",style: TextStyle(
                              fontSize: 25
                          ),)
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("总共添加错题数量：",style: TextStyle(color: Color(0xFF637864)),),
                          Text(data.toString(),style: TextStyle(
                              fontSize: 30,
                              color: Color(0xFF637864)),),
                          SizedBox(width: 1,)
                        ],
                      )
                    ],
                  )
              ),
              IconButton(onPressed: (){
                Get.toNamed("/Chart");
              }, icon: Icon(Icons.pie_chart,color: Color(0xFF637864)))
            ],
          ),
          SizedBox(height: 20,),
          Container(
            color: Color(0xFF637864),
            width: 350,
            height: 2,
          )
        ],
      ),
    );
  }
}
