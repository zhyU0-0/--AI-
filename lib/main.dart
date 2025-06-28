import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as language;
import 'package:summer_assessment/pages/Tab/AIChat.dart';
import 'package:summer_assessment/pages/Tab/Questions.dart';
import 'package:summer_assessment/pages/Tab/User.dart';
import 'package:summer_assessment/pages/land.dart';
import 'package:summer_assessment/routers/routers.dart';

void main() {
  runApp(const MyApp());
}
var logger = Logger();
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    defaultTransition: Transition.rightToLeftWithFade,
    getPages: AppPage.routers,
      home: Land(),
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
      body: Center(
        child: Pages[selectedNum]
      ),
      bottomNavigationBar: BottomNavigationBar(

          fixedColor: Color(0xFF539EAF),
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
