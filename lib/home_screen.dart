import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:perkiraan_cuaca_bmkg/services/endpoint.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> kotaList = ['Select Kota'];

  String? selectedKota;
  int id = 0;
  List<String> idkota = [];

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

      // Get the nearest city using the latitude and longitude
      await _fetchNearestCity(position.latitude, position.longitude);

      // Fetch additional data based on the selected city
      fetchAdditionalData();
    } catch (error) {
      print('Error fetching current location: $error');
    }
  }

  Future<void> _fetchNearestCity(double latitude, double longitude) async {
    try {
      // Use the latitude and longitude to get the nearest city
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

      // Update the selected city with the nearest city
      setState(() {
        kotaList.clear(); // Clear existing items
        kotaList.add('Select Kota'); // Add "Select Kota" as the first item
        for (var item in data) {
          kotaList.add(item['kota'] as String); // Add other kota names
        }
        selectedKota = nearestCity; // Set the selected city to the nearest city
      });
    } catch (error) {
      print('Error fetching nearest city: $error');
    }
  }

  Future<void> fetchAdditionalData() async {
    try {
      var value = await Endpoint.instance.cuacawilayah(id);
      print('Value from checkstatusmitra: $value');
    } catch (error) {
      print('Error fetching additional data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Kota"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCurrentLocation,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: DropdownButton<String>(
                value: selectedKota,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedKota = newValue;
                    int index = kotaList.indexOf(newValue!);
                    if (index != -1 && index < idkota.length) {
                      String selectedId = idkota[index];
                      id = int.parse(selectedId);
                      fetchAdditionalData();
                    }
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
            Text(
              selectedKota ?? 'Submit',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
