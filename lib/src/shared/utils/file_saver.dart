import 'file_saver_io.dart' if (dart.library.html) 'file_saver_web.dart';

abstract class FileSaver {
  static Future<void> saveFile(List<int> bytes, String fileName) async {
    await FileSaverImplementation.saveFile(bytes, fileName);
  }
}
