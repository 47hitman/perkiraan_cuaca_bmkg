// ignore_for_file: library_private_types_in_public_api

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
            dropdownitem(),
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
    );
  }
}
