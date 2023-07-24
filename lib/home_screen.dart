// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:perkiraan_cuaca_bmkg/services/endpoint.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> kotaList = [];
  String? selectedKota; // Store the selected Kota
  int id = 0;
  List<String> idkota = []; // Change the data type of 'id' to String

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<dynamic> data = await Endpoint.instance.kodewilayah();
      setState(() {
        kotaList = data.map((item) => item['kota'] as String).toList();
        idkota = data.map((item) => item['id'] as String).toList();
      });
    } catch (error) {
      print('Error fetching data: $error');
      // Handle any error that occurs during data fetching
    }
  }

  Future<void> fetchAdditionalData() async {
    try {
      var value = await Endpoint.instance.cuacawilayah(id);
      // Perform any action with the fetched data, update the UI, etc.
      print('Value from checkstatusmitra: $value');
    } catch (error) {
      print('Error fetching additional data: $error');
      // Handle any error that occurs during data fetching
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Kota"),
      ),
      body: RefreshIndicator(
          onRefresh: fetchData,
          child: Column(
            children: [
              Center(
                child: DropdownButton<String>(
                  value: selectedKota, // Set the selected value here
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedKota = newValue;
                      // Find the index of the selected Kota in the kotaList
                      int index = kotaList.indexOf(newValue!);

                      // Check if the index is valid (not -1) and within the range of idkota list
                      if (index != -1 && index < idkota.length) {
                        // Use the index to access the corresponding idkota value
                        String selectedId = idkota[index];

                        // Convert the selectedId to an integer and update the 'id' variable
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
                  // Perform any action when the TextButton is pressed
                  // You can use the 'id' or 'selectedKota' as needed
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
            ],
          )),
    );
  }
}
