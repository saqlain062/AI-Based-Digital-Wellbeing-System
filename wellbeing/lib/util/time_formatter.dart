class TimeFormatter {
  /// Convert hours (double) to user-friendly format: "1h 24m 30s"
  static String formatHours(double hours) {
    int totalSeconds = (hours * 3600).toInt();
    int secondsLeft = totalSeconds;

    int h = secondsLeft ~/ 3600;
    secondsLeft %= 3600;

    int m = secondsLeft ~/ 60;
    int s = secondsLeft % 60;

    List<String> parts = [];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (s > 0 || parts.isEmpty) parts.add('${s}s');

    return parts.join(' ');
  }

  /// Convert milliseconds to hours with 1 decimal
  static double millisecondsToHours(int millis) {
    return millis / (1000 * 60 * 60);
  }

  /// Get a short version for compact display
  static String formatHoursShort(double hours) {
    if (hours >= 1.0) {
      return '${hours.toStringAsFixed(1)}h';
    } else {
      int minutes = (hours * 60).toInt();
      return '${minutes}m';
    }
  }
}
