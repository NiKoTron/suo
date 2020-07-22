import 'dart:async';
import 'dart:io';

import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'package:path/path.dart' as pth;

import 'package:watcher/watcher.dart' as watcher;

import 'core/core.dart';

class DirStorage {
  final Directory _dir;

  final Map<String, dynamic> _cache = {};

  final Map<String, StreamController<StorageEvent>> _listeners = {};

  final Map<String, Deserialise> _deSerialisers = {};
  final Map<String, Function> _serialisers = {};

  DirStorage(String dirPath) : _dir = Directory(dirPath) {
    if (!_dir.existsSync()) {
      _dir.createSync(recursive: true);
    }

    final w = watcher.Watcher(_dir.path);
    w.ready.then((_) {
      w.events.listen(_listening);
    });
  }

  Stream<T> keyChangingStream<T>(String key) {
    final kh = _keyHash(key);
    if (!_listeners.containsKey(kh) || _listeners[kh].isClosed) {
      _listeners[kh] = StreamController<StorageEvent<T>>.broadcast();
    }
    return _listeners[kh].stream.asBroadcastStream() as Stream<T>;
  }

  String _keyHash(String key) =>
      hex.encode(crypto.md5.convert(utf8.encode(key)).bytes);

  void _sync(String keyHash, dynamic value) {
    if (_cache.containsKey(keyHash)) {
      if (value == null) {
        _cache.remove(keyHash);
        if (_listeners.containsKey(keyHash)) {
          _listeners[keyHash].add(StorageEvent.removed());
        }
        return;
      }

      if (_cache[keyHash] == value) {
        return;
      }
    }

    if (value == null) {
      return;
    }

    if (_listeners.containsKey(keyHash) &&
        _deSerialisers.containsKey(keyHash)) {
      _cache[keyHash] = value;
      final e = StorageEvent.changed(_cache[keyHash]);
      _listeners[keyHash].sink.add(e);
    }
  }

  void _listening(watcher.WatchEvent event) {
    final hashedKey = pth.basenameWithoutExtension(event.path);
    switch (event.type) {
      case watcher.ChangeType.MODIFY:
        final file = File(event.path);
        final value = _deSerialisers[hashedKey](file.readAsStringSync());
        _sync(hashedKey, value);
        break;
      case watcher.ChangeType.REMOVE:
        _sync(hashedKey, null);
        break;
    }
  }

  void registerSerialisers<T>(String key,
      {Deserialise<T> deserialiser, Serialise<T> serialiser}) {
    final hashKey = _keyHash(key);
    _deSerialisers[hashKey] = deserialiser;
    _serialisers[hashKey] = serialiser;
  }

  void setKey<T>(String key, T value) {
    final hk = _keyHash(key);
    assert(_serialisers.containsKey(hk));

    final fp = '${_dir.path}/$hk.ks';
    final f = File(fp);
    if (!f.existsSync()) {
      f.createSync(recursive: true);
    }
    final serialiser = _serialisers[hk];
    final str = serialiser(value);
    f.writeAsStringSync(str);
    _sync(hk, value);
  }

  T getKey<T>(String key) {
    final hk = _keyHash(key);
    assert(_deSerialisers.containsKey(hk));

    final fp = '${_dir.path}/$hk.ks';
    final f = File(fp);
    //if(!_cache.containsKey(hk)){
    if (!f.existsSync()) {
      return null;
    }
    final deserialiser = _deSerialisers[hk];
    final value = deserialiser(f.readAsStringSync());
    _sync(hk, value);
    return value as T;
    // }
    // return _cache[hk] as T;
  }
}
