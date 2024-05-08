String parseDate (DateTime input) {
  final months = <String>[
    'Jan.',
    'Feb.',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'Aug.',
    'Sep.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];

  String result = '${input.day}.';
  result = '$result ${months[input.month]}';
  result = '$result ${input.year}';

  return result;
}

String parsePrice (double price) {
  bool isInteger(num value) =>
      value is int || value == value.round();

  String result = price.toStringAsFixed(2);
  if(isInteger(price)) {
    result = price.round().toString();
  }
  return result;
}