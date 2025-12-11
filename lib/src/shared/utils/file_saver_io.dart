import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileSaverImplementation {
  static Future<void> saveFile(List<int> bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(path)], text: 'Aquí tienes tu reporte.');
  }
}
