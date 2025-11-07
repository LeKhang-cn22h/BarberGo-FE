import 'package:intl/intl.dart';

// Class DateTimeUtils dùng để định dạng ngày và giờ trong ứng dụng.
// Mục tiêu: giúp hiển thị ngày/giờ nhất quán (vd: trên màn hình đặt lịch, hóa đơn, thông tin khách hàng...).
class DateTimeUtils {

  // Định dạng NGÀY (ví dụ: 07/11/2025)
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Định dạng GIỜ (ví dụ: 15:45)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Định dạng NGÀY + GIỜ (ví dụ: 07/11/2025 15:45)
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}