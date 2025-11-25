import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'database_helper.dart';
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
      title: 'Reservasi Boxing',
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
  final MapController _mapController = MapController();
  final List<CatatanModel> _savedNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();   // <-- load data dari database
  }

  Future<void> _loadNotes() async {
    final data = await DatabaseHelper.instance.getNotes();
    setState(() {
      _savedNotes.clear();
      for (var item in data) {
        _savedNotes.add(
          CatatanModel(
            id: item["id"],
            position: latlong.LatLng(item["lat"], item["lng"]),
            note: item["note"],
            address: item["address"],
            type: item["type"],
          ),
        );
      }
    });
  }

  void _showNoteDialog(CatatanModel note) {
    TextEditingController controller = TextEditingController(text: note.note);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Detail Lokasi (${note.type})"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Alamat: ${note.address}"),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: "Catatan"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteNote(note.id!);
                setState(() => _savedNotes.remove(note));
                Navigator.pop(context);
              },
              child: const Text("HAPUS", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL"),
            ),
            TextButton(
              onPressed: () async {
                note.note = controller.text;
                await DatabaseHelper.instance.updateNote(note, note.id!);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("SIMPAN"),
            ),
          ],
        );
      },
    );
  }

  void _addMarkerAtCenter() async {
    var location = _mapController.camera.center;

    var newNote = CatatanModel(
      position: location,
      note: "Catatan Baru",
      address: "Belum tersedia",
      type: "Lokasi",
    );

    int id = await DatabaseHelper.instance.insertNote(newNote);
    newNote.id = id;

    setState(() {
      _savedNotes.add(newNote);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservasi Boxing - Map"),
        backgroundColor: Colors.purple.shade200,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaftarCatatanPage(notes: _savedNotes),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade200,
        onPressed: _addMarkerAtCenter,
        child: const Icon(Icons.add_location_alt_outlined),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: latlong.LatLng(-8.21, 113.67),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _savedNotes.map(
              (n) => Marker(
                point: n.position,
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showNoteDialog(n),
                  onPanUpdate: (details) {
                    setState(() {
                      n.position = latlong.LatLng(
                        n.position.latitude - details.delta.dy * 0.0001,
                        n.position.longitude + details.delta.dx * 0.0001,
                      );
                    });
                  },
                  child: const Icon(Icons.location_on,
                      size: 40, color: Colors.purple),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}
