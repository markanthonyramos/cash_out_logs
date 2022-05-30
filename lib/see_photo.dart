import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SeePhotoArgs {
  final String imagePath;

  SeePhotoArgs({required this.imagePath});
}

class SeePhoto extends StatelessWidget {
  static const String routeName = "/see-photo";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as SeePhotoArgs;

    return Scaffold(
        appBar: AppBar(title: Text("Picture")),
        body: Image.file(File(args.imagePath)));
  }
}
