import 'package:suo/src/core/core.dart';

mixin SuoDocumetMixin<T> {
  late Deserialise<T> deserialiser;
  late Serialise<T> serialiser;
  late IndexedFactory<T> indexedFactory;

  IndexedEntity<T, String> indexedEntityOfThis() {
    assert(this is T);
    return indexedFactory(this as T);
  }
}
