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
      DateTime? dateTime = DateTime.tryParse(dateTimeString);
      if (dateTime == null) {
        print('Error formatting date: Invalid date format');
        return 'N/A';
      }
      return DateFormat('HH:mm').format(dateTime);
    } catch (error) {
      print('Error formatting date: $error');
      return 'N/A';
    }
  }

  String formatDateToWords(String dateTimeString) {
    try {
      DateTime? dateTime = DateTime.tryParse(dateTimeString);
      if (dateTime == null) {
        print('Error parsing date: Invalid date format');
        return 'Invalid Date';
      }

      String day = DateFormat('EEEE').format(dateTime);
      String month = DateFormat('MMMM').format(dateTime);
      int date = dateTime.day;
      String year = DateFormat('y').format(dateTime);
      String time = DateFormat('HH:mm').format(dateTime);

      // Format the date as "dayOfMonth monthName year, time" (e.g., "24 July 2023, 00:00")
      return '$date $month $year, $time';
    } catch (error) {
      print('Error parsing date: $error');
      return 'Invalid Date';
    }
  }

  Future<void> fetchAdditionalData() async {
    try {
      var value = await Endpoint.instance.cuacawilayah(id);
      setState(() {
        weatherData = value;

        // Assuming weatherData is a list of maps
        if (weatherData!.isNotEmpty) {
          // Accessing the first map in the list to get the data
          Map<String, dynamic> firstData = weatherData![0];

          // Extracting and setting values
          cuaca = firstData['cuaca'] ?? 'N/A';
          idcuaca = firstData['kodeCuaca'] ?? 'N/A';
          suhu = firstData['tempC'] ?? 'N/A';
          waktu = firstData['jamCuaca'] ?? 'N/A';
        }
        print(cuaca);
        print(idcuaca);
        print(suhu);
        print(waktu);
        print('Value from cuacawilayah: $weatherData');
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
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.blue.withOpacity(0.7),
        body: Column(
          children: [
            tophome(),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Hari ini',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: todayWeatherData.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return buildWeatherCard(todayWeatherData[index]);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Besok',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tomorrowWeatherData.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(width: 10), // Atur lebar pemisah antar item
                      itemBuilder: (BuildContext context, int index) {
                        return buildWeatherCard(tomorrowWeatherData[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Card buildTransparentBlueCard(Widget child) {
    return Card(
      color: Colors.blue.withOpacity(0.3), // Set the color to transparent blue
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: child,
      ),
    );
  }

  Widget buildWeatherCard(Map<String, dynamic> weather) {
    String weatherCode = weather['kodeCuaca'] ?? 'N/A';
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Material(
        color: Colors.transparent, // Set the background color to white
        elevation: 0, // Set elevation to 0 to remove the shadow
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                8)), // Optional: You can add rounded corners if desired
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
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              if (weatherCode != 'N/A')
                Image.network(
                  'https://ibnux.github.io/BMKG-importer/icon/$weatherCode.png',
                  width: 50, // You can adjust the size as needed
                  height: 50,
                ),
              SizedBox(height: 4),
              Text(
                '${weather['tempC']}°' ?? 'N/A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tophome() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Add the border radius here
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        // You can add other properties like gradients, borders, etc.
      ),
      height: 400,
      // color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 90,
          ),
          dropdownitem(),
          Text(
            '$suhu°',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 80,
            ),
          ),
          Text(
            formatDateToWords(waktu),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Text(
            cuaca,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          if (idcuaca != 'N/A')
            Image.network(
              'https://ibnux.github.io/BMKG-importer/icon/$idcuaca.png',
              width: 50, // You can adjust the size as needed
              height: 50,
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
        ],
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
            Endpoint.instance.cuacawilayah(id).then((value) {
              setState(() {
                weatherData = value;
              });

              DateTime currentTime = DateTime.now();
              Map<String, dynamic>? matchingWeather = weatherData?.firstWhere(
                (entry) {
                  DateTime entryTime = DateTime.parse(entry['jamCuaca']);
                  return currentTime
                      .isBefore(entryTime); // Find the first future entry
                },
                orElse: () =>
                    weatherData?.last, // If no future entry, use the last entry
              );

              if (matchingWeather != null) {
                setState(() {
                  cuaca = matchingWeather['cuaca'];
                  idcuaca = matchingWeather['kodeCuaca'];
                  suhu = matchingWeather['tempC'];
                  waktu = matchingWeather['jamCuaca'];
                });
              } else {
                // If matchingWeather is null, set default values or handle as needed
                setState(() {
                  cuaca = 'N/A';
                  idcuaca = 'N/A';
                  suhu = 'N/A';
                  waktu = 'N/A';
                });
              }
            }).catchError((error) {
              print('Error fetching additional data: $error');
            });
          });
        },
        items: kotaList.map((kota) {
          return DropdownMenuItem<String>(
            value: kota,
            child: Text(
              kota,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
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
