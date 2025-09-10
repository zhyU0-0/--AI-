import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/main.dart';
import 'package:summer_assessment/View/edit_question.dart';
import '../../Presenter/photo_service.dart';
import '../../model/DataBase.dart';

class Questions extends StatefulWidget {
  const Questions({super.key});

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  List<Map<String, dynamic>> _photos = [];
  TextEditingController description = TextEditingController();
  int _type = 0;
  String username = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      _loadQuestion();
    });
    logger.d("is init");
  }

  Future<void> _loadQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    username = (await prefs.getString("user_name")).toString();
    final photos = await DatabaseService.instance.getAllQuestion(username);
    setState(() {
      _photos = photos;
    });
  }

  Future<void> _addQuestion() async {
    final pickedFile = await PhotoStorageService.pickImage();
    if (pickedFile != null) {
      // 保存图片到本地存储
      final savedPath = await PhotoStorageService.saveImageToAppDir(pickedFile);

      // 保存记录到数据库
      await DatabaseService.instance.insertQuestion({
        'title': '图片 ${_photos.length + 1}',
        'file_path': savedPath,
        'created_at': DateTime.now().toIso8601String(),
        "description":description.text,
        "type":_type.toString(),
        "name":username
      });

      _loadQuestion(); // 刷新列表
    }
  }

  Future<void> _showDeleteDialog(BuildContext context,Map<String, dynamic> photo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext stateContext, StateSetter setState) {
              return AlertDialog(
                title: Column(
                  children: [
                    Text("是否删除？")
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(onPressed: () {
                        Navigator.of(context).pop();
                      },child: Text('cancel'.tr)),
                      ElevatedButton(onPressed: () {
                        _deletePhoto(
                            photo['id'],
                            photo['file_path']);
                        Navigator.of(context).pop();
                      },child: Text('delete'.tr,style: TextStyle(
                        color: Colors.red
                      ),))
                    ],
                  )

                ],
              );
            }
        );
      },
    );
  }

  Future<void> _showInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext stateContext, StateSetter setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                // 动态获取键盘高度，设置底部内边距
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    width: 200,
                    height: 400,
                    child: Column(
                      children: [
                        Text('please input information'.tr),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text("选择题目类型",style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13
                                ),),

                                IconButton(onPressed: () {
                                  if (_type > 0) {
                                    setState(() {
                                      _type--;
                                    });
                                  } else {
                                    setState(() {
                                      _type = 3;
                                    });
                                  }
                                  logger.d(_type);
                                }, icon: Icon(Icons.arrow_back)),

                                Text(
                                  _type == 0 ? "simple".tr : _type == 1 ? "common".tr : _type == 2
                                      ? "difficult".tr
                                      : "very difficult".tr,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: _type == 0 ? Colors.green : _type == 1
                                          ? Colors.blue
                                          : _type == 2 ? Colors.orange : Colors.red
                                  ),),
                                IconButton(onPressed: () {
                                  if (_type < 3) {
                                    setState(() {
                                      _type++;
                                    });
                                  } else {
                                    setState(() {
                                      _type = 0;
                                    });
                                  }
                                  logger.d(_type);
                                }, icon: Icon(Icons.arrow_forward)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 200,
                          height: 300,
                          //padding: EdgeInsets.only(left: 0,right: 20),
                          child: TextField(
                            controller: description,
                            decoration: InputDecoration(
                                label: Text("description".tr)
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('cancel'.tr),
                ),
                TextButton(
                  onPressed: () {
                    _addQuestion();
                    Navigator.of(context).pop();
                  },
                  child: Text('add'.tr),
                ),
              ],
            );
          }
        );
      },
    );
  }
  Future<void> _deletePhoto(int id, String filePath) async {

    await DatabaseService.instance.deleteQuestion(id);

    await PhotoStorageService.deleteImageFile(filePath);

    _loadQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFE8E6E0),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8E6E0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text('Correction Notebook'.tr),
          IconButton(onPressed: (){
            Get.toNamed("/Chart");
          }, icon: Icon(Icons.bar_chart,
          color: Color(0xFF637864),))
        ],),
      ),
      body: Column(
        children: [
          
          _photos.isEmpty
              ? Center(child: Text('暂无错题，请添加'))
              : Expanded(child: ListView.builder(
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return QuestionCard(
                delete: (){
                  _showDeleteDialog(context, photo);
                },
                photo: photo,
                load: _loadQuestion,
              );
            },
          )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.add,color:Color(0xFF637864)),
        onPressed: (){
          _showInputDialog(context);
        },
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  VoidCallback load;
  VoidCallback delete;
  Map<String,dynamic> photo;
  QuestionCard({super.key,required this.delete,required this.photo,required this.load});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        height: 100,
        width: 350,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2
          ),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child:GestureDetector(

                  child: Row(
                    children: [
                      Image.file(
                        File(widget.photo['file_path']),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10), // 添加间距

                      // 使用 Expanded 限制文本区域宽度
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                          children: [
                            Text(
                              (widget.photo['created_at']).toString().split("T")[0],
                              style: TextStyle(color:Color(0xFF637864)),
                            ),
                            Text(
                              widget.photo['description'],
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder:(context)=> EditQuestionPage(photo: widget.photo,load: widget.load,)
                    ));
                  },
                )
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: widget.delete,
              color: Color(0xFF637864),
            )
          ],
        ),
      ),
    );
  }
}
