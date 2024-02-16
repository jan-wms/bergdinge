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

  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  if(DateTime(input.year, input.month, input.day) == today) {
    result = 'Heute';
  } else if(DateTime(input.year, input.month, input.day) == yesterday) {
    result = 'Gestern';
  }

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