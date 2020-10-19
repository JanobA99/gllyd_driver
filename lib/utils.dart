class Utils {

  static String convertDate(String month, String day) {
    String result = '';
    int monthValue = int.parse(month);
    int dayValue = int.parse(day);
    if (dayValue < 10)
      result += '0' + day;
    else
      result += day;
    result += '.';
    if (monthValue < 10)
      result += '0' + month;
    else
      result += month;

    return result;
  }

  static String getFullDate(String year, String month, String day) {
    String result = '';
    result = convertDate(month, day) + '.' + year;
    return result;
  }

  static int getTripMinutes(String startTime, String endTime) {
    int res = 0;
    List<String> end = endTime.split(":");
    List<String> start = startTime.split(":");

    res = 60 * int.parse(end[0]) + int.parse(end[1]) - 60 * int.parse(start[0]) - int.parse(start[1]);
    return res;
  }

  static String convertToHours(int minutes) {
    double hour = minutes / 60;
    return hour.toStringAsFixed(1);
  }

  static String convertToKm(double distance) {
    double km = distance / 1000;
    return km.toStringAsFixed(1);
  }

  static String convertAMPMTime(String time) {
    String res;
    List<String> temp = time.split(":");
    int hour = int.parse(temp[0]);
    int minute = int.parse(temp[1]);
    if (minute < 10)
      res = '0' + minute.toString();
    else
      res = minute.toString();

    if (hour == 24) {
      res = '12:' + res + ' am';
    } else if (hour == 12) {
      res = '12:' + res + ' pm';
    } else if (hour < 12) {
      res = hour.toString() + ':' + res + ' am';
    } else {
      hour = hour - 12;
      res = hour.toString() + ':' + res + ' pm';
    }

    res.replaceAll(':00', '');
    res = res + ' ';
    return res;
  }
}