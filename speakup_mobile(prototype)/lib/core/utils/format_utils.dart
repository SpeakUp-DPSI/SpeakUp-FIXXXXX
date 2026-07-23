import 'package:intl/intl.dart';

class FormatUtils {
  static String formatDate(String? rawDate, {bool includeTime = false}) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    
    try {
      final DateTime dt = DateTime.parse(rawDate).toLocal();
      if (includeTime) {
        return DateFormat('dd MMM yyyy HH:mm').format(dt);
      }
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      // Fallback
      if (rawDate.contains('T')) {
        return rawDate.split('T')[0];
      }
      return rawDate;
    }
  }

  static String formatTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    
    try {
      final DateTime dt = DateTime.parse(rawDate).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      if (rawDate.contains('T')) {
        return rawDate.split('T')[1].substring(0, 5);
      }
      return '-';
    }
  }
}
