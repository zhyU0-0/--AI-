import 'package:flutter/material.dart';
import 'package:summer_assessment/main.dart';

import '../../AIrequest/TranslateAudio.dart';

class VoiceRecognitionPage extends StatefulWidget {
  @override
  _VoiceRecognitionPageState createState() => _VoiceRecognitionPageState();
}

class _VoiceRecognitionPageState extends State<VoiceRecognitionPage> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioTranslate _translator = AudioTranslate();
  bool _isRecording = false;
  String _result = '';

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _result = '';
    });
    await _recorder.startRecording();
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    logger.d("111");
    // 获取Base64编码的音频数据
    final base64Audio = await _recorder.stopAndGetBase64();
    logger.d("222");
    if (base64Audio != null) {
      // 设置音频数据并发送
      logger.d("333");
      _translator.Audio = base64Audio;
      logger.d(_translator.Audio);
      //////await _translator.sendAudio();
      logger.d("444");
      // 注意：这里需要根据讯飞API的实际返回结果更新UI
      // 示例中只是简单显示成功消息
      setState(() {
        _result = '音频已发送，等待识别结果...';
      });
    } else {
      setState(() {
        _result = '录音失败';
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('语音识别示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text('开始录音'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text('停止并识别'),
            ),
            ElevatedButton(onPressed:() async {
              try {
                final result = await _translator.recognize();

                setState(() {
                  _result = '识别结果: $result';
                });
                print('识别结果: $result');
              } catch (e) {
                print('识别失败: $e');
              }
            }, child: Text("发送"))
          ],
        ),
      ),
    );
  }
}