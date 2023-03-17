import 'package:intl/intl.dart';
extension StringExtension on String {
  String capitalize() {
    int i = 0;
    var whiteSpaces = "";
    while (this[i] == " ") {
      i++;
      whiteSpaces += " ";
    }
    return "$whiteSpaces${this[i].toUpperCase()}${substring(i + 1)}";
  }

  String toCamelCase() {
    String res = "";
    for (var i = 0; i < length; i++) {
      if(i == 0 || this[i - 1] == " ") {
        res += this[i].toUpperCase();
      } else {
        res += this[i].toLowerCase();
      }
    }
    return res;
  }
}

extension DateTimeUtils on DateTime {
  int getLastDayOfMonth() {
    return DateTime(year, month + 1, 0).day;
  }

  int getFirstDayOfTheWeek() {
    return subtract(Duration(days: weekday - 1)).day;
  }

  String format({String pattern = "dd/MM/yyyy", int substring = -1}) {
    try {
      return DateFormat(pattern)
          .format(this)
          .substring(0, substring == -1 ? null : substring);
    } catch (e) {
      return "";
    }
  }

  bool isSameDay(DateTime date) {
    return year == date.year &&
        month == date.month &&
        day == date.day;
  }

  bool isWeekend() {
    return weekday == 6 || weekday == 7;
  }
}
