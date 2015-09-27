part of cupid;

class TerminalInputDevice implements InputDevice {
  Stream<String> _stdin;
  StreamSubscription _stdinSubscription;

  Future open() async {
    final c = new StreamController<String>.broadcast();
    _stdin = c.stream.asBroadcastStream();
    _stdinSubscription = stdin.listen((b) {
      c.add(UTF8.decode(b).trim());
    });
  }

  Future<Input> nextInput() async {
    stdout.write(InputDevice.prompt.ansi);
    try {
      return new Input(await _stdin.first);
    } on ArgumentError {
      return null;
    }
  }

  Future close() {
    return _stdinSubscription.cancel();
  }
}
