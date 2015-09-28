part of cupid;

const Map<Symbol, List<int>> _keys = const {
  #up: const [27, 91, 65],
  #left: const [27, 91, 68],
  #right: const [27, 91, 67],
  #down: const [27, 91, 66],
  #enter: const [10],
  #backspace: const [127],
  #tab: const [9],
  #delete: const [27, 91, 51, 126],
};

class TerminalInputDevice implements InputDevice {
  Stream<String> _stdin;
  StreamSubscription _stdinSubscription;
  TerminalPrompt _prompt = new TerminalPrompt();
  bool _open = false;

  Future open() async {
    Console.init();
    final c = new StreamController<String>.broadcast();
    stdin.echoMode = false;
    stdin.lineMode = false;
    _stdin = c.stream.asBroadcastStream();
    _stdinSubscription = stdin.listen((bytes) {
      if (!_open) return;
      _updatePrompt(bytes, () {
        _write('\n');
        c.add(_prompt.flush());
      }, {
        #up: _onUp,
        #left: _onLeft,
        #right: _onRight,
        #down: _onDown,
        #backspace: _onBackspace,
        #tab: _onTab,
        #delete: _onDelete,
      });
    });
  }

  void _onUp() {
    print('UP');
  }

  void _onLeft() {
    _prompt.cursor--;
  }

  void _onRight() {
    _prompt.cursor++;
  }

  void _onDown() {
    print('DOWN');
  }

  void _onBackspace() {
    _prompt.backspace();
  }

  void _onDelete() {
    _prompt.forwardspace();
  }

  void _onTab() {
    print('HELP');
  }

  void _updatePrompt(List<int> bytes, onEnter(),
      Map<Symbol, Function> keyCallbacks) {
    if (_equalList(bytes, _keys[#enter])) onEnter();
    else if (_keys.values.any((k) => _equalList(k, bytes))) {
      keyCallbacks[_keys.keys.firstWhere((s) => _equalList(_keys[s], bytes))]();
      _render();
    } else {
      _prompt.input(UTF8.decode(bytes).replaceAll(new RegExp(
          r'[\u001b\u009b][[()#;?]*(?:[0-9]{1,4}'
          r'(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]'), ''));
      _render();
    }
  }

  bool _equalList(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++)
      if (a[i] != b[i]) return false;
    return true;
  }

  Future<Input> nextInput() async {
    _open = true;
    _render();
    Input returnValue;
    try {
      returnValue = new Input(await _stdin.first);
    } on ArgumentError {
      returnValue = null;
    }
    _open = false;
    return returnValue;
  }

  void _render() {
    Console.moveToColumn(Console.columns);
    Console.eraseLine(1);
    Console.moveToColumn(0);
    _writeOutput(InputDevice.prompt);
    _writeOutput(_prompt.output);
    Console.moveToColumn(InputDevice.prompt.plain.length + 1 + _prompt.cursor);
  }

  Future close() {
    stdin.echoMode = true;
    stdin.lineMode = true;
    return _stdinSubscription.cancel();
  }

  void _writeOutput(Output output) {
    stdout.write(output.ansi);
  }

  void _write(String chars) {
    _writeOutput(new Output(chars));
  }

  void _writeln(String line) {
    _write('$line\n');
  }
}
