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

/// 语音识别工具类
/// 支持传入Base64字符串格式的音频数据，返回识别结果
class VoiceRecognizer {
  final OneSentenceASRController _controller = OneSentenceASRController();

  /// 语音识别方法
  /// [audioBase64]：Base64编码的音频字符串
  /// [appId]：腾讯云AppId
  /// [secretId]：腾讯云SecretId
  /// [secretKey]：腾讯云SecretKey
  /// [token]：可选，临时鉴权token
  /// [engineType]：引擎类型，默认16k中文
  /// 返回识别结果字符串
  Future<String?> recognize(
      String audioBase64) async {
    try {
      // 1. 将Base64字符串解码为音频二进制数据
      final Uint8List audioData = base64Decode(audioBase64);

      // 2. 配置识别参数
      final params = OneSentenceASRParams()
        //..appid = int.parse(appId)
        //..secretid = secretId
        //..secretkey = secretKey
        //..token = token
        //..engine_type = engineType
        ..data = audioBase64.toString()
      ..eng_serice_type = "8k_zh"; // 设置音频数据
      // 3. 调用识别接口
      final result = await _controller.recognize(params);

      // 4. 处理识别结果
      if (result.error == null || result.error.toString().isEmpty) {
        // 识别成功，返回识别文本
        return result.error.toString().isNotEmpty ? result.result : "未识别到有效内容";

      } else {
        // 识别失败，返回错误信息
        return "识别失败：${result.result.toString()+" || "+result.response_body}（错误码：${result.error}）";
      }
    } catch (e) {
      // 捕获异常
      logger.e("识别异常：${e.toString()}");
      return "识别异常：${e.toString()}";
    }
  }

  /// 释放资源
  void dispose() {
    // 可根据插件实际需求添加资源释放逻辑
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

  // 公共参数
  Map<String, dynamic> get _commonArgs => {"app_id": APPID};

  // 业务参数
  Map<String, dynamic> get _businessArgs => {
    "domain": "iat",
    "language": "zh_cn",
    "accent": "mandarin",
    "vinfo": 1,
    "vad_eos": 10000
  };

  // 生成鉴权URL
  Future<String> _createUrl() async {
    final host = "iat-api.xfyun.cn";
    final path = "/v2/iat";
    final now = DateTime.now().toUtc();
    final date = _generateRFC1123Date();

    // 生成签名
    final signatureOrigin = "host: $host\ndate: $date\nGET $path HTTP/1.1";
    final hmacSha256 = Hmac(sha256, utf8.encode(APISecret));
    final signatureSha = base64.encode(hmacSha256.convert(utf8.encode(signatureOrigin)).bytes);

    final authorizationOrigin =
        'api_key="$APIKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signatureSha"';
    final authorization = base64.encode(utf8.encode(authorizationOrigin));

    // 构建URL参数
    final params = {
      "authorization": authorization,
      "date": date,
      "host": host
    };
    /*var _params = OneSentenceASRParams();
    _params.binary_data = Uint8List.View((await rootBundle.load("assets/30s.wav")).buffer);
    _params.voice_format = OneSentenceASRParams.FORMAT_WAV;*/
    /*final params = OneSentenceASRParams();
    _params.appid = 123456; // 你的腾讯云 AppId（从腾讯云控制台获取）
    params.secretid = "your_secretid"; // 你的腾讯云 SecretId
    params.secretkey = "your_secretkey"; // 你的腾讯云 SecretKey
    params.engine_type = OneSentenceASRParams.ENGINE_16K_ZH; // 引擎模型（例如16k中文）
    params.voice_format = OneSentenceASRParams.FORMAT_WAV; // 音频格式*/
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
      // 将 Base64 字符串转换为字节数据
      final bytes = base64.decode(base64Audio);

      // 使用字节数据播放音频
      await player.play(BytesSource(bytes));
    } catch (e) {
      print('播放音频时出错: $e');
      rethrow; // 可选：向上传播错误
    }
  }
  // 执行语音识别
  Future<String> recognize() async {

    var str = await VoiceRecognizer().recognize(Audio);
    logger.d("recognize:: ${str}");
    return str.toString();
    /*final completer = Completer<String>();
    final resultBuffer = StringBuffer();

    try {
      final wsUrl = await _createUrl();
      print(wsUrl);
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      channel.stream.listen(
            (message) {
          try {
            final jsonMsg = json.decode(message);
            if (jsonMsg['code'] != 0) {
              completer.completeError("识别错误: ${jsonMsg['message']}");
            } else {
              jsonMsg['data']['result']['ws'].forEach((item) {
                item['cw'].forEach((w) => resultBuffer.write(w['w']));
                print(resultBuffer.toString());
              });
            }
          } catch (e) {
            completer.completeError("消息解析失败: $e");
          }
        },
        onError: (error) => completer.completeError("WebSocket错误: $error"),
        onDone: () => completer.complete(resultBuffer.toString()),
      );

      await _sendAudioData(channel);

      channel.sink.close();

    } catch (e) {
      completer.completeError("连接建立失败: $e");
    }

    return completer.future;*/
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


