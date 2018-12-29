import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class NetUtil {
  static String _tag = "NetUtil-";

  ///get请求方式
  static int get = 1;

  ///post请求方式
  static int post = 2;

  ///upload 上传文件
  static int upload = 3;

  ///下载文件
  static int download = 4;

  ///请求方式
  int method;

  ///请求的URl
  String baseUrl;

  ///url模块名
  String path = "";

  ///Get参数
  Map<String, String> getPrams;

  ///Post参数
  Map<String, String> postPrams;

  ///公共参数
  Map<String, String> commonPrams = {};

  ///可以通过FormData实现上传数据
  ///例如 FormData formData = new FormData.from({"file":new UploadFileInfo(new File(""), "name.txt")});
  FormData formData;

  ///连接的超时时间
  int connectTimeout = 5000;

  ///接收的超时时间
  int receiveTimeout = 5000;

  Dio _dio;

  NetUtil() {
    if (_dio == null) {
      _dio = new Dio();
    }
  }

  ///发起请求
  call({onResponse(Response value),OnDownloadProgress value}) async {
    _dioConfig();
    _handlePrams();
    _addRequestInterceptor();
    _addResponseInterceptor();
    _addHttpsVerification();
    await _realRequest(value: value).then(onResponse);
  }

  ///真正请求部分
  Future<Response> _realRequest({OnDownloadProgress value}) async {
    if (method == get) {
      return await _dio.get(path, data: getPrams);
    } else if (method == post) {
      return await _dio.post(path, data: postPrams);
    } else if (method == upload) {
      return await _dio.post(path, data: formData);
    } else if (method == download){
      return await _dio.download(path, "",onProgress:value);
    }
  }

  ///处理请求参数
  void _handlePrams() {
    if (method == get) {
      Map<String, String> prams;
      if (getPrams == null) {
        if (commonPrams != null) {
          prams = commonPrams;
        }
      } else {
        if (commonPrams != null) {
          prams = getPrams;
          prams.addAll(commonPrams);
        } else {
          prams = getPrams;
        }
      }
      getPrams = prams;
    } else if (method == post || method == upload) {
      if (commonPrams != null) {
        path += "?";
        commonPrams.forEach((key, value) {
          path += "$key=$value&";
        });
      }
    }
  }

  ///Dio配置参数
  void _dioConfig() {
    if (baseUrl == null) {
      throw new NullThrownError();
    }

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = connectTimeout;
    _dio.options.receiveTimeout = receiveTimeout;
    _dio.options.responseType = ResponseType.JSON;
    ///_dio.cookieJar = new PersistCookieJar("./cookies");
    _dio.options.contentType =
        ContentType.parse("application/x-www-form-urlencoded");
    _dio.options.headers = {};
  }

  ///添加请求拦截器
  void _addRequestInterceptor() {
    _dio.interceptor.request.onSend = (Options options) {
      print("${_tag}BaseUrl:${options.baseUrl}");
      print("${_tag}path:${options.path}");
      print("${_tag}method:${options.method}");
      print("${_tag}data:${options.data}");
      return options;
    };
  }

  ///添加回复拦截器
  void _addResponseInterceptor() {
    _dio.interceptor.response.onSuccess = (Response response) {
      print("${_tag}Success data:${response.data}");
      return response;
    };
    _dio.interceptor.response.onError = (DioError e) {
      print("${_tag}Failture message:${e.message}");
      return e;
    };
  }

  ///添加Https证书验证
  void _addHttpsVerification() {
    String PEM = "";
    _dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        print("${_tag}cert.pem = ${cert.pem}");
        if (cert.pem == PEM) {
          return true;
        }
        return false;
      };
    };
  }
}
