import 'index.dart';

typedef Deserialise<T> = T Function(String string);
typedef Serialise<T> = String Function(T data);
typedef IndexedFactory<T> = IndexedEntity<T, String> Function(T entity);
