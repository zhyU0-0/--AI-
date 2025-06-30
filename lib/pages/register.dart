
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:summer_assessment/model/DataBase.dart';

// 发送邮箱验证码
int SendWaitTime = 10;

var logger = Logger();


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _LandState();
}

class _LandState extends State<Register> {
  TextEditingController pass_word = new TextEditingController();
  TextEditingController user_name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController code = new TextEditingController();
  TextEditingController image = new TextEditingController();
  bool is_success = false;
  bool is_send = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image.text = "0";
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
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start,
                    children: [BackButton(onPressed: (){Get.back();},)],),
                  Container(width: double.infinity,height: 300,
                    child: Image.asset("images/logo.png"),//logo
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: (){
                        var a = int.parse(image.text);
                        if(a>0){
                          a--;
                        }else{
                          a = 5;
                        }
                        setState(() {
                          image.text = a.toString();
                        });
                      }, icon: Icon(Icons.arrow_back)),
                      Container(
                        width: 80,
                        height: 80,
                        child: ClipOval(
                          child:Image.asset(image.text == "0"?"images/user/0.png":"images/user/"+image.text+".jpg")
                        )
                      ),
                      IconButton(onPressed: (){
                        var a = int.parse(image.text);
                        if(a<5){
                          a++;
                        }else{
                          a = 0;
                        }
                        setState(() {
                          image.text = a.toString();
                        });
                      }, icon: Icon(Icons.arrow_forward)),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.only(left: 20,right: 20),
                    height: 40,
                    width: double.infinity,
                    child: TextField(controller: user_name,
                      decoration: InputDecoration(
                          label: Text("userName".tr),
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
                  Container(
                    padding: EdgeInsets.only(left: 20,right: 20),
                    height: 40,
                    width: double.infinity,
                    child: TextField(controller: email,
                      decoration: InputDecoration(
                          label: Text("email".tr),
                          border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(onPressed: (){
                        if(user_name.text.isNotEmpty&&email.text.isNotEmpty&&pass_word.text.isNotEmpty){
                          insert_user();
                        }else{
                          Get.snackbar("请输入信息", "请输入信息");
                        }
                      }, child: Text("register".tr),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(160, 50),
                          side: BorderSide(
                            color: Color(0xFF728873),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF728873),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
        )
    );
  }

  insert_user()async{

    int a = await DatabaseService.instance.insertUser(
        user_name.text,
        pass_word.text,
        image.text,
        email.text
    );
    if(a == -1){
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Color(0xff935757),
        message: "用户名已存在",
        duration: Duration(seconds: 1),
      ));
    }else{
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Colors.green,
        message: "注册成功",
        duration: Duration(seconds: 1),
      ));
      Get.back();
    }

  }
}

