// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Meminta izin lokasi saat inisialisasi
    _requestLocationPermission();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  // Fungsi untuk meminta izin lokasi
  void _requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      // Izin diberikan, Anda dapat melakukan tindakan sesuai kebutuhan
      print('Izin lokasi diberikan.');
    } else if (status.isDenied) {
      // Izin ditolak, Anda dapat memberi informasi ke pengguna untuk memberikan izin melalui dialog atau pesan lainnya.
      print('Izin lokasi ditolak oleh pengguna.');
    } else if (status.isPermanentlyDenied) {
      // Pengguna telah secara permanen menolak izin lokasi. Anda dapat membuka pengaturan perangkat untuk meminta izin secara manual.
      print(
          'Izin lokasi ditolak secara permanen. Buka pengaturan perangkat untuk memberikan izin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: const [
            Text(
              'ini coba coba',
            )
          ],
        ),
      ),
    );
  }
}
