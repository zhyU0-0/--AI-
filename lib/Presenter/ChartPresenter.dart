import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/model/DataBase.dart';

import '../pages/ChartPage.dart';

class ChartPresenter{

  Map<String,double>summary = {
    "0":0,
    "1":0,
    "2":0,
    "3":0,
    "ava0":0,
    "ava1":0,
    "ava2":0,
    "ava3":0,
  };
  ChartPresenter(){
    init();
  }

  init()async{
    final p = await SharedPreferences.getInstance();
    String username = (p.getString("user_name")).toString();

    List<Map<String,dynamic>> data = await DatabaseService.instance.getAllQuestion(username);
    for(var a in data){
      switch(a["type"]){
        case "0":
          summary["0"] = 1 + summary["0"]!;
          break;
        case "1":
          summary["1"] = 1 + summary["1"]!;
          break;
        case "2":
          summary["2"] = 1 + summary["2"]!;
          break;
        case "3":
          summary["3"] = 1 + summary["3"]!;
          break;
      }
    }
  }

  Future<List<PieData>> getPieData()async{

    double all = summary["0"]! + summary["1"]! + summary["2"]! + summary["3"]!;
    if(all != 0){
      summary["ava0"] = double.parse((summary["0"]!/all*100).toStringAsFixed(2));
      summary["ava1"] = double.parse((summary["1"]!/all*100).toStringAsFixed(2));
      summary["ava2"] = double.parse((summary["2"]!/all*100).toStringAsFixed(2));
      summary["ava3"] = double.parse((summary["3"]!/all*100).toStringAsFixed(2));

      return [
        PieData('simple'.tr, summary["ava0"]!, Colors.green),
        PieData('common'.tr, summary["ava1"]!, Colors.blue),
        PieData('difficult'.tr, summary["ava2"]!, Colors.orange),
        PieData('very difficult'.tr, summary["ava3"]!, Colors.red),

      ];
    }else{
      return [
        PieData('A', 25, Colors.blue),
        PieData('B', 25, Colors.red),
        PieData('C', 25, Colors.green),
        PieData('D', 25, Colors.amber),
      ];
    }
  }
  Future<List<Map<String,dynamic>>>getBarData() async {
    List<Map<String,dynamic>> barData = [];
    barData = [
      {'类型': 'simple'.tr, 'sales': summary["0"]},
      {'类型': 'common'.tr, 'sales': summary["1"]},
      {'类型': 'difficult'.tr, 'sales': summary["2"]},
      {'类型': 'very difficult'.tr, 'sales': summary["3"]},
    ];
    return barData;
  }

  Future<List<Map<String,dynamic>>>getLineData() async {
    DateTime now = DateTime.now();
    DateTime now_1 = now.subtract(Duration(days: 1));
    DateTime now_2 = now.subtract(Duration(days: 2));
    DateTime now_3 = now.subtract(Duration(days: 3));
    DateTime now_4 = now.subtract(Duration(days: 4));
    DateTime now_5 = now.subtract(Duration(days: 5));
    DateTime now_6 = now.subtract(Duration(days: 6));
    List<double> data_everday = [0,0,0,0,0,0,0];
    final p = await SharedPreferences.getInstance();
    String username = (p.getString("user_name")).toString();

    List<Map<String,dynamic>> data = await DatabaseService.instance.getAllQuestion(username);
    for(var a in data){
      if(a['created_at'].split('T')[0] == now.toString().split(' ')[0]){
        data_everday[0] += 1;
      }
      if(a['created_at'].split('T')[0] == now_1.toString().split(' ')[0]){
        data_everday[1] += 1;
      }
      if(a['created_at'].split('T')[0] == now_2.toString().split(' ')[0]){
        data_everday[2] += 1;
      }
      if(a['created_at'].split('T')[0] == now_3.toString().split(' ')[0]){
        data_everday[3] += 1;
      }
      if(a['created_at'].split('T')[0] == now_4.toString().split(' ')[0]){
        data_everday[4] += 1;
      }
      if(a['created_at'].split('T')[0] == now_5.toString().split(' ')[0]){
        data_everday[5] += 1;
      }
      if(a['created_at'].split('T')[0] == now_6.toString().split(' ')[0]){
        data_everday[6] += 1;
      }
    }

    List<Map<String,dynamic>> lineData = [];
    lineData = [
      {
        '类型': now_6.toString().split(' ')[0].split("-")[1]+"-"+now_6.toString().split(' ')[0].split("-")[2],
        'sales': data_everday[6]
      },
      {
        '类型': now_5.toString().split(' ')[0].split("-")[1]+"-"+now_5.toString().split(' ')[0].split("-")[2],
        'sales': data_everday[5]
      },
      {
        '类型': now_4.toString().split(' ')[0].split("-")[1]+"-"+now_4.toString().split(' ')[0].split("-")[2],
        'sales': data_everday[4]
      },
      {
        '类型': now_3.toString().split(' ')[0].split("-")[1]+"-"+now_3.toString().split(' ')[0].split("-")[2],
        'sales': data_everday[3]
      },
      {
        '类型': now_2.toString().split(' ')[0].split("-")[1]+"-"+now_2.toString().split(' ')[0].split("-")[2],
        'sales': data_everday[2]
      },
      {
        '类型': now_1.toString().split(' ')[0].split("-")[1]+"-"+now_1.toString().split(' ')[0].split("-")[2],
        'sales': data_everday[1]
      },
      {
        '类型': now.toString().split(' ')[0].split("-")[1]+"-"+now.toString().split(' ')[0].split("-")[2],
        'sales': data_everday[0]
      },
    ];
    return lineData;
  }
}