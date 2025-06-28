

import 'package:get/get.dart';

import '../main.dart';
import '../pages/Detail.dart';
import '../pages/land.dart';
import '../pages/register.dart';

class AppPage{
  static final routers = [
    GetPage(name: "/home", page: () => MyHomePage()),
    GetPage(name: "/land", page: () => Land()),
    GetPage(name: "/register", page: () => Register()),
    GetPage(name: "/DetailPage", page: () => DetailPage()),
  ];
}