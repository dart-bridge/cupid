part of cupid;

class SilentInputDevice extends InputDevice {
  Future open(Stream<List<int>> stdinBroadcast) async {}

  Future<Input> nextInput(String tabCompletion(String input)) async {
    return new Completer().future;
  }

  Future close() async {}

  Future rawInput() async {}
}
