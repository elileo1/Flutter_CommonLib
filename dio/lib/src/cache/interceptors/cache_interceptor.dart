import 'package:dio/src/cache/interceptors/cache_mgr.dart';
import 'package:dio/src/cache/interceptors/response_control.dart';
import 'package:dio/src/dio_error.dart';
import 'package:dio/src/interceptor.dart';
import 'package:dio/src/options.dart';
import 'package:dio/src/response.dart';

import 'cache_control.dart';

///create by elileo on 2019/5/22
class CacheInterceptor extends Interceptor{
  Cache _cache;

  CacheInterceptor(){
    _cache = new Cache();
  }

  @override
  onRequest(RequestOptions options) async {
    if("get" == options.method.toLowerCase() && options.cacheControl == CacheControl.CACHE_AND_NETWORK){
      String result = await _cache.getCache(options);
      if(result != null){
        return result;
      }
      return options;
    }
    return options;
  }

  @override
  onResponse(Response response) async{
    await _cache.addCache(response);
    response.responseFrom = ResponseFrom.FROM_NETWORK;
    return response;
  }

  @override
  onError(DioError err) {
    return err;
  }
}