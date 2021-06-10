import 'core/document.dart';
import 'doc_storage.dart';

/// The main class for woring with suo.
class Suo {
  static final _instances = <String, Suo>{};

  final _basePath;

  Suo._(this._basePath);

  /// Creates a storage by following path and returns instance
  /// if storage already exists by this path returns instance
  factory Suo.create(String basePath) {
    if (!_instances.containsKey(basePath)) {
      _instances[basePath] = Suo._(basePath);
    }
    return _instances[basePath]!;
  }

  final _storages = <String, DocStorage>{};

  /// Register document type into suo storage
  /// It means that suo will be know which sereialiser use to store
  /// and which indeicies should be calculated for entities
  void register<D>(SuoDocumetMixin<D?> doc) {
    final typeS = D.toString().toLowerCase();
    if (!_storages.containsKey(typeS)) {
      _storages[typeS] = DocStorage<D>('$_basePath/$typeS',
          deSerialiser: doc.deserialiser,
          seriaiser: doc.serialiser,
          indexedFactory: doc.indexedFactory);
    }
  }

  DocStorage<D?>? _getStorage<D>(String key) {
    if (!_storages.containsKey(key)) {
      return null;
    }
    return _storages[key] as DocStorage<D?>?;
  }

  /// Saves document into storage
  void save<D>(D document) {
    final storage = _getStorage(D.toString().toLowerCase());
    storage?.save(document);
  }

  /// Find and takes a document by primary id
  /// if document not founded returns `null`
  D? getById<D>(String id) {
    final storage = _getStorage(D.toString().toLowerCase());
    if (storage != null) {
      return storage.getById(id);
    }
    return null;
  }

  /// Returns list of objects with type passed in generic
  /// can limits count of returning objects by passing `limit` arg.
  List<D?> getBy<D>({int? limit}) {
    final key = D.toString().toLowerCase();
    if (_storages.containsKey(key)) {
      final storage = _storages[key]!;
      return storage.getAll(limit) as List<D?>;
    }
    return [];
  }
}
