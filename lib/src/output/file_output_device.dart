part of cupid;

class FileOutputDevice implements OutputDevice {
  final IOSink _log;

  FileOutputDevice(String file)
      : _log = new File(file).openWrite(mode: APPEND);

  void output(Output output) {
    _log.write(output.plain);
  }

  Future close() {
    return _log.close();
  }
}
