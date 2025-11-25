import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'catatan_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('catatan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE catatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lat REAL,
            lng REAL,
            note TEXT,
            address TEXT,
            type TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertNote(CatatanModel note) async {
    final db = await instance.database;
    return await db.insert('catatan', {
      'lat': note.position.latitude,
      'lng': note.position.longitude,
      'note': note.note,
      'address': note.address,
      'type': note.type,
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await instance.database;
    return await db.query('catatan');
  }

  Future<int> updateNote(CatatanModel note, int id) async {
    final db = await instance.database;
    return await db.update(
      'catatan',
      {
        'note': note.note,
        'lat': note.position.latitude,
        'lng': note.position.longitude,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('catatan', where: "id = ?", whereArgs: [id]);
  }
}
