import 'dart:io';

import 'package:flutter/material.dart';

class EditQuestionPage extends StatefulWidget {
  Map<String,dynamic> photo;
  EditQuestionPage({super.key,required this.photo});

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();

}

class _EditQuestionPageState extends State<EditQuestionPage> {
  TextEditingController description = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    description.text = widget.photo["description"];
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
                  Image.file(
                    File(widget.photo['file_path']),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ]
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
              children: [
                ElevatedButton(onPressed: (){

                }, child: Text("保存"))
              ],
            )
          ],
        ),
      ),
    );
  }

}
