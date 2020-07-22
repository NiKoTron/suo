import 'package:suo/src/core/core.dart';

mixin SuoDocumetMixin<T> {
  Deserialise<T> deserialiser;
  Serialise<T> serialiser;
  IndexedFactory<T> indexedFactory;

  IndexedEntity<T, String> indexedEntityOfThis() {
    assert(this is T);
    return indexedFactory(this as T);
  }
}
