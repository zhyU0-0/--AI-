import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:summer_assessment/main.dart';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'translate_tools/onesentence_plugin.dart';

class VoiceRecognizer {
  final OneSentenceASRController _controller = OneSentenceASRController();

  Future<String?> recognize(
      String audioBase64) async {
    try {
      final Uint8List audioData = base64Decode(audioBase64);

      final params = OneSentenceASRParams()

        ..data = audioBase64.toString()
      ..eng_serice_type = "8k_zh"; // 设置音频数据

      final result = await _controller.recognize(params);
      if (result.error == null || result.error.toString().isEmpty) {

        return result.error.toString().isNotEmpty ? result.result : "未识别到有效内容";

      } else {

        return "识别失败：${result.result.toString()+" || "+result.response_body}（错误码：${result.error}）";
      }
    } catch (e) {

      logger.e("识别异常：${e.toString()}");
      return "识别异常：${e.toString()}";
    }
  }

  void dispose() {

  }
}

//听写识别
class AudioTranslate {
  String APPID = "393d198f";
  String APIKey = "3c08f86da9aff97dbcd50f77e3978784"; // 替换为你的API Key
  String APISecret = "NTkzOTdmOTZhNDgxYzFiOGIyYmFmNGQx"; // 替换为你的API Secret
  String Audio = ''; // 你的音频数据（base64编码）
  // 生成RFC1123格式的时间戳
  // 状态常量
  static const int STATUS_FIRST_FRAME = 0;
  static const int STATUS_CONTINUE_FRAME = 1;
  static const int STATUS_LAST_FRAME = 2;

  Map<String, dynamic> get _commonArgs => {"app_id": APPID};

  Map<String, dynamic> get _businessArgs => {
    "domain": "iat",
    "language": "zh_cn",
    "accent": "mandarin",
    "vinfo": 1,
    "vad_eos": 10000
  };

  Future<String> _createUrl() async {
    final host = "iat-api.xfyun.cn";
    final path = "/v2/iat";
    final now = DateTime.now().toUtc();
    final date = _generateRFC1123Date();

    final signatureOrigin = "host: $host\ndate: $date\nGET $path HTTP/1.1";
    final hmacSha256 = Hmac(sha256, utf8.encode(APISecret));
    final signatureSha = base64.encode(hmacSha256.convert(utf8.encode(signatureOrigin)).bytes);

    final authorizationOrigin =
        'api_key="$APIKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signatureSha"';
    final authorization = base64.encode(utf8.encode(authorizationOrigin));

    final params = {
      "authorization": authorization,
      "date": date,
      "host": host
    };

    final queryString = Uri(queryParameters: params).query;
    return "wss://$host$path?$queryString";
  }

  // 转换日期格式
  String _generateRFC1123Date() {
    final now = DateTime.now().toUtc();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]}, '
        '${now.day.toString().padLeft(2, '0')} '
        '${months[now.month - 1]} '
        '${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')} GMT';
  }
  Future<void> playBase64Audio(String base64Audio) async {
    final player = AudioPlayer();

    try {

      final bytes = base64.decode(base64Audio);

      await player.play(BytesSource(bytes));
    } catch (e) {
      print('播放音频时出错: $e');
      rethrow;
    }
  }

  Future<String> recognize() async {

    var str = await VoiceRecognizer().recognize(Audio);
    logger.d("recognize:: ${str}");
    return str.toString();
  }

  //分帧
  Future<void> _sendAudioData(WebSocketChannel channel) async {
    const frameSize = 8000; // 帧大小
    const interval = Duration(milliseconds: 40); // 间隔

    final audioBytes = base64.decode(Audio);
    int status = STATUS_FIRST_FRAME;
    await playBase64Audio(Audio);
    for (var i = 0; i < audioBytes.length; i += frameSize) {
      final end = min(i + frameSize, audioBytes.length);
      final frame = audioBytes.sublist(i, end);
      print(i);
      final data = {
        if (status == STATUS_FIRST_FRAME) "common": _commonArgs,
        if (status == STATUS_FIRST_FRAME) "business": _businessArgs,
        "data": {
          "status": status,
          "format": "audio/L16;rate=16000",
          "audio": base64.encode(frame),
          "encoding": "raw"
        }
      };
      channel.sink.add(json.encode(data));

      if (status == STATUS_FIRST_FRAME) {
        status = STATUS_CONTINUE_FRAME;
      }

      await Future.delayed(interval);
    }

    channel.sink.add(json.encode({
      "data": {
        "status": STATUS_LAST_FRAME,
        "format": "audio/L16;rate=16000",
        "audio": "",
        "encoding": "raw"
      }
    }));
  }
}


//获取音频
class AudioRecorder {
  final Record _record = Record();
  int Audio_length = 0;
  Future<bool> _checkPermissions() async {
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      await Permission.microphone.request();
    }
    return micStatus.isGranted;
  }

  Future<String?> startRecording() async {
    if (!await _checkPermissions()) return null;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/recording.wav';  // 保存为WAV格式

    await _record.start(
      path: path,
      encoder: AudioEncoder.wav,
      bitRate: 128000,
      samplingRate: 8000,
    );

    return path;
  }

  Future<String?> stopAndGetBase64() async {
    final path = await _record.stop();
    if (path == null) return null;

    final file = File(path);
    final bytes = await file.readAsBytes();
    Audio_length = bytes.length;
    return base64Encode(bytes);  // 转换为Base64
  }

  void dispose() {
    _record.dispose();
  }
}


