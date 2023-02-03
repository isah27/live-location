import 'dart:io';
import 'package:location_tracker/model/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static const _dbName = 'Location.db';
  static const _dbVersion = 1;

  //singleton constructor
  DataBaseHelper._();
  static final DataBaseHelper instance = DataBaseHelper._();

  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String path = join(dataDirectory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: onCreateDB);
  }

  onCreateDB(Database db, int version) async {
    db.execute('''
    CREATE TABLE ${User.tbluser}(
      ${User.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
     ${User.colName} TEXT NOT NULL,
     ${User.colSwitch} INT NOT NULL
    )
''');
  }

  // insert data into user table
  Future<int> insertUser(User user) async {
    Database? db = await instance.database;
    return await db!.insert(User.tbluser, user.tomap());
  }

  //fetch data from user table
  Future<User> fetchUser() async {
    Database? db = await instance.database;
    List<Map> user = await db!.query(User.tbluser);
    return user.isEmpty ? User() : user.map((e) => User.fromMap(e)).toList().first;
  }
}
