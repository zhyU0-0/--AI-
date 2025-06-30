import 'dart:io';

import 'package:flutter/material.dart';

import '../Presenter/QuestionEditor.dart';
import '../main.dart';

class EditQuestionPage extends StatefulWidget {
  VoidCallback load;
  Map<String,dynamic> photo;
  EditQuestionPage({super.key,required this.photo,required this.load});

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();

}

class _EditQuestionPageState extends State<EditQuestionPage> {
  TextEditingController description = new TextEditingController();
  QuestionEditor QE = new QuestionEditor();
  int _type = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    description.text = widget.photo["description"];
    _type = int.parse(widget.photo["type"]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("错题详情"),
      ),
      body: Padding(padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  (widget.photo['created_at']).toString().split("T")[0],
                  style: TextStyle(color: Color(0xFF595959)),
                ),
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Image.file(
                      File(widget.photo['file_path']),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context)=>Photo(path: widget.photo['file_path'])
                          )
                      );
                    },
                  )
                  
                ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  _type == 0 ? "简单" : _type == 1 ? "普通" : _type == 2
                      ? "困难"
                      : "恶梦",
                  style: TextStyle(
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
            Row(
              children: [
                SizedBox(width: 50,),
                Expanded(child: TextField(
                  controller: description,
                  maxLines: null,
                ),),
                SizedBox(width: 50,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: ()async{
                  await QE.save(widget.photo["id"], widget.photo["name"], description.text, _type);
                  widget.load();
                }, child: Text("保存"))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Photo extends StatelessWidget {
  String path;
  Photo({super.key,required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(
            File(path),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
