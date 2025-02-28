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
  _AirQualityPageState createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<AirQualityPage> {
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
      final Map<String, dynamic> data = json.decode(response.body); // แปลง JSON
      final List<dynamic> stations =
          data['stations']; // ใช้ 'stations' แทน 'data'

      return stations.map((station) => AirQuality.fromJson(station)).toList();
    } else {
      throw Exception('Failed to load air quality data');
    }
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

                // กำหนดสีของ Card และไอคอนตามค่า AQI
                Color cardColor =
                    airQuality.aqi <= 100 ? Colors.green : Colors.red;
                IconData icon = airQuality.aqi <= 100
                    ? Icons.sentiment_satisfied
                    : Icons.sentiment_dissatisfied;

                // วันที่และเวลา
                String dateTime =
                    "${airQuality.date} ${airQuality.time}"; // ใช้ข้อมูลจาก date และ time

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  color: cardColor, // เปลี่ยนสีของ Card ตามค่า AQI
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
                      ],
                    ),
                    trailing: Icon(
                      icon, // ไอคอนที่แสดงตามค่า AQI
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
