part of cupid;

class StdInputDevice extends InputDevice {
  Stream<String> _stdin;
  StreamSubscription _stdinSubscription;

  Future open() async {
    final c = new StreamController<String>.broadcast();
    _stdin = c.stream.asBroadcastStream();
    _stdinSubscription = stdin.listen((b) {
      c.add(UTF8.decode(b, allowMalformed: true).trim());
    });
  }

  Future<Input> nextInput(_) async {
    stdout.write(InputDevice.prompt.plain);
    try {
      return new Input(await _stdin.first);
    } on ArgumentError {
      return null;
    }
  }

  Future close() {
    return _stdinSubscription.cancel();
  }

  Future rawInput() async {
    return inferType(await _stdin.first);
  }
}
