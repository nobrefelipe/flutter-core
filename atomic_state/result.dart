sealed class Result<T> {
  const Result._();
  // factory Result.initial() = Initial<T>;
  factory Result.idle() = Idle<T>;
  factory Result.loading() = Loading<T>;
  factory Result.empty() = Empty<T>;
  factory Result.success(T value) = Success<T>;
  factory Result.failure(String message) = Failure<T>;

  // Use this getter to return the error insead of casting the result to Failure in the view.
  String get errorMessage {
    return this is Failure ? (this as Failure).message : '';
  }
}

// class Initial<T> extends Result<T> {
//   const Initial() : super._();

//   @override
//   String toString() => 'Initial<$T>(';
// }

class Idle<T> extends Result<T> {
  const Idle() : super._();

  @override
  String toString() => 'Idle<$T>(';
}

class Loading<T> extends Result<T> {
  const Loading() : super._();
  @override
  String toString() => 'Loading<$T>()';
}

class Empty<T> extends Result<T> {
  const Empty() : super._();
  @override
  String toString() => 'Empty()';
}

class Success<T> extends Result<T> {
  final T value;
  Success(this.value) : super._();

  @override
  String toString() => 'Success<$T>($value) ';
}

class Failure<T> extends Result<T> {
  final String message;
  Failure(this.message) : super._();

  @override
  String toString() => 'Failure<$T>($message) ';
}
