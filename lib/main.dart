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
      title: 'AQI Status APP',
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

  // ใช้ AQI เพื่อกำหนดสีพื้นหลัง
  Color getAQIColor(double aqi) {
    if (aqi <= 50) {
      return Colors.green; // Air quality is good
    } else if (aqi <= 100) {
      return const Color.fromARGB(255, 38, 96, 44); // Moderate air quality
    } else if (aqi <= 120) {
      return const Color.fromARGB(
          255, 235, 199, 20); // Unhealthy for sensitive groups
    } else if (aqi <= 200) {
      return Colors.red; // Unhealthy
    } else {
      return Colors.purple; // Very Unhealthy
    }
  }

  // เปลี่ยนสีของ AppBar ตามค่า AQI
  Color getAppBarColor(double aqi) {
    if (aqi <= 50) {
      return Colors.green;
    } else if (aqi <= 100) {
      return Colors.yellow;
    } else if (aqi <= 150) {
      return Colors.orange;
    } else if (aqi <= 200) {
      return Colors.red;
    } else {
      return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getAppBarColor(50), // เปลี่ยนสีหัวข้อให้เหมาะสมกับ AQI
        title: Text('Air Quality Data'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [getAQIColor(50), getAQIColor(100)], // ใช้สีที่กำหนดจาก AQI
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<AirQuality>>(
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

                  String dateTime = "${airQuality.date} ${airQuality.time}";
                  String location =
                      "Lat: ${airQuality.lat}, Long: ${airQuality.long}";

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        elevation: 5, // เพิ่มเงาให้กับการ์ด
                        color: cardColor,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          title: Text(
                            airQuality.stationName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AQI: ${airQuality.aqi}\nStatus: ${airQuality.status}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Date & Time: $dateTime',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Location: $location',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
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
      ),
    );
  }
}
