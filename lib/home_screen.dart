// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:perkiraan_cuaca_bmkg/services/endpoint.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> kotaList = ['Select Kota'];
  List<dynamic>? weatherData;
  String? selectedKota;
  int id = 0;
  List<String> idkota = [];
  String idcuaca = "";
  String waktu = "";
  String suhu = "";
  String cuaca = "";

  String? weatherStatus;
  @override
  void initState() {
    super.initState();
    Endpoint.instance.cuacawilayah(id).then((value) => setState(() {
          // status = value["status"];
        }));
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _fetchNearestCity(position.latitude, position.longitude);
      fetchAdditionalData();
    } catch (error) {
      print('Error fetching current location: $error');
    }
  }

  Future<void> _fetchNearestCity(double latitude, double longitude) async {
    try {
      List<dynamic> data = await Endpoint.instance.kodewilayah();
      double nearestDistance = double.maxFinite;
      String nearestCity = '';

      for (var item in data) {
        double lat = double.parse(item['lat']);
        double lon = double.parse(item['lon']);

        double distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          lat,
          lon,
        );

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestCity = item['kota'] as String;
          id = int.parse(item['id']);
        }
      }

      setState(() {
        kotaList.clear();
        kotaList.add('Select Kota');
        for (var item in data) {
          kotaList.add(item['kota'] as String);
        }
        selectedKota = nearestCity;
      });
    } catch (error) {
      print('Error fetching nearest city: $error');
    }
  }

  String formatDate(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (error) {
      print('Error formatting date: $error');
      return 'N/A';
    }
  }

  Future<void> fetchAdditionalData() async {
    try {
      var value = await Endpoint.instance.cuacawilayah(id);
      setState(() {
        print('Value from cuacawilayah: $value');
        // Update the value and selectedKota after fetching data
      });
    } catch (error) {
      print('Error fetching additional data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List filterDataByDate(DateTime targetDate) {
      return weatherData?.where((item) {
            final currentDate = DateTime.parse(item['jamCuaca']);
            return currentDate.day == targetDate.day &&
                currentDate.month == targetDate.month &&
                currentDate.year == targetDate.year;
          }).toList() ??
          [];
    }

    final todayDate = DateTime.now();
    final tomorrowDate = DateTime.now().add(Duration(days: 1));

    List todayWeatherData = filterDataByDate(todayDate);
    List tomorrowWeatherData = filterDataByDate(tomorrowDate);

    return Scaffold(
        appBar: AppBar(
          title: Text("Select Kota"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              dropdownitem(),
              Text(
                '$suhu°',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                waktu,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                cuaca,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                idcuaca.toString(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {
                  print(
                      'TextButton pressed! Selected Kota: $selectedKota, ID: $id');
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
              Text(
                selectedKota ?? 'Submit',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  if (weatherStatus != null)
                    Text(
                      'Weather Status: $weatherStatus', // Display the fetched weather status
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: todayWeatherData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildWeatherCard(todayWeatherData[index]);
                  },
                ),
              ),
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tomorrowWeatherData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildWeatherCard(tomorrowWeatherData[index]);
                  },
                ),
              )
            ],
          ),
        ));
  }

  Widget buildWeatherCard(Map<String, dynamic> weather) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formatDate(weather['jamCuaca'] ?? 'N/A'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                weather['kodeCuaca'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                weather['cuaca'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${weather['tempC']}°' ?? 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropdownitem() {
    return Center(
      child: DropdownButton<String>(
        value: selectedKota,
        onChanged: (String? newValue) {
          setState(() {
            selectedKota = newValue;
            int index = kotaList.indexOf(newValue!);
            if (index != -1 && index < idkota.length) {
              String selectedId = idkota[index];
              id = int.parse(selectedId);
            }
            Endpoint.instance
                .cuacawilayah(id)
                .then((value) => setState(() {
                      weatherData = value;
                      cuaca = weatherData?[0]['cuaca'];
                      idcuaca = weatherData?[0]['kodeCuaca'];
                      suhu = weatherData?[0]['tempC'];
                      waktu = weatherData?[0]['jamCuaca'];
                      // Update the state based on the received data if needed
                      // For example, you can extract and use the data from 'value'
                      // var status = value["status"];
                    }))
                .catchError((error) {
              print('Error fetching additional data: $error');
            });
          });
        },
        items: kotaList.map((kota) {
          return DropdownMenuItem<String>(
            value: kota,
            child: Text(kota),
          );
        }).toList(),
        hint: const Text(
          "Please choose ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
