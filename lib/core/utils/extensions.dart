
extension StringExtensions on String {
  bool get isValidEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  bool get isValidPhone {
    final regex = RegExp(r'^\d{9,11}$');
    return regex.hasMatch(this);
  }
}

extension DateTimeExtensions on DateTime {
  String toShortDate() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
