class AirQuality {
  final String stationName;
  final double aqi;
  final String status;
  final String date;
  final String time;

  AirQuality({
    required this.stationName,
    required this.aqi,
    required this.status,
    required this.date,
    required this.time,
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

    return AirQuality(
      stationName: json['nameTH'] ?? 'N/A',
      aqi: aqiValue,
      status: status,
      date: date,
      time: time,
    );
  }
}
