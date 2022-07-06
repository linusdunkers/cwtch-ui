class FileDownloadProgress {
  int chunksDownloaded = 0;
  int chunksTotal = 1;
  bool complete = false;
  bool gotManifest = false;
  bool interrupted = false;
  String? downloadedTo;
  DateTime? timeStart;
  DateTime? timeEnd;
  DateTime? requested;

  FileDownloadProgress(this.chunksTotal, this.timeStart);

  double progress() {
    return 1.0 * chunksDownloaded / chunksTotal;
  }
}

String prettyBytes(int bytes) {
  if (bytes > 1000000000) {
    return (1.0 * bytes / 1000000000).toStringAsFixed(1) + " GB";
  } else if (bytes > 1000000) {
    return (1.0 * bytes / 1000000).toStringAsFixed(1) + " MB";
  } else if (bytes > 1000) {
    return (1.0 * bytes / 1000).toStringAsFixed(1) + " kB";
  } else {
    return bytes.toString() + " B";
  }
}
