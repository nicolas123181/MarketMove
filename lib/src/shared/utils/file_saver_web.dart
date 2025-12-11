import 'dart:html' as html;

class FileSaverImplementation {
  // Static lock to prevent duplicate downloads
  static bool _isDownloading = false;
  static DateTime? _lastDownload;

  static Future<void> saveFile(List<int> bytes, String fileName) async {
    // Prevent duplicate downloads within 3 seconds
    final now = DateTime.now();
    if (_isDownloading) {
      print('FileSaver: Download blocked - already in progress');
      return;
    }
    if (_lastDownload != null && now.difference(_lastDownload!).inSeconds < 3) {
      print('FileSaver: Download blocked - too soon after last download');
      return;
    }

    _isDownloading = true;
    _lastDownload = now;

    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body!.children.add(anchor);
      anchor.click();

      // Add small delay before cleanup
      await Future.delayed(const Duration(milliseconds: 100));

      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      print('FileSaver: Successfully downloaded $fileName');
    } finally {
      // Reset lock after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        _isDownloading = false;
      });
    }
  }
}
