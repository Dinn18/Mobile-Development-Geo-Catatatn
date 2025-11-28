import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'catatan_model.dart';
import 'catatan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<CatatanModel> _savedNotes = [];
  final MapController _mapController = MapController();

  // Fungsi mendapatkan untuk mendapatkan  lokasi saat ini
  Future<void> _findMyLocation() async {
    //cek layanan dan izin dari gps
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }

    //Ambil Posisi Saat Ini
    Position pos = await Geolocator.getCurrentPosition();
    //pindahkan kamera peta
    _mapController.move(latlong.LatLng(pos.latitude, pos.longitude), 15.0);
  }

  // fungsi menangani Long press pada peta
  void _handleLongPress(TapPosition _, latlong.LatLng point) async {
    // Reverse Geocoding (koordinat -> Alamat)
    List<Placemark> placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
    String address = placemarks.first.street ?? placemarks.first.street ?? "Alamat tidak ditemukan";

    // ambil pemilihan type lokasi seperti rumah toko ataupun kantor
    String? chosenType = await _selectTypeDialog();
    if (chosenType == null) return; // batal

    //Tampilkan Dialog (Kode UI Dialog disederhanakan disini)
    // Implementasi Dialog
    setState(() {
      _savedNotes.add(
        CatatanModel(
          id: DateTime.now().millisecondsSinceEpoch,
          position: point,
          note: "Catatan Baru",
          address: address,
          type: chosenType,
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lokasi disimpan: $address ($chosenType)")),
    );

    _saveToPreferences();
  }

  void _deleteMarker(int id) {
    setState(() {
      _savedNotes.removeWhere((item) => item.id == id);
    });
    _saveToPreferences();
  }

  Icon _iconByType(String type) {
    switch (type) {
      case "rumah":
        return const Icon(Icons.home, color: Colors.green, size: 40);
      case "toko":
        return const Icon(Icons.store, color: Colors.orange, size: 40);
      case "kantor":
        return const Icon(Icons.business, color: Colors.blue, size: 40);
      default:
        return const Icon(Icons.location_on, color: Colors.red, size: 40);
    }
  }

  // Dialog untuk memilih type lokasi
  Future<String?> _selectTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pilih Jenis Lokasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Rumah"),
                onTap: () => Navigator.pop(context, "rumah"),
              ),
              ListTile(
                title: const Text("Toko"),
                onTap: () => Navigator.pop(context, "toko"),
              ),
              ListTile(
                title: const Text("Kantor"),
                onTap: () => Navigator.pop(context, "kantor"),
              ),
            ],
          ),
        );
      },
    );
  }

  // TODO: Implementasi Simpan ke Shared Preferences
  void _saveToPreferences() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geo-Catatan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaftarCatatanPage(
                    notes: _savedNotes,
                    delete: _deleteMarker,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const latlong.LatLng(-6.2, 106.8),
          initialZoom: 13.0,
          onLongPress: _handleLongPress,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: _savedNotes
                .map(
                  (n) => Marker(
                    point: n.position,
                    width: 40,
                    height: 40,
                    child: _iconByType(n.type),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}