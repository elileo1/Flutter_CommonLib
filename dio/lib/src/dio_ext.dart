///create by elileo on 2015/5/22
import 'package:dio/dio.dart';

import 'cache/interceptors/cache_control.dart';
import 'cache/interceptors/cache_interceptor.dart';
import 'cache/interceptors/response_control.dart';

class DioExt{
  static const String GET = "get";
  static const String POST = "post";
  static BaseOptions _options = new BaseOptions(connectTimeout: 5000, receiveTimeout: 5000);
  static Dio _dio = new Dio(_options);

  static init(){
    _dio.interceptors.add(new CacheInterceptor());
  }

  static Future<Null> get(String url, Function callBack, {Map<String, Object> params, Function errorCallBack, CacheControl cacheControl}) async{
    await _request(url, callBack,
        method: GET, params: params, errorCallBack: errorCallBack, cacheControl: cacheControl);
  }

  static Future<Null> post(String url, Function callBack, {Map<String, Object> params, Function errorCallBack}) async{
    await _request(url, callBack, method: POST, params: params, errorCallBack: errorCallBack);
  }

  static Future<Null> _request(String url, Function callBack, {String method, Map<String, Object> params, Function errorCallBack,CacheControl cacheControl}) async{
    String errorMsg = "";
    int statusCode;
    try{
      Response response;
      if(method == GET){
        if(params != null && params.isNotEmpty){
          StringBuffer sb = new StringBuffer("?");
          params.forEach((key, value){
            sb.write("$key" + "=" + "$value" + "&");
          });
          String paramStr = sb.toString();
          paramStr = paramStr.substring(0, paramStr.length - 1);
          url += paramStr;
        }
        response = await _dio.get(url, cacheControl: cacheControl);
      }else{
        if (params != null && params.isNotEmpty) {
          response = await _dio.post(url, data: params);
        } else {
          response = await _dio.post(url);
        }
      }
      if(response.responseFrom == ResponseFrom.FROM_NETWORK){
        statusCode = response.statusCode;
        //处理错误部分
        if (statusCode != 200) {
          errorMsg = statusCode.toString();
          _handError(errorCallBack, errorMsg);
          return;
        }
      }

      if (callBack != null) {
        callBack(response.data, response.responseFrom == ResponseFrom.FROM_NETWORK);
      }
      if(method == GET && cacheControl != null && cacheControl == CacheControl.CACHE_AND_NETWORK && response.responseFrom == ResponseFrom.FROM_CACHE){
        response = await _dio.get(url, cacheControl: CacheControl.NETWORK_REFRESH_CACHE);
        if(response != null && response.statusCode == 200 && callBack != null){
          callBack(response.data, response.responseFrom == ResponseFrom.FROM_NETWORK);
        }
      }
    }catch(exception){
      _handError(errorCallBack, exception.toString());
    }
  }

  static void _handError(Function errorCallBack, String errorMsg){
    if(errorCallBack != null){
      errorCallBack(errorMsg);
    }
  }
}