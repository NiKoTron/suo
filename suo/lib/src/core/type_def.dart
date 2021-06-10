import 'dart:typed_data';

import 'index.dart';

typedef Deserialise<T> = T? Function(Uint8List string);
typedef Serialise<T> = Uint8List Function(T data);
typedef IndexedFactory<T> = IndexedEntity<T, String> Function(T entity);
