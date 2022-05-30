import 'package:camera/camera.dart';
import 'package:cash_out_logs/cash_out_log.dart';
import 'package:cash_out_logs/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TakeAPhotoArgs {
  final int id;

  TakeAPhotoArgs({required this.id});
}

class TakeAPhoto extends StatefulWidget {
  static const String routeName = '/Take-a-photo';

  final CameraDescription camera;

  TakeAPhoto({Key? key, required this.camera}) : super(key: key);

  @override
  _TakeAPhotoState createState() => _TakeAPhotoState();
}

class _TakeAPhotoState extends State<TakeAPhoto> {
  late CameraController _controller;
  late Future<Database> database;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.ultraHigh);
    database = DatabaseHelper().getDb();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TakeAPhotoArgs;

    return FutureBuilder(
        future: _controller.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                backgroundColor: Colors.white,
                body: CameraPreview(_controller),
                floatingActionButton: Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: FloatingActionButton(
                      onPressed: () async {
                        try {
                          await _controller.initialize();
                          final XFile image = await _controller.takePicture();

                          final String imagePath = join(
                              (await getExternalStorageDirectory())!
                                  .path
                                  .split('Android')[0],
                              'Pictures/${image.name}');

                          await image.saveTo(imagePath);

                          final int id = await CashOutLog.updateImagePathById(
                              database, imagePath, args.id);

                          Navigator.pop(context, id);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Picture saved successfully.')));
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Icon(Icons.camera),
                    )),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
