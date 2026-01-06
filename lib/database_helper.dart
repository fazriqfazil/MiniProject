import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();

    // Define the old and new paths
    String oldPath = join(databasesPath, 'user_auth.db');
    String newPath = join(databasesPath, 'restaurant_package_booking');

    // Check if the old database file exists
    bool exists = await databaseExists(oldPath);

    if (exists) {
      // Rename the old file to the new name so the data is carried over
      await File(oldPath).rename(newPath);
      print("Old database found. Renamed 'user_auth.db' to 'restaurant_package_booking'");
    }

    return await openDatabase(
      newPath,
      version: 5,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, password TEXT, role TEXT)',
        );

        // 2. Bookings table (Fully defined)
        await db.execute('''
          CREATE TABLE bookings(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            userId INTEGER,
            packageName TEXT, 
            eventDate TEXT, 
            eventTime TEXT, 
            numGuests INTEGER, 
            totalPrice REAL,
            status TEXT DEFAULT 'Pending'
          )
        ''');

        // 3. Menus table
        await db.execute('''
          CREATE TABLE menus(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            main TEXT,
            sides TEXT,
            dessert TEXT,
            drink TEXT,
            pax INTEGER,
            basePrice REAL,
            rating INTEGER
          )
        ''');

        // 4. Admin Initial Data
        await db.insert('users', {
          'name': 'Administrator',
          'email': 'admin@forkyeah.com',
          'password': 'admin123',
          'role': 'admin'
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          try {
            await db.execute("ALTER TABLE bookings ADD COLUMN status TEXT DEFAULT 'Pending'");
          } catch (e) { print("Status column already exists"); }

          try {
            await db.execute("ALTER TABLE bookings ADD COLUMN userId INTEGER");
          } catch (e) { print("userId column already exists"); }
        }
      },
    );
  }

  // --- AUTHENTICATION ---
  Future<bool> doesUserExist(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return results.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserData(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // --- BOOKING METHODS ---
  Future<int> insertBooking(Map<String, dynamic> row) async {
    final db = await database;
    Map<String, dynamic> data = Map.from(row);
    if (!data.containsKey('status')) {
      data['status'] = 'Pending';
    }
    return await db.insert('bookings', data);
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final db = await database;
    return await db.query('bookings', orderBy: 'id DESC');
  }

  // --- FIXED: GENERAL UPDATE METHOD (For EditBookingPage) ---
  Future<int> updateBooking(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('bookings', row, where: 'id = ?', whereArgs: [id]);
  }

  // --- STATUS SPECIFIC UPDATE (For Admin Accept Button) ---
  Future<int> updateBookingStatus(int id, String status) async {
    final db = await database;
    return await db.update('bookings', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getAcceptedBookingCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM bookings WHERE status = ?', ['Accepted']);
    return result.first['count'] as int;
  }

  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // --- ADMIN / MENU METHODS ---
  Future<List<Map<String, dynamic>>> getAdminAllBookings() async {
    final db = await database;
    return await db.query('bookings', orderBy: 'id DESC');
  }

  Future<int> addMenuPackage(Map<String, dynamic> menu) async {
    final db = await database;
    return await db.insert('menus', menu);
  }

  Future<List<Map<String, dynamic>>> getAllMenus() async {
    final db = await database;
    return await db.query('menus');
  }

  Future<int> updateMenu(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('menus', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMenu(int id) async {
    final db = await database;
    return await db.delete('menus', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}