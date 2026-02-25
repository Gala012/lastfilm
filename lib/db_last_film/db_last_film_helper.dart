import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_last_film_entity.dart';

class DbLastFilmHelper {
  static Database? _db;
  static const String _dbName = 'last_film.db';
  static const int _version = 1;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE roll (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        film_id TEXT NOT NULL,
        cover_path TEXT,
        created_at INTEGER NOT NULL,
        category INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE photo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roll_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (roll_id) REFERENCES roll (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE app_stats (
        key TEXT PRIMARY KEY,
        value INTEGER DEFAULT 0
      )
    ''');
    await db.insert('app_stats', {'key': 'roll_count', 'value': 0});
    await _initDefaultRolls(db);
  }

  static Future<void> _initDefaultRolls(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final film in ['superia100', 'gold200', 'vista800', 'color100', 'reala500d', 'ultra50', 'lomo800']) {
      final names = {'superia100': 'Superia 100', 'gold200': 'Gold 200', 'vista800': 'Vista 800', 'color100': 'Color 100', 'reala500d': 'Reala 500D', 'ultra50': 'Ultra 50', 'lomo800': 'Lomo 800'};
      await db.insert('roll', {'name': names[film], 'film_id': film, 'cover_path': null, 'created_at': now, 'category': 0});
    }
    await db.insert('app_stats', {'key': 'roll_count', 'value': 7}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> ensureDefaultRolls() async {
    final list = await getAllRolls();
    if (list.isEmpty) {
      final d = await db;
      await _initDefaultRolls(d);
    }
  }

  Future<List<RollEntity>> getAllRolls() async {
    final d = await db;
    final list = await d.query('roll', orderBy: 'created_at DESC');
    return list.map((m) => RollEntity.fromMap(m)).toList();
  }

  Future<RollEntity?> getRollById(int id) async {
    final d = await db;
    final list = await d.query('roll', where: 'id = ?', whereArgs: [id]);
    if (list.isEmpty) return null;
    return RollEntity.fromMap(list.first);
  }

  Future<List<RollEntity>> getRollsByCategory(int category) async {
    if (category == 0) return getAllRolls();
    final d = await db;
    final list = await d.query('roll', where: 'category = ?', whereArgs: [category], orderBy: 'created_at DESC');
    return list.map((m) => RollEntity.fromMap(m)).toList();
  }

  Future<int> insertRoll(RollEntity entity) async {
    final d = await db;
    final id = await d.insert('roll', entity.toMap());
    await _updateRollCount();
    return id;
  }

  Future<int> updateRoll(RollEntity entity) async {
    final d = await db;
    return d.update('roll', entity.toMap(), where: 'id = ?', whereArgs: [entity.id]);
  }

  Future<int> deleteRoll(int id) async {
    final d = await db;
    await d.delete('photo', where: 'roll_id = ?', whereArgs: [id]);
    final r = await d.delete('roll', where: 'id = ?', whereArgs: [id]);
    await _updateRollCount();
    return r;
  }

  Future<List<PhotoEntity>> getPhotosByRollId(int rollId) async {
    final d = await db;
    final list = await d.query('photo', where: 'roll_id = ?', whereArgs: [rollId], orderBy: 'created_at DESC');
    return list.map((m) => PhotoEntity.fromMap(m)).toList();
  }

  Future<List<PhotoEntity>> getAllPhotos() async {
    final d = await db;
    final list = await d.query('photo', orderBy: 'created_at DESC');
    return list.map((m) => PhotoEntity.fromMap(m)).toList();
  }

  Future<int> insertPhoto(PhotoEntity entity) async {
    final d = await db;
    return await d.insert('photo', entity.toMap());
  }

  Future<int> deletePhoto(int id) async {
    final d = await db;
    return d.delete('photo', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePhoto(PhotoEntity entity) async {
    if (entity.id == null) return 0;
    final d = await db;
    return d.update('photo', entity.toMap(), where: 'id = ?', whereArgs: [entity.id]);
  }

  Future<String?> getSetting(String key) async {
    final d = await db;
    final list = await d.query('settings', where: 'key = ?', whereArgs: [key]);
    if (list.isEmpty) return null;
    return list.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final d = await db;
    await d.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> getRollCount() async {
    final d = await db;
    final list = await d.query('app_stats', where: 'key = ?', whereArgs: ['roll_count']);
    if (list.isEmpty) return 0;
    return list.first['value'] as int? ?? 0;
  }

  Future<int> getPhotoCount() async {
    final d = await db;
    final r = await d.rawQuery('SELECT COUNT(*) as c FROM photo');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<void> _updateRollCount() async {
    final d = await db;
    final r = await d.rawQuery('SELECT COUNT(*) as c FROM roll');
    final c = Sqflite.firstIntValue(r) ?? 0;
    await d.insert('app_stats', {'key': 'roll_count', 'value': c}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
