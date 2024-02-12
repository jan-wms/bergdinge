String parseDate (DateTime input) {
  String result = input.toIso8601String();
  return result;
}