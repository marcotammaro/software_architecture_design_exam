import 'package:intl/intl.dart';

extension DateTimeFirebaseHelper on DateTime {
  String toFirestore() {
    return DateFormat('dd-MM-yyyy – HH:mm:ss').format(this);
  }

  static DateTime fromFirestore(String date) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy – HH:mm:ss');
    return dateFormat.parse(date);
  }
}
