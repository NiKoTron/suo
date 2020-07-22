import 'core/document.dart';
import 'doc_storage.dart';

class Suo {
  static final _instances = <String, Suo>{};

  final _basePath;

  Suo._(this._basePath);

  factory Suo.create(String basePath) {
    if (!_instances.containsKey(basePath)) {
      _instances[basePath] = Suo._(basePath);
    }
    return _instances[basePath];
  }

  final _storages = <String, DocStorage>{};

  void register<D>(SuoDocumetMixin<D> doc) {
    final typeS = D.toString().toLowerCase();
    if (!_storages.containsKey(typeS)) {
      _storages[typeS] = DocStorage<D>('$_basePath/$typeS',
          deSerialiser: doc.deserialiser,
          seriaiser: doc.serialiser,
          indexedFactory: doc.indexedFactory);
    }
  }

  DocStorage<D> _getStorage<D>(String key) {
    if (!_storages.containsKey(key)) {
      return null;
    }
    return _storages[key];
  }

  void save<D>(D document) {
    final storage = _getStorage(D.toString().toLowerCase());
    storage?.save(document);
  }

  D getById<D>(String id) {
    final storage = _getStorage(D.toString().toLowerCase());
    if (storage != null) {
      return storage.getById(id);
    }
    return null;
  }

  List<D> getBy<D>({int limit}) {
    final key = D.toString().toLowerCase();
    if (_storages.containsKey(key)) {
      final storage = _storages[key];
      return storage.getAll(limit);
    }
    return [];
  }
}
