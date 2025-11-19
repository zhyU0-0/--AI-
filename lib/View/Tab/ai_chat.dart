import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/model/DataBase.dart';
import '../../Presenter/translate_audio.dart';
import '../../Presenter/request.dart';
import '../../main.dart';
int selectNum = 0;
AIService deepseek = new AIService();
List<String> node_l = ["1",'2'];
class AIChat_page extends StatefulWidget {
  const AIChat_page({super.key});
  @override
  State<AIChat_page> createState() => _AIChat_pageState();
}

class _AIChat_pageState extends State<AIChat_page> {
  TextEditingController question = new TextEditingController();
  bool is_waiting = false;
  List<Map<String,String>> History = [];
  bool is_show = false;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioTranslate _translator = AudioTranslate();
  bool _isRecording = false;
  bool _isRecognizing = false;
  bool _isRequseting = false;
  String _result = 'audio'.tr;
  int style = 0;
  GlobalKey<_Chat_ListState> chatKey = new GlobalKey<_Chat_ListState>();
  Color audio_color = Color(0xFF728873);
  Color send_color = Color(0xFF728873);

  double tap_x = 0;
  double tap_y = 0;
  bool is_update_style = false;
  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
    logger.d("is dispose   "+selectNum.toString());
  }
  dis()async{
    final prefs = await SharedPreferences.getInstance();
    var username = await prefs.getString("user_name");
    prefs.setInt(username.toString(), selectNum);
  }
  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _result = 'stop'.tr;
    });

    await _recorder.startRecording();
  }

  Future<void> _stopRecording() async {
    setState(() {
      audio_color = Colors.grey;
      _isRecognizing = true;
      _isRecording = false;
    });

    final base64Audio = await _recorder.stopAndGetBase64();

    if (base64Audio != null) {

      _translator.Audio = base64Audio;
      question.text = await _translator.recognize();

      if(question.text.isEmpty){
        Get.snackbar("Fail", "没听清捏，再说一编吧");
      }
      setState(() {
        _isRecognizing = false;
        audio_color = Color(0xFF728873);
        _result = '识别中'.tr;
      });
    } else {
      setState(() {
        _isRecognizing = false;
        _result = '录音失败'.tr;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  init()async{
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("user_name");

    if((await DatabaseService.instance.getAllHistory(username.toString())).length == 0){
      DatabaseService.instance.insertHistory(jsonEncode([]),username.toString(),"1");
    }

    selectNum = prefs.getInt(username.toString()) ?? 0 ;
    logger.d(selectNum.toString()+":::"+username.toString());

    deepseek.getHistory(selectNum).then((r){
      setState(() {
        History = r;
      });
      deepseek.message_history = r;
    });

    logger.d("is init   "+selectNum.toString());
  }
  chat()async{
    if(question.text.isNotEmpty && !_isRequseting){
      setState(() {
        _isRequseting = true;
        send_color = Colors.grey;
        is_waiting = true;
      });
      logger.d(question.text);
      await deepseek.getChatCompletion(question.text,selectNum,style);
      await deepseek.getHistory(selectNum).then((r){
        setState(() {
          question.text = '';
          History = r;
          is_waiting = false;
          _isRequseting = false;
        });
        logger.d("new chat history::"+History.toString());
      });
      sendMessage();
    }else{
      if(_isRequseting){
        Get.showSnackbar(GetSnackBar(
          title: "正在思考哦",
          backgroundColor: Colors.green,
          message: "正在思考哦~",
          duration: Duration(seconds: 2),
        ));
      }else{
        Get.showSnackbar(GetSnackBar(
          title: "请输入问题",
          backgroundColor: Colors.green,
          message: "请输入问题",
          duration: Duration(seconds: 2),
        ));
      }

    }
  }
  clean()async{
    logger.d("History.length   "+History.length.toString());
    final prefs = await SharedPreferences.getInstance();
    var username = await prefs.getString("user_name");
    if(History.length != 0){
      selectNum = (await DatabaseService.instance.getAllHistory(username.toString())).length;
    }
    await deepseek.clearConversation();
    await deepseek.getHistory(selectNum).then((r){
      setState(() {
        History = r;
      });
    });
    logger.d("clean history::"+selectNum.toString()+History.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 10,),
              Container(width: double.infinity,height: 50,
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: (){
                      setState(() {
                        is_show = true;
                      });
                    }, icon: Icon(Icons.table_rows,color: Color(0xFF637864))),
                    IconButton(onPressed: (){
                      setState(() {
                        clean();
                      });
                    }, icon: Icon(Icons.add,size: 30,color: Color(0xFF637864))),
                  ],),),
              Expanded(child: Chat_List(
                key: chatKey,
                History: History,
              )),
              Container(width: double.infinity,height: 2,color: Color(0xFF637864),),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPressStart: (details) {
                      logger.d("Down");
                      //_showInputDialog(context);
                      setState(() {
                        is_update_style = true;
                        tap_x = details.localPosition.dx;
                        tap_y = details.localPosition.dy;
                      });
                    },
                    onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                      logger.d("长按移动 - 当前位置: ${details.localPosition}");
                      // 更新移动过程中的坐标
                      if(details.localPosition.dy-tap_y>0&&details.localPosition.dx-tap_x>0){
                        setState(() {
                          style = 3;
                        });
                      }
                      else if(details.localPosition.dy-tap_y>0&&details.localPosition.dx-tap_x<0){
                        setState(() {
                          style = 2;
                        });
                      }
                      else if(details.localPosition.dy-tap_y<0&&details.localPosition.dx-tap_x>0){
                        setState(() {
                          style = 1;
                        });
                      }
                      else if(details.localPosition.dy-tap_y<0&&details.localPosition.dx-tap_x<0){
                        setState(() {
                          style = 0;
                        });
                      }
                      logger.d(details.localPosition.dy-tap_y);

                    },

                    onLongPressEnd: (details) {

                      logger.d("up");
                      setState(() {
                        is_update_style = false;
                      });
                      //Navigator.of(context).pop();
                    },
                    child:Padding(
                        padding: EdgeInsets.only(top: 2,bottom: 2,left: 10),
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        height: 25,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFF637864),
                            width: 2
                          )
                        ),
                        child:Padding(padding: EdgeInsets.only(left: 10,right: 10),
                        child: Text(
                            style: TextStyle(
                                color: Color(0xFF637864)
                            ),
                            style==0?"normal".tr:style==1?"cold".tr:style==2?"enthusiasm".tr:"earnest".tr
                        ),),
                      ),
                    ),
                  )

                ],
              ),
              Row(
                children: [Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: question,
                      textInputAction: TextInputAction.send,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "输入你的问题...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTapDown: (TapDownDetails details) async {
                      if(!_isRecording && !_isRecognizing){
                        _startRecording();
                      }
                    },
                    onTapUp: (TapUpDetails details)=>{
                      if(_isRecording && !_isRecognizing){
                        _stopRecording()
                      }
                    },
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: audio_color,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: const Icon(Icons.mic, size: 20,color: Color(0xFFE8E6E0),)),
                  ),
                  FloatingActionButton(
                    onPressed: chat,
                    backgroundColor: send_color,
                    mini: true,
                    child: _isRequseting?Container(
                      width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Color(0xFFE8E6E0),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF637864)), // 进度颜色
                    ),
                    ):Icon(Icons.send, size: 20,color: Color(0xFFE8E6E0)),
                  ),
                ],
              ),
              SizedBox(height: 5,)
            ],
          ),
        ),
        if(is_show)
          SelectPage( select: (){
            deepseek.getHistory(selectNum).then((r){
              setState(() {
                History = r;
                is_show = false;
              });
            });
          }),
        if(is_update_style)
          Container(
            color: Color(0x88000000),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 320,
                        height: 500,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SelectStyle(style: style, r_style: 0, content: "normal"),
                                SizedBox(width: 5,),
                                SelectStyle(style: style, r_style: 1, content: "cold"),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                SelectStyle(style: style, r_style: 2, content: "enthusiasm"),
                                SizedBox(width: 5,),
                                SelectStyle(style: style, r_style: 3, content: "earnest"),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )
          )

      ],
    );
  }
  sendMessage(){
    logger.d("is submit11");
    question.clear();
    chatKey.currentState?.sendMessage();
    setState(() {
      send_color = Color(0xFF728873);
    });
  }
}

class SelectStyle extends StatefulWidget {
  int style;
  int r_style;
  String content;
  SelectStyle({super.key,required this.style,required this.r_style,required this.content,});

  @override
  State<SelectStyle> createState() => _SelectStyleState();
}

class _SelectStyleState extends State<SelectStyle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      alignment: widget.r_style == 0?Alignment.bottomLeft:widget.r_style == 1?Alignment.bottomRight:widget.r_style == 2?Alignment.topLeft:Alignment.topRight,
      child: Row(
        mainAxisAlignment: widget.r_style%2 != 1?MainAxisAlignment.end:MainAxisAlignment.start,
        children: [
          // 使用AnimatedContainer替代Container
          AnimatedContainer(
            // 动画持续时间（毫秒）
            duration: Duration(milliseconds: 200),
            // 动画曲线（可选，默认是线性）
            curve: Curves.easeInOut,

            width: widget.style == widget.r_style ? 150 : 80,
            height: widget.style == widget.r_style ? 150 : 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: Color(0xFF728873),
                  width: widget.style == widget.r_style ? 8 : 2
              ),
            ),
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              // 文本样式变化的动画
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: widget.style == widget.r_style ? 25 : 15,
                color: Color(0xFF728873),
              ),
              child: Text(widget.content.tr),
            ),
          )
        ],
      ),
    );
  }
}


class Chat_List extends StatefulWidget {
  List<Map<String,String>> History;
  Chat_List({super.key,required this.History});

  @override
  State<Chat_List> createState() => _Chat_ListState();
}

class _Chat_ListState extends State<Chat_List> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String,String>> chatHistory = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  sendMessage(){
    logger.d("is submit22");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: chatHistory.length,
        itemBuilder: (BuildContext context,index){
      return ListTile(
        title:Row(
          mainAxisAlignment:chatHistory[index]["role"].toString()=="user"? MainAxisAlignment.end:MainAxisAlignment.start,
          children:chatHistory[index]["role"].toString() == "user"? [
            Container(
              constraints: BoxConstraints(
                maxWidth: 320, // 最宽宽度
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:Color(0xA55B8060),
              ),
              child: MarkdownBody(
                data: formatText(chatHistory[index]["content"].toString()),
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 10,),
          ]:[
            Container(
              constraints: BoxConstraints(
                maxWidth: 320, // 最宽宽度
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:Color(0x5EAEAEAE),
              ),
              child: MarkdownBody(
                data: formatText(chatHistory[index]["content"].toString()),
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
        );
    });
  }

  init()async{
    var a = await deepseek.getHistory(selectNum);
    setState(() {
      chatHistory = a;
    });
  }
  @override
  void didUpdateWidget(covariant Chat_List oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.History != oldWidget.History){
      setState(() {
        chatHistory = widget.History;
      });
    }
  }
  String formatText(String originalText) {
    return originalText
        .replaceAll(r'\n', '\n');
  }
}


class waiting extends StatefulWidget {
  const waiting({super.key});

  @override
  State<waiting> createState() => _waitingState();
}

class _waitingState extends State<waiting> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 创建一个动画控制器，设置动画时长为1秒
    _controller = AnimationController(
      duration: const Duration(seconds: 1,milliseconds: 500),
      vsync: this,
    );
    // 创建一个从0到2π的旋转动画
    _animation = Tween<double>(begin: 0, end: 2 * 3.1415926).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    // 启动动画并设置为无限循环
    _controller.repeat();
  }

  @override
  void dispose() {
    // 释放动画控制器资源
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class SelectPage extends StatefulWidget {
  VoidCallback select;
  SelectPage({super.key,required this.select});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  List<Map<String, dynamic>> hList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  init()async{
    final prefs = await SharedPreferences.getInstance();
    var username = await prefs.getString("user_name");
    List<Map<String, dynamic>> a = await DatabaseService.instance.getAllHistory(username.toString());
    setState(() {
      hList = a;
    });
    logger.d(a.length);
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          child: Container(
            width: 600,
            height: 800,
            color: Colors.black26,
          ),
          onTap: widget.select,
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white
              ),
              width: 200,
              child:Column(
                children: [
                  Expanded(child: ListView.builder(
                      itemCount: hList.length,
                      itemBuilder: (context,index){
                    return ListTile(
                      title: GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: 50,
                          decoration: BoxDecoration(
                            color: selectNum == index?Color(0xFF728873): Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: selectNum == index?0:2,
                                color: Colors.black26
                            )
                          ),
                          child:Row(
                            children: [
                              Expanded(child: Text(
                                getTitle(hList[index]),
                                maxLines: 1,           // 限制为单行
                                overflow: TextOverflow.ellipsis,
                              )
                              )

                            ],
                          ),
                        ),
                        onTap: (){
                          logger.d(":::"+selectNum.toString());
                          selectNum = index;
                          widget.select();
                        },
                      )
                    );
                  }))
                ],
              ),
            )
          ],
        )
      ],
    );
  }
  String getTitle(Map<String, dynamic> value){
    try{
      return (jsonDecode((value["history"]).toString()).map((item) => Map<String, String>.from(item)).toList())[0]["content"];
    }catch(e){
      return "新对话";
    }

  }
}



