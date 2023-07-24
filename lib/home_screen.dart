// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:perkiraan_cuaca_bmkg/services/endpoint.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> kotaList = [];
  String? selectedKota;
  int id = 0;
  List<String> idkota = [];

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
          onRefresh: fetchData,
          child: Column(
            children: [
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
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
            ],
          )),
    );
  }
}
