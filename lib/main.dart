import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/View/Tab/ai_chat.dart';
import 'package:summer_assessment/View/Tab/questions.dart';
import 'package:summer_assessment/View/Tab/user.dart';
import 'package:summer_assessment/View/land.dart';
import 'package:summer_assessment/routers/routers.dart';

import 'language/language.dart';



Future<void> main() async {

  runApp(const MyApp());
}
var logger = Logger();
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool landing = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  init()async{
    final prefs = await SharedPreferences.getInstance();
    var a = await prefs.getBool("is_land")??false;
    setState(() {
      landing = a;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      defaultTransition: Transition.rightToLeftWithFade,
      getPages: AppPage.routers,
      translations: Message(),
      locale: Locale("zh","CN"),
      fallbackLocale: Locale("en","US"),
      home: landing?MyHomePage():Land(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Widget>Pages = [];
  int selectedNum = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Pages = [AIChat_page(),Questions(),User_page()];

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE8E6E0),
      body: Center(
        child: Pages[selectedNum]
      ),
      bottomNavigationBar: BottomNavigationBar(

          fixedColor: Color(0xFF637864),
          unselectedItemColor: Colors.black12,
          currentIndex: selectedNum,
          onTap: (index){
            setState(() {
              selectedNum = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: "AI"),
            BottomNavigationBarItem(icon: Icon(Icons.question_answer_sharp),label: "错题"),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: "用户")
          ]),
    );
  }
}
