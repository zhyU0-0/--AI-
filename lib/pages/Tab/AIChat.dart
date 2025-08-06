import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summer_assessment/model/DataBase.dart';
import '../../Presenter/TranslateAudio.dart';
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
  String _result = 'audio'.tr;
  int style = 0;
  GlobalKey<_Chat_ListState> chatKey = new GlobalKey<_Chat_ListState>();
  Color audio_color = Color(0xFF728873);
  Color send_color = Color(0xFF728873);

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
        audio_color = Color(0xFF728873);
        _result = '识别中'.tr;
      });
    } else {
      setState(() {
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
    if(question.text.isNotEmpty){
      setState(() {
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
        });
        logger.d("new chat history::"+History.toString());
      });
      sendMessage();
    }else{
      Get.showSnackbar(GetSnackBar(
        title: "请输入问题",
        backgroundColor: Colors.green,
        message: "请输入问题",
        duration: Duration(seconds: 2),
      ));
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
                    ElevatedButton(
                        onPressed: (){clean();},
                        child: Text("new chat".tr),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(100, double.infinity), // 设置固定尺寸
                        side: BorderSide(
                          color: Color(0xFF728873),      // 边框颜色
                          width: 1.5,             // 边框宽度
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // 圆角
                        ),
                        elevation: 4,             // 阴影高度
                        backgroundColor: Colors.white, // 背景色
                        foregroundColor: Color(0xFF728873),   // 文字颜色
                      ),
                    )
                  ],),),
              Expanded(child: Chat_List(
                key: chatKey,
                History: History,
              )),
              Container(width: double.infinity,height: 2,color: Color(0xFF637864),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text("normal".tr),
                      Checkbox(value: style == 0, onChanged: (r){
                        setState(() {
                          style = 0;
                        });
                      },
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFF728873);
                              }
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.white;
                              }
                              return Colors.white;
                            },
                          )
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("cold".tr),
                      Checkbox(value: style == 1, onChanged: (r){
                        setState(() {
                          style = 1;
                        });
                      },
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color(0xFF728873);
                            }
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.white;
                            }
                            return Colors.white;
                          },
                        )
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("enthusiasm".tr),
                      Checkbox(value: style == 2, onChanged: (r){
                        setState(() {
                          style = 2;
                        });
                      },
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFF728873);
                              }
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.white;
                              }
                              return Colors.white;
                            },
                          )
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("earnest".tr),
                      Checkbox(value: style == 3, onChanged: (r){
                        setState(() {
                          style = 3;
                        });
                      },
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFF728873);
                              }
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.white;
                              }
                              return Colors.white;
                            },
                          )
                      )
                    ],
                  ),
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
                      if(!_isRecording){
                        _startRecording();
                      }
                    },
                    onTapUp: (TapUpDetails details)=>{
                      if(_isRecording){
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
                    child: const Icon(Icons.send, size: 20,color: Color(0xFFE8E6E0)),
                  ),
                ],
              ),
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
          })
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
              decoration: BoxDecoration(
                color: Color(0xA55B8060),
                borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              width: (chatHistory[index]["content"]!.length)*30<200?
              (chatHistory[index]["content"]!.length)*30 : 200,
              child: Text(chatHistory[index]["content"].toString(),style: TextStyle(
                fontSize: 15
              ),),
            ),
            SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Container(
                height:30, width: 30,
                child:Image.asset("images/221.png")
              )],
            )
          ]:[
            Container(
              height:chatHistory[index]['content']!.length*2+0.1>80?chatHistory[index]['content']!.length*2+15.1:80,
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                          alignment: Alignment.topCenter,
                          width: 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Container(
                                height:30, width: 30,
                                child:Image.asset("images/robot.png")
                            )],
                          )
                      ),
                    ],
                  ),
                  SizedBox(width: 10,),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:Color(0x5EAEAEAE),
                    ),
                    padding: EdgeInsets.only(left: 10,right: 10),
                    width: 230,
                    child: Column(
                      children: [
                        Expanded(child: Container(
                          alignment: Alignment.centerLeft,
                          child:Markdown(
                            data: formatText(chatHistory[index]["content"].toString()),
                            // 可以自定义样式
                            styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              // 其他样式设置...
                            ),
                            // 处理链接点击
                            onTapLink: (text, href, title) {
                              if (href != null) {
                                // 在这里处理链接点击事件，例如使用url_launcher打开链接
                                print('点击了链接: $href');
                              }
                            },
                          )/*Text(chatHistory[index]["content"].toString())*//*RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 16),
                                children: parseMarkdownText(formatText(chatHistory[index]["content"].toString())),
                              )
                          )*/
                        ),),
                      ],
                    ),
                  ),

                ],
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
    // 先将连续的多个换行符（比如 \n\n 等）替换为单个换行符，再去掉可能多余的首尾换行
    return originalText
        .replaceAll(r'\n', '\n');    // 将 "\n" 转换为实际换行符
  }
  /*String formatText(String originalText) {
    // 先将连续的多个换行符（比如 \n\n 等）替换为单个换行符，再去掉可能多余的首尾换行
    return originalText
        .replaceAll(r'\n', '\n')    // 将 "\n" 转换为实际换行符
        .replaceAll(r'\\n', r'\n'); // 处理可能的双反斜杠转义
  }
  List<TextSpan> parseMarkdownText(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');

    int start = 0;
    for (Match match in boldRegex.allMatches(text)) {
      // 添加普通文本
      spans.add(TextSpan(
        text: text.substring(start, match.start),
        style: TextStyle(
            color: Colors.black
        )
      ));

      // 添加加粗文本
      spans.add(TextSpan(
        text: match.group(1)!,
        style: TextStyle(
            fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ));

      start = match.end;
    }

    // 添加剩余文本
    if (start < text.length) {
      spans.add(TextSpan(
          text: text.substring(start),
        style: TextStyle(
            color: Colors.black
        )
      ));
    }

    return spans;
  }*/
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



