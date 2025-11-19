

import 'package:get/get.dart';

import '../main.dart';
import '../View/chart_page.dart';
import '../View/detail.dart';
import '../View/land.dart';
import '../View/register.dart';

class AppPage{
  static final routers = [
    GetPage(name: "/home", page: () => MyHomePage()),
    GetPage(name: "/land", page: () => Login()),
    GetPage(name: "/register", page: () => Register()),
    GetPage(name: "/DetailPage", page: () => DetailPage()),
    GetPage(name: "/Chart", page: () => ChartPage()),
  ];
}