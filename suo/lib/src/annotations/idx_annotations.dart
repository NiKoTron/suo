import 'package:meta/meta.dart';

class IdxDocument {
  const IdxDocument();
}

class IdxID {
  const IdxID();
}

class IdxIndex {
  final String name;
  const IdxIndex({@required this.name}) : assert(name != null);
}
