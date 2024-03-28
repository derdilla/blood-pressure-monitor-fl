/// Extension for safer casting of generic objects.
extension Castable on Object {
  /// Returns null if this is not of type [T] else return casted object.
  T? castOrNull<T>() {
    if (this is T) return this as T;
    return null;
  }
}
