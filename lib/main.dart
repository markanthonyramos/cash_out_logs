import 'package:cash_out_logs/cash_out_log_form.dart';
import 'package:cash_out_logs/database_helper.dart';
import 'package:cash_out_logs/see_photo.dart';
import 'package:flutter/material.dart';

import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper().getDb();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      routes: {
        CashOutLogForm.routeName: (context) => CashOutLogForm(),
        SeePhoto.routeName: (context) => SeePhoto()
      },
    );
  }
}
