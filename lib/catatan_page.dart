import 'package:flutter/material.dart';
import 'catatan_model.dart';

class DaftarCatatanPage extends StatelessWidget {
  final List<CatatanModel> notes;

  const DaftarCatatanPage({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Catatan")),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final n = notes[index];
          return ListTile(
            leading: Icon(
              n.type == "rumah"
                  ? Icons.home
                  : n.type == "toko"
                      ? Icons.store
                      : Icons.business,
            ),
            title: Text(n.note),
            subtitle: Text(n.address),
          );
        },
      ),
    );
  }
}
