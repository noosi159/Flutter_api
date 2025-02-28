class AirQuality {
  final String stationName;
  final double aqi;
  final String status;
  final String date;
  final String time;
  final double lat; // เพิ่มตัวแปร lat
  final double long; // เพิ่มตัวแปร long

  AirQuality({
    required this.stationName,
    required this.aqi,
    required this.status,
    required this.date,
    required this.time,
    required this.lat, // เพิ่ม parameter lat
    required this.long, // เพิ่ม parameter long
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    var aqiData = json['AQILast'] != null ? json['AQILast']['AQI'] : null;
    double aqiValue = aqiData != null
        ? double.tryParse(aqiData['aqi'].toString()) ?? 0.0
        : 0.0;
    String status = aqiData != null ? aqiData['param'] ?? 'Unknown' : 'Unknown';
    String date = json['AQILast'] != null
        ? json['AQILast']['date'] ?? 'Unknown'
        : 'Unknown';
    String time = json['AQILast'] != null
        ? json['AQILast']['time'] ?? 'Unknown'
        : 'Unknown';
    double lat = json['lat'] != null
        ? double.tryParse(json['lat'].toString()) ?? 0.0
        : 0.0;
    double long = json['long'] != null
        ? double.tryParse(json['long'].toString()) ?? 0.0
        : 0.0;

    return AirQuality(
      stationName: json['nameTH'] ?? 'N/A',
      aqi: aqiValue,
      status: status,
      date: date,
      time: time,
      lat: lat, // กำหนดค่า lat
      long: long, // กำหนดค่า long
    );
  }
}
