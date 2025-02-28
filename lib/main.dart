import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'class/air_quality.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AirQualityPage(),
    );
  }
}

class AirQualityPage extends StatefulWidget {
  const AirQualityPage({super.key});

  @override
  AirQualityPageState createState() => AirQualityPageState();
}

class AirQualityPageState extends State<AirQualityPage> {
  late Future<List<AirQuality>> airQualityData;

  @override
  void initState() {
    super.initState();
    airQualityData = fetchAirQualityData();
  }

  Future<List<AirQuality>> fetchAirQualityData() async {
    final response = await http.get(
        Uri.parse('http://air4thai.pcd.go.th/services/getNewAQI_JSON.php'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> stations = data['stations'];

      return stations.map((station) => AirQuality.fromJson(station)).toList();
    } else {
      throw Exception('Failed to load air quality data');
    }
  }

  Color getAQIColor(double aqi) {
    int aqiInt = aqi.toInt();
    if (aqiInt >= 100) {
      return Colors.red;
    } else if (aqiInt >= 70) {
      return Colors.yellow;
    }
    return Colors.green;
  }

  IconData getAQIIcon(double aqi) {
    int aqiInt = aqi.toInt();
    if (aqiInt >= 100) {
      return Icons.sentiment_very_dissatisfied;
    } else if (aqiInt >= 70) {
      return Icons.sentiment_neutral;
    }
    return Icons.sentiment_satisfied;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Air Quality Data'),
      ),
      body: FutureBuilder<List<AirQuality>>(
        future: airQualityData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final airQualityList = snapshot.data!;
            return ListView.builder(
              itemCount: airQualityList.length,
              itemBuilder: (context, index) {
                final airQuality = airQualityList[index];
                Color cardColor = getAQIColor(airQuality.aqi);
                IconData icon = getAQIIcon(airQuality.aqi);

                String dateTime = "${airQuality.date} ${airQuality.time}";
                String location =
                    "Lat: ${airQuality.lat}, Long: ${airQuality.long}";

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  color: cardColor,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      airQuality.stationName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AQI: ${airQuality.aqi}\nStatus: ${airQuality.status}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Date & Time: $dateTime',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Location: $location',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      icon,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
