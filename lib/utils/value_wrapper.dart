/// The class to wrap values that we might want to explicitly set to null.
/// If you pass an instance of this to copyWith, you are saying:
/// "I explicitly want to set the new value to whatever is inside this wrapper."
class ValueWrapper<T> {
  final T value;

  const ValueWrapper(this.value);
}