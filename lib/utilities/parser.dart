import 'package:intl/intl.dart';

class Parser {
  static String stringFromDateTime(DateTime input) {
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

    return '${input.day}. ${months[input.month - 1]} ${input.year}';
  }

  static String stringFromDoublePrice(double price) {
    bool isInteger(num value) => value is int || value == value.round();

    String result = price.toStringAsFixed(2);
    if (isInteger(price)) {
      result = price.round().toString();
    }
    return result;
  }

  static String thousandDot(double value) {
    final formatter = NumberFormat('#,###', 'de_DE');
    return formatter.format(value);
  }
}
