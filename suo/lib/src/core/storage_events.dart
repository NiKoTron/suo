enum StorageEventType { changed, removed, added }

class StorageEvent<T> {
  final StorageEventType type;
  final T? data;

  StorageEvent._(this.type, {this.data});

  factory StorageEvent.removed() => StorageEvent._(StorageEventType.removed);

  factory StorageEvent.changed(T data) =>
      StorageEvent._(StorageEventType.changed, data: data);

  factory StorageEvent.added(T data) =>
      StorageEvent._(StorageEventType.added, data: data);

  R? when<R>({
    R Function(T data)? changed,
    R Function()? removed,
    R Function(T data)? added,
  }) {
    final value = data;
    if (value != null) {
      switch (type) {
        case StorageEventType.changed:
          if (changed != null) {
            return changed(value);
          }
          return null;
        case StorageEventType.removed:
          if (removed != null) {
            return removed();
          }
          return null;
        case StorageEventType.added:
          if (added != null) {
            return added(value);
          }
          return null;
        default:
          return null;
      }
    } else {
      if (removed != null) {
        return removed();
      }
      return null;
    }
  }
}
