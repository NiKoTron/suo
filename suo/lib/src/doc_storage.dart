import 'dart:collection';
import 'dart:io';
import 'package:meta/meta.dart';

import 'package:path/path.dart';
import 'core/core.dart';

class DocStorage<D> {
  final Directory _dir;
  final Deserialise<D> _deSerialiser;
  final Serialise<D> _serialiser;
  final Cipher _cipher;
  final IndexedFactory<D> _indexedFactory;

  final Map<String, Map<String, Set<String>>> _indices = {};
  final LFUCache<String, D> _cache = LFUCache(150);
  final Set<String> _dbeFileLinks = <String>{};

  Directory _iDir;

  int get cacheCapacity => _cache.capacity;
  int get cacheLength => _cache.values.length;

  DocStorage(String dirPath,
      {@required Deserialise<D> deSerialiser,
      @required Serialise<D> seriaiser,
      @required IndexedFactory<D> indexedFactory,
      Cipher cipher = const _BypassCipher()})
      : assert(dirPath != null && dirPath.isNotEmpty),
        assert(deSerialiser != null),
        assert(seriaiser != null),
        assert(indexedFactory != null),
        _dir = Directory(dirPath),
        _deSerialiser = deSerialiser,
        _serialiser = seriaiser,
        _indexedFactory = indexedFactory,
        _cipher = cipher {
    _iDir = Directory('$dirPath/index');
    if (!_iDir.existsSync()) {
      _iDir.createSync(recursive: true);
    }
    _init();
  }

  void _init() {
    _restoreFromPersist();
    _dumpIndecies();
  }

  void _restoreFromPersist() {
    _dbeFileLinks.clear();
    _dir.listSync(recursive: false).forEach((f) {
      final ext = extension(f.path);
      if (ext == '.dbe') {
        final entity = _readFromFile(f);
        _dbeFileLinks.add(entity.id);
        _addToIndecies(entity);
        _cache.put(entity.id, entity.value);
      }
    });
  }

  void loadIndecies() {
    _iDir.listSync(recursive: false).forEach((f) {
      final ext = extension(f.path);
      if (ext == '.idx') {
        final ics = loadIndexFile(f);
        final iKey = basenameWithoutExtension(f.path);
        _indices[iKey] = ics;
      }
    });
  }

  Map<String, Set<String>> loadIndexFile(File f) {
    final map = <String, Set<String>>{};
    f.readAsLinesSync().forEach((ln) {
      final line = _decrypt(ln);
      final vls = line.split(':');
      assert(vls.length == 2);
      final valueHash = vls[0].trim();
      final links = vls[1].split(',').map((e) => e.trim()).toSet();
      map[valueHash] = links;
    });
    return map;
  }

  void _dumpIndecies() {
    _indices.forEach((key, value) {
      final f = File('${_iDir.path}/$key.idx');

      final sb = StringBuffer();
      value
          .forEach((vh, lSet) => sb.writeln(_encrypt('$vh:${lSet.join(",")}')));

      f.writeAsStringSync(sb.toString());
    });
  }

  void save(D item) {
    final entity = _indexedFactory(item);

    _cache.put(entity.id, entity.value);

    _addToIndecies(entity);

    final f = File('${_dir.path}/${entity.id}.dbe');

    f.writeAsStringSync(_encrypt(_serialiser(entity.value)));

    _rebuildDbeLinks();
    _dumpIndecies();
  }

  void _addToIndecies(IndexedEntity<D, String> entity) {
    entity.indices.entries.forEach((e) {
      if (e.value != null) {
        if (!_indices.containsKey(e.key)) {
          _indices[e.key] = {};
        }
        if (!_indices[e.key].containsKey(e.value)) {
          _indices[e.key][e.value] = LinkedHashSet.of([entity.id]);
        } else if (!_indices[e.key][e.value].contains(entity.id)) {
          _indices[e.key][e.value].add(entity.id);
        }
      }
    });
  }

  IndexedEntity<D, String> _readFromFile(File f) =>
      _indexedFactory(_deSerialiser(_decrypt(f.readAsStringSync())));

  D getById(String id) {
    if (_cache.values.containsKey(id)) {
      return _cache.get(id);
    }
    final f = File('${_dir.path}/$id.dbe');
    if (f.existsSync()) {
      final entity = _readFromFile(f);
      //TODO: Maybe storing in memcache also should be ciphered. think about it.
      _cache.put(entity.id, entity.value);
      return entity.value;
    }
    return null;
  }

  List<D> getByIndex(String indexName, String indexValue) {
    if (_indices.containsKey(indexName) &&
        _indices[indexName].containsKey(indexValue)) {
      final resolvedIndices = _indices[indexName][indexValue];
      return resolvedIndices.map((i) => getById(i)).toList();
    }
    return [];
  }

  List<D> getAll([int limit]) {
    final iterable = _dbeFileLinks.take(
        (limit == null || _dbeFileLinks.length <= limit)
            ? _dbeFileLinks.length
            : limit);
    return iterable.map((e) => getById(e)).toList();
  }

  void _rebuildDbeLinks() {
    _dbeFileLinks.clear();
    _dir.listSync(recursive: false).forEach((f) {
      final ext = extension(f.path);
      if (ext == '.dbe') {
        _dbeFileLinks.add(basenameWithoutExtension(f.path));
      }
    });
  }

  void remove(String index) {
    final item = _cache.get(index);
    if (item != null) {
      final entity = _indexedFactory(item);
      entity.indices.entries.forEach((e) {
        if (e.value != null) {
          if (_indices.containsKey(e.key) &&
              _indices[e.key].containsKey(e.value)) {
            _indices[e.key][e.value].remove(index);

            if (_indices[e.key][e.value].isEmpty) {
              _indices[e.key].removeWhere((k, _) => k == e.value);
            }
            if (_indices[e.key].isEmpty) {
              _indices.removeWhere((k, _) => k == e.key);
            }
          }
        }
      });
    }

    final f = File('${_dir.path}/${index}.dbe');
    if (f.existsSync()) {
      f.deleteSync(recursive: true);
    }
    _dumpIndecies();
  }

  String _decrypt(String input) {
    try {
      return _cipher.decrypt(input);
    } catch (e, s) {
      throw CipherException(
          'Unable to decrypt a data. See parent exception for detatils', e);
    }
  }

  String _encrypt(String input) {
    try {
      return _cipher.encrypt(input);
    } catch (e, s) {
      throw CipherException(
          'Unable to encrypt a data. See parent exception for detatils', e);
    }
  }
}

class _BypassCipher implements Cipher {
  const _BypassCipher();

  @override
  String decrypt(String data) => data;

  @override
  String encrypt(String data) => data;
}
