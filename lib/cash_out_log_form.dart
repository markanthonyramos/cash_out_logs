import 'package:cash_out_logs/cash_out_log.dart';
import 'package:cash_out_logs/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class CashOutLogArgs {
  final int? id;
  final String? date;
  final String? refNumber;
  final int? cashOut;
  final int? charge;
  final String? claimedBy;

  CashOutLogArgs(
      {this.id,
      this.date,
      this.refNumber,
      this.cashOut,
      this.charge,
      this.claimedBy});
}

class CashOutLogForm extends StatefulWidget {
  static const String routeName = '/cash-out-log-form';

  @override
  _CashOutLogFormState createState() => _CashOutLogFormState();
}

class _CashOutLogFormState extends State<CashOutLogForm> {
  late Future<Database> database;
  final _formKey = GlobalKey<FormState>();

  final _dateController = TextEditingController();
  final _refNumberController = TextEditingController();
  final _cashOutController = TextEditingController();
  final _chargeController = TextEditingController();
  final _claimedByController = TextEditingController();

  @override
  void initState() {
    super.initState();
    database = DatabaseHelper().getDb();
  }

  textFieldValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please fill out this field.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CashOutLogArgs?;
    if (args != null) {
      _dateController.text = "${args.date}";
      _refNumberController.text = "${args.refNumber}";
      _cashOutController.text = "${args.cashOut}";
      _chargeController.text = "${args.charge}";
      _claimedByController.text = "${args.claimedBy}";
    }

    return Scaffold(
        appBar: AppBar(title: Text('Form')),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: EdgeInsets.all(15),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (args != null)
                          Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: TextFormField(
                                validator: (val) {
                                  return textFieldValidator(val);
                                },
                                controller: _dateController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Date: Ex. Sep. 10, 2021'),
                              )),
                        Container(
                            padding: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              validator: (val) {
                                return textFieldValidator(val);
                              },
                              controller: _refNumberController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Ref. Number'),
                            )),
                        Container(
                            padding: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              validator: (val) {
                                return textFieldValidator(val);
                              },
                              controller: _cashOutController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Cash Out'),
                            )),
                        Container(
                            padding: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              validator: (val) {
                                return textFieldValidator(val);
                              },
                              controller: _chargeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Charge'),
                            )),
                        Container(
                            child: TextFormField(
                          validator: (val) {
                            return textFieldValidator(val);
                          },
                          controller: _claimedByController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Claimed By'),
                        )),
                        ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (args != null) {
                                  await CashOutLog.updateCashOutLogById(
                                      database,
                                      CashOutLogArgs(
                                          id: args.id,
                                          date: _dateController.text,
                                          refNumber: _refNumberController.text,
                                          cashOut: int.parse(
                                              _cashOutController.text),
                                          charge:
                                              int.parse(_chargeController.text),
                                          claimedBy:
                                              _claimedByController.text));

                                  Navigator.pop(
                                      context, _refNumberController.text);
                                } else {
                                  final int id =
                                      await CashOutLog.insertCashOutLog(
                                          database,
                                          _refNumberController.text,
                                          int.parse(_cashOutController.text),
                                          int.parse(_chargeController.text),
                                          _claimedByController.text);

                                  Navigator.pop(context, id);
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Form has been saved.')));
                              }
                            },
                            child: Text('Save',
                                style: TextStyle(fontWeight: FontWeight.bold)))
                      ])))
        ]));
  }
}
