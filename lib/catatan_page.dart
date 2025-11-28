import 'package:flutter/material.dart';
import 'catatan_model.dart';

class DaftarCatatanPage extends StatelessWidget {
  final List<CatatanModel> notes;
  final Function(int id) delete;

  const DaftarCatatanPage({
    super.key,
    required this.notes,
    required this.delete,
  });

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
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Hapus Catatan?"),
                    content:
                        const Text("Apakah Anda yakin ingin menghapus catatan ini?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          delete(n.id!);     // panggil function delete
                          Navigator.pop(context);
                        },
                        child: const Text("Hapus"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}