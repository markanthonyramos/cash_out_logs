import 'dart:io';

import 'package:cash_out_logs/cash_out_log.dart';
import 'package:cash_out_logs/database_helper.dart';
import 'package:cash_out_logs/see_photo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import 'cash_out_log_form.dart';
import 'image_helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Database> database;
  XFile? imagePicked;
  int id = 0;

  @override
  void initState() {
    super.initState();
    database = DatabaseHelper().getDb();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CashOutLog>>(
        future: CashOutLog.getAllCashOutLogs(database),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                    leading: IconButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                            context, CashOutLogForm.routeName) as int?;

                        if (result != null) {
                          setState(() {
                            id = result;
                          });
                        }
                      },
                      icon: Icon(Icons.add),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () async {
                            final int search = await showSearch(
                                context: context,
                                delegate: _HomeSearchDelegate());

                            setState(() {
                              id = search;
                            });
                          },
                          icon: Icon(Icons.search))
                    ]),
                body: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Card(
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: Column(children: [
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 5),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: Text(
                                                "Ref #: ${snapshot.data![i].refNumber}",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextWidgetWrapper(
                                                          value:
                                                              'Date: ${snapshot.data![i].date}'),
                                                      TextWidgetWrapper(
                                                          value:
                                                              "Cash Out: P${snapshot.data![i].cashOutVal}"),
                                                    ]),
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TextWidgetWrapper(
                                                              value:
                                                                  "Charge: P${snapshot.data![i].charge}"),
                                                          TextWidgetWrapper(
                                                              value:
                                                                  "Claimed By: ${snapshot.data![i].claimedBy}"),
                                                        ])),
                                              ])
                                        ])),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.075,
                                        child: PopupMenuButton<int>(
                                            onSelected: (int val) async {
                                          final int cashOutLogId =
                                              snapshot.data![i].id;
                                          String? imagePath =
                                              snapshot.data![i].imagePath;

                                          switch (val) {
                                            case 0:
                                              final result =
                                                  await Navigator.pushNamed(
                                                      context,
                                                      CashOutLogForm.routeName,
                                                      arguments: CashOutLogArgs(
                                                          id: cashOutLogId,
                                                          date: snapshot
                                                              .data![i].date,
                                                          refNumber: snapshot
                                                              .data![i]
                                                              .refNumber,
                                                          cashOut: snapshot
                                                              .data![i]
                                                              .cashOutVal,
                                                          charge: snapshot
                                                              .data![i].charge,
                                                          claimedBy: snapshot
                                                              .data![i]
                                                              .claimedBy)) as String?;

                                              if (result != null) {
                                                setState(() {
                                                  id = int.parse(result);
                                                });
                                              }
                                              break;
                                            case 1:
                                              if (snapshot.data![i].imagePath !=
                                                  null) {
                                                imagePath = snapshot
                                                    .data![i].imagePath!;

                                                Navigator.pushNamed(
                                                    context, SeePhoto.routeName,
                                                    arguments: SeePhotoArgs(
                                                        imagePath: imagePath));
                                              }
                                              break;
                                            case 2:
                                              final image =
                                                  await ImageHelper.addAPhoto(
                                                      database, cashOutLogId);

                                              if (image != null) {
                                                setState(() {
                                                  imagePicked = image;
                                                });
                                              }
                                              break;
                                            case 3:
                                              final image =
                                                  await ImageHelper.takeAPhoto(
                                                      database, cashOutLogId);

                                              if (image != null) {
                                                setState(() {
                                                  imagePicked = image;
                                                });
                                              }
                                              break;
                                            case 4:
                                              if (snapshot.data![i].imagePath !=
                                                  null) {
                                                imagePath = snapshot
                                                    .data![i].imagePath!;

                                                await ImageHelper.deleteImage(
                                                    File(imagePath));
                                              }

                                              final int result =
                                                  await CashOutLog
                                                      .deleteCashOutLogById(
                                                          database,
                                                          cashOutLogId);

                                              setState(() {
                                                id = result;
                                              });
                                              break;
                                          }
                                        }, itemBuilder: (BuildContext context) {
                                          final String? imagePath =
                                              snapshot.data![i].imagePath;

                                          return [
                                            PopupMenuItem(
                                                value: 0,
                                                child: Row(children: [
                                                  Icon(Icons.update),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12),
                                                      child: Text("Update"))
                                                ])),
                                            if (imagePath != null)
                                              PopupMenuItem(
                                                  value: 1,
                                                  child: Row(children: [
                                                    Icon(Icons.photo),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 12),
                                                        child:
                                                            Text("See photo"))
                                                  ])),
                                            PopupMenuItem(
                                                value: 2,
                                                child: Row(children: [
                                                  Icon(Icons
                                                      .add_photo_alternate),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12),
                                                      child: Text(
                                                          imagePath == null
                                                              ? "Add a photo"
                                                              : "Change Photo"))
                                                ])),
                                            if (imagePath == null)
                                              PopupMenuItem(
                                                  value: 3,
                                                  child: Row(children: [
                                                    Icon(Icons.add_a_photo),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 12),
                                                        child: Text(
                                                            "Take a photo"))
                                                  ])),
                                            PopupMenuItem(
                                                value: 4,
                                                child: Row(children: [
                                                  Icon(Icons.delete),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12),
                                                      child: Text("Delete"))
                                                ]))
                                          ];
                                        }))
                                  ])));
                    }));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class TextWidgetWrapper extends StatelessWidget {
  final String value;

  TextWidgetWrapper({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.5), child: Text(value));
  }
}

class _HomeSearchDelegate extends SearchDelegate {
  final Future<Database> database = DatabaseHelper().getDb();
  List<Map> _data = [];
  List<Map> _history = [];

  Future<void> getData() async {
    final Database db = await database;
    _data = await db.rawQuery("select ref_number from cash_out_logs");
  }

  Future<void> getHistory() async {
    final Database db = await database;
    _history = await db.rawQuery("select * from search_history");
  }

  Future<void> getBoth() async {
    await getHistory();
    await getData();
  }

  Future<List<CashOutLog>> getResults(String refNumber) async {
    final db = await database;

    final isRefNumberExist = await db
        .rawQuery("select id from search_history where history='$refNumber'");

    if (isRefNumberExist.length == 0) {
      await db.rawInsert(
          "insert into search_history(history) values('$refNumber')");
    }

    final query = await db.rawQuery(
        'select * from cash_out_logs where ref_number like "$refNumber%"');

    if (query.length == 0) return [];

    return CashOutLog.parseCashOutLogListMap(query);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, 0);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    late List _suggestions;

    return FutureBuilder(
        future: getBoth(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _suggestions = query.isEmpty
                ? _history
                : _data
                    .where((element) =>
                        element["ref_number"].toString().startsWith(query))
                    .toList();

            return ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (BuildContext context, int i) {
                  return ListTile(
                      onTap: () async {
                        final Database db = await database;

                        query = query.isNotEmpty
                            ? _suggestions[i]['ref_number']
                            : _suggestions[i]['history'];

                        final isRefNumberExist = await db.rawQuery(
                            "select id from search_history where history='$query'");

                        if (isRefNumberExist.length == 0) {
                          await db.rawInsert(
                              "insert into search_history(history) values('$query')");
                        }

                        showResults(context);
                      },
                      leading: Icon(query.isEmpty ? Icons.history : null),
                      title: Text(query.isEmpty
                          ? _suggestions[i]['history']
                          : _suggestions[i]['ref_number'].toString()),
                      trailing: query.isEmpty
                          ? IconButton(
                              onPressed: () async {
                                final Database db = await database;

                                await db.rawDelete(
                                    "delete from search_history where id=${_history[i]['id']}");

                                showResults(context);
                                showSuggestions(context);
                              },
                              icon: Icon(Icons.clear))
                          : Icon(Icons.youtube_searched_for));
                });
          }

          return Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
          child: Text("No log found.", style: TextStyle(fontSize: 16)));
    }

    return FutureBuilder<List<CashOutLog>>(
        future: getResults(query),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.length == 0) {
              return Center(
                  child: Text("No log found.", style: TextStyle(fontSize: 16)));
            }

            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int i) {
                  return Card(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: Column(children: [
                                      Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Text(
                                            "Ref #: ${snapshot.data![i].refNumber}",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextWidgetWrapper(
                                                      value:
                                                          'Date: ${snapshot.data![i].date}'),
                                                  TextWidgetWrapper(
                                                      value:
                                                          "Cash Out: P${snapshot.data![i].cashOutVal}"),
                                                ]),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextWidgetWrapper(
                                                      value:
                                                          "Charge: P${snapshot.data![i].charge}"),
                                                  TextWidgetWrapper(
                                                      value:
                                                          "Claimed By: ${snapshot.data![i].claimedBy}"),
                                                ]),
                                          ])
                                    ])),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.075,
                                    child: PopupMenuButton<int>(
                                        onSelected: (int val) async {
                                      final int cashOutLogId =
                                          snapshot.data![i].id;
                                      final String? imagePath =
                                          snapshot.data![i].imagePath;

                                      switch (val) {
                                        case 0:
                                          final refNumber =
                                              await Navigator.pushNamed(context,
                                                  CashOutLogForm.routeName,
                                                  arguments: CashOutLogArgs(
                                                      id: cashOutLogId,
                                                      date: snapshot
                                                          .data![i].date,
                                                      refNumber: snapshot
                                                          .data![i].refNumber,
                                                      cashOut: snapshot
                                                          .data![i].cashOutVal,
                                                      charge: snapshot
                                                          .data![i].charge,
                                                      claimedBy: snapshot
                                                          .data![i]
                                                          .claimedBy)) as String;

                                          query = refNumber;
                                          break;
                                        case 1:
                                          if (imagePath != null) {
                                            Navigator.pushNamed(
                                                context, SeePhoto.routeName,
                                                arguments: SeePhotoArgs(
                                                    imagePath: imagePath));
                                          }
                                          break;
                                        case 2:
                                          await ImageHelper.addAPhoto(
                                              database, cashOutLogId);

                                          showSuggestions(context);
                                          showResults(context);
                                          break;
                                        case 3:
                                          await ImageHelper.takeAPhoto(
                                              database, cashOutLogId);

                                          showSuggestions(context);
                                          showResults(context);
                                          break;
                                        case 4:
                                          if (imagePath != null) {
                                            await ImageHelper.deleteImage(
                                                File(imagePath));
                                          }

                                          await CashOutLog.deleteCashOutLogById(
                                              database, cashOutLogId);

                                          showSuggestions(context);
                                          showResults(context);
                                          break;
                                      }
                                    }, itemBuilder: (BuildContext context) {
                                      final String? imagePath =
                                          snapshot.data![i].imagePath;

                                      return [
                                        PopupMenuItem(
                                            value: 0,
                                            child: Row(children: [
                                              Icon(Icons.update),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 12),
                                                  child: Text("Update"))
                                            ])),
                                        if (imagePath != null)
                                          PopupMenuItem(
                                              value: 1,
                                              child: Row(children: [
                                                Icon(Icons.photo),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: Text("See photo"))
                                              ])),
                                        PopupMenuItem(
                                            value: 2,
                                            child: Row(children: [
                                              Icon(Icons.add_photo_alternate),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 12),
                                                  child: Text(imagePath == null
                                                      ? "Add a photo"
                                                      : "Change Photo"))
                                            ])),
                                        if (imagePath == null)
                                          PopupMenuItem(
                                              value: 3,
                                              child: Row(children: [
                                                Icon(Icons.add_a_photo),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: Text("Take a photo"))
                                              ])),
                                        PopupMenuItem(
                                            value: 4,
                                            child: Row(children: [
                                              Icon(Icons.delete),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 12),
                                                  child: Text("Delete"))
                                            ]))
                                      ];
                                    }))
                              ])));
                });
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}
