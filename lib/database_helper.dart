import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  late String path;
  Database? _db;

  Future<Database> getDb() async {
    path = join(await getDatabasesPath(), 'database.db');

    _db ??= await _initDb(path);

    return _db!;
  }

  Future<Database> _initDb(String path) async {
    _db = await openDatabase(path, version: 3, onCreate: (db, version) async {
      await db.execute('''create table cash_out_logs(
            id integer primary key,
            date text,
            ref_number text,
            cash_out_val integer,
            charge integer,
            claimed_by text,
            image_path text)''');

      await db.execute(
          '''create index idx_ref_number on cash_out_logs(ref_number)''');

      await db.execute('''create table search_history(
            id integer primary key,
            history text unique)''');
    });

    return _db!;
  }
}
