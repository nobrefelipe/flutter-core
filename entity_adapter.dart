mixin EntityAdapter<T> {
  T fromJson(dynamic json);
  Map<String, dynamic> toMap(T value);
  List<T> fromJsonToList(dynamic json);
}

mixin Entity {
  String? getAttribute(String attribute);
}
