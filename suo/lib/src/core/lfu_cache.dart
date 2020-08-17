import 'dart:collection';

/// LFU Cache implementation
class LFUCache<K, V> {
  int capacity;

  Map<K, V> values = {};
  Map<K, int> counts = {};
  Map<int, Queue<K>> indices = SplayTreeMap<int, Queue<K>>();

  int get min => indices.keys.first;

  LFUCache(this.capacity);

  V get(K key) {
    if (values.containsKey(key)) {
      final count = counts.containsKey(key) ? counts[key] + 1 : 0;
      counts[key] = count;

      if (indices[count] == null) {
        indices[count] = Queue.of([key]);
      } else {
        indices[count].add(key);
      }

      if (count > 0) {
        indices[count - 1].remove(key);
        if (indices[count - 1].isEmpty) {
          indices.removeWhere((k, _) => k == count - 1);
        }
      }

      return values[key];
    }
    return null;
  }

  void put(K key, V value) {
    if (values.length >= capacity) {
      final keyToRemove = indices[min].removeLast();
      values.remove(keyToRemove);
      counts.remove(keyToRemove);
    }
    values[key] = value;
    if (!counts.containsKey(key)) {
      counts[key] = 0;
      if (indices[0] == null) {
        indices[0] = Queue.of([key]);
      } else {
        indices[0].addFirst(key);
      }
    }
  }
}
