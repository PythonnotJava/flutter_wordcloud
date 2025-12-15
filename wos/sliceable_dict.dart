import 'dart:collection';

class SliceableMap<K, V> implements Map<K, V> {
  final LinkedHashMap<K, V> _inner = LinkedHashMap<K, V>();

  SliceableMap([Map<K, V>? original]) {
    if (original != null) {
      _inner.addAll(original);
    }
  } 

  /// ===== 切片功能 =====
  SliceableMap<K, V> slice(int? start, [int? end]) {
    start ??= 0;
    end ??= length;

    if (start < 0) start = 0;
    if (end > length) end = length;
    if (start > end) start = end;

    final keysList = _inner.keys.toList();
    final selectedKeys = keysList.sublist(start, end);

    final result = SliceableMap<K, V>();
    for (final k in selectedKeys) {
      result[k] = _inner[k] as V;
    }
    return result;
  }

  /// ===== Map 接口实现 =====
  @override
  V? operator [](Object? key) => _inner[key];

  @override
  void operator []=(K key, V value) => _inner[key] = value;

  @override
  void addAll(Map<K, V> other) => _inner.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) =>
      _inner.addEntries(entries);

  @override
  Map<RK, RV> cast<RK, RV>() => _inner.cast<RK, RV>();

  @override
  void clear() => _inner.clear();

  @override
  bool containsKey(Object? key) => _inner.containsKey(key);

  @override
  bool containsValue(Object? value) => _inner.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => _inner.entries;

  @override
  void forEach(void Function(K key, V value) action) => _inner.forEach(action);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterable<K> get keys => _inner.keys;

  @override
  int get length => _inner.length;

  @override
  V putIfAbsent(K key, V Function() ifAbsent) =>
      _inner.putIfAbsent(key, ifAbsent);

  @override
  V? remove(Object? key) => _inner.remove(key);

  @override
  void removeWhere(bool Function(K key, V value) test) =>
      _inner.removeWhere(test);

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) =>
      _inner.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(V Function(K key, V value) update) => _inner.updateAll(update);

  @override
  Iterable<V> get values => _inner.values;

  @override
  Map<K2, V2> map<K2, V2>(
          MapEntry<K2, V2> Function(K key, V value) transform) =>
      _inner.map(transform);

  @override
  String toString() => _inner.toString();
}
