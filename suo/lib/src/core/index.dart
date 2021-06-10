/// Represents named computable index
class Index<V, I> {
  /// Name of index
  final String name;

  /// The function acording to which one index will compute
  final I Function(V) indexFunction;

  const Index(this.name, this.indexFunction);
}

/// Wrapper for entity with indexng possibility
class IndexedEntity<V, I> {
  final V value;
  final I Function(V) _idFunction;

  I get id => _idFunction(value);

  final List<Index<V, I>>? _indices;

  Map<String, I> get indices =>
      {for (var e in _indices!) e.name: e.indexFunction(value)};

  const IndexedEntity(this.value, this._idFunction, [this._indices]);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(dynamic other) => value == (other.value);
}
