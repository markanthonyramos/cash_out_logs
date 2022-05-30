import 'package:cash_out_logs/cash_out_log_form.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class CashOutLog {
  final int id;
  final String date;
  final String refNumber;
  final int cashOutVal;
  final int charge;
  final String claimedBy;
  final String? imagePath;

  CashOutLog(
      {required this.id,
      required this.date,
      required this.refNumber,
      required this.cashOutVal,
      required this.charge,
      required this.claimedBy,
      this.imagePath});

  Map toMap() {
    return {
      'id': id,
      'date': date,
      'ref_number': refNumber,
      'cash_out_val': cashOutVal,
      'charge': charge,
      'claimedBy': claimedBy,
      'imagePath': imagePath
    };
  }

  static List<CashOutLog> parseCashOutLogListMap(List<Map> queryResult) {
    return queryResult.map((q) {
      return CashOutLog(
          id: q['id'],
          date: q['date'],
          refNumber: q['ref_number'],
          cashOutVal: q['cash_out_val'],
          charge: q['charge'],
          claimedBy: q['claimed_by'],
          imagePath: q['image_path']);
    }).toList();
  }

  static Future<int> insertCashOutLog(
      Future<Database> database,
      String refNumberParam,
      int cashOutParam,
      int chargeParam,
      String claimedByParam) async {
    final db = await database;
    final now = DateTime.now();
    final formatter = DateFormat('yMMMd');

    return await db.rawInsert('''insert into
                                  cash_out_logs(date, ref_number, cash_out_val, charge, claimed_by)
                                values(
                                  "${formatter.format(now)}",
                                  $refNumberParam,
                                  $cashOutParam,
                                  $chargeParam,
                                  "$claimedByParam"
                                )''');
  }

  static Future<List<CashOutLog>> getAllCashOutLogs(
      Future<Database> database) async {
    final db = await database;

    final query = await db.rawQuery('select * from cash_out_logs');

    return CashOutLog.parseCashOutLogListMap(query);
  }

  static Future<int> updateCashOutLogById(
      Future<Database> database, CashOutLogArgs args) async {
    final Database db = await database;

    return await db.rawUpdate('''update 
            cash_out_logs 
          set 
            date="${args.date}",
            ref_number="${args.refNumber}",
            cash_out_val=${args.cashOut},
            charge=${args.charge},
            claimed_by="${args.claimedBy}"
          where
            id=${args.id}''');
  }

  static Future<int> updateImagePathById(
      Future<Database> database, String imagePath, int id) async {
    final Database db = await database;

    return await db.rawUpdate(
        'update cash_out_logs set image_path="$imagePath" where id=$id');
  }

  static Future<int> deleteCashOutLogById(
      Future<Database> database, int id) async {
    final db = await database;

    return await db.rawDelete('delete from cash_out_logs where id=$id');
  }
}
