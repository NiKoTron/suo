enum StorageEventType { changed, removed, added }

class StorageEvent<T> {
  final StorageEventType type;
  final T data;

  StorageEvent._(this.data, this.type);

  factory StorageEvent.removed() =>
      StorageEvent._(null, StorageEventType.removed);

  factory StorageEvent.changed(T data) =>
      StorageEvent._(data, StorageEventType.changed);

  factory StorageEvent.added(T data) =>
      StorageEvent._(data, StorageEventType.added);

  R when<R>({
    R Function(T data) changed,
    R Function() removed,
    R Function(T data) added,
  }) {
    switch (type) {
      case StorageEventType.changed:
        if (changed != null) {
          return changed(data);
        }
        return null;
      case StorageEventType.removed:
        if (removed != null) {
          return removed();
        }
        return null;
      case StorageEventType.added:
        if (added != null) {
          return added(data);
        }
        return null;
      default:
        return null;
    }
  }
}
