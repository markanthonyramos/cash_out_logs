import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'cash_out_log.dart';

class ImageHelper {
  static Future takeAPhoto(Future<Database> database, int id) async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (image != null) {
      final String imagePath = join(
          (await getExternalStorageDirectory())!.path.split('Android')[0],
          'Pictures/${image.name}');

      await image.saveTo(imagePath);

      await CashOutLog.updateImagePathById(database, imagePath, id);

      return image;
    }

    return null;
  }

  static Future addAPhoto(Future<Database> database, int id) async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      final String imagePath = join(
          (await getExternalStorageDirectory())!.path.split('Android')[0],
          'Pictures/${image.name}');

      await image.saveTo(imagePath);

      await CashOutLog.updateImagePathById(database, imagePath, id);

      return image;
    }

    return null;
  }

  static Future<void> deleteImage(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print(e);
    }
  }
}
