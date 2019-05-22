import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:io';

import 'package:dio/src/cache/disk_lru_cache.dart';
import 'package:dio/src/cache/interceptors/cache_control.dart';
import 'package:dio/src/options.dart';
import 'package:dio/src/response.dart';

///create by elileo on 2019/5/22
class Cache{
  DiskLruCache _diskLruCache;
  int maxSize = 10 * 1024 * 1024;

  Cache({int maxSize}){
    _diskLruCache = new DiskLruCache(
      maxSize: maxSize ?? this.maxSize,
      directory: new Directory("${Directory.systemTemp.path}/dioCache"),
      filesCount: 1
    );
  }

  addCache(Response response) async{
    if(response != null && response.request != null &&
        "get" == response.request.method.toLowerCase() &&
        response.request.cacheControl != CacheControl.ONLY_NETWORK){
      String url =  response.request.path;
      if(response.data is String){
        CacheEditor editor = await _diskLruCache.edit(generateMd5(url));
        if(editor != null){
          IOSink sink = await editor.newSink(0);
          sink.write(response.data);
          await sink.close();
          await editor.commit();
        }
      }
    }
  }

  getCache(RequestOptions request) async{
    if(request != null){
      CacheSnapshot snapshot =  await _diskLruCache.get(generateMd5(request.path));
      if(snapshot == null){
        return null;
      }
       return await snapshot.getString(0);
    }
    return null;
  }

  String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }
}