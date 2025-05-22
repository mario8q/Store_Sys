import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('storsys.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Drop the table if it exists to ensure we have a clean slate
    await db.execute('DROP TABLE IF EXISTS products');

    // Create the table with the correct schema
    await db.execute('''
      CREATE TABLE products (
        document_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        category TEXT NOT NULL,
        imageUrl TEXT,
        userId TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // If we need to add new columns or make other schema changes,
    // we can do it here based on the version numbers
    if (oldVersion < 1) {
      await _createDB(db, newVersion);
    }
    // Add more version checks here as needed
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'storsys.db');
    await deleteDatabase(path);
    _database = null;
  }
}
