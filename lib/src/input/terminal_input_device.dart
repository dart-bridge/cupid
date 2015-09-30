part of cupid;

typedef String TabCompletion(String input);

const Map<Symbol, List<int>> _keys = const {
  #up: const [27, 91, 65],
  #left: const [27, 91, 68],
  #right: const [27, 91, 67],
  #down: const [27, 91, 66],
  #enter: const [10],
  #backspace: const [127],
  #tab: const [9],
  #ctrlX: const [24],
  #delete: const [27, 91, 51, 126],
};

class TerminalInputDevice extends InputDevice {
  Stream<String> _stdin;
  TerminalPrompt _prompt;
  bool _open = false;
  TabCompletion _tabCompletion;
  StreamSubscription _stdinBroadcastSubscription;

  Future open(Stream<List<int>> stdinBroadcast) async {
    File historyFile = new File('.cupid_history');
    if (!await historyFile.exists())
      await historyFile.writeAsString('');
    _prompt = new TerminalPrompt(
        (await historyFile.readAsString()).split('\n'),
        historyFile.openWrite(mode: FileMode.APPEND));
    Console.init();
    final c = new StreamController<String>.broadcast();
    _stdin = c.stream;
    _stdinBroadcastSubscription = stdinBroadcast.listen((bytes) {
      if (!_open) return;
      _updatePrompt(bytes,
          onEnter: () {
            _write('\n');
            c.add(_prompt.flush());
          },
          onCtrlX: () {
            _write('\n');
            c.add('exit');
          },
          keyCallbacks: {
            #up: _onUp,
            #tab: _onTab,
            #left: _onLeft,
            #right: _onRight,
            #down: _onDown,
            #backspace: _onBackspace,
            #delete: _onDelete,
          });
    });
  }

  void _onTab() {
    if (_tabCompletion == null) return;
    _prompt._content = _tabCompletion(_prompt._content);
    _prompt.cursor = _prompt._content.length;
  }

  void _onUp() {
    _prompt.previous();
  }

  void _onDown() {
    _prompt.next();
  }

  void _onLeft() {
    _prompt.cursor--;
  }

  void _onRight() {
    _prompt.cursor++;
  }

  void _onBackspace() {
    _prompt.backspace();
  }

  void _onDelete() {
    _prompt.forwardspace();
  }

  void _updatePrompt(List<int> bytes, {onEnter(), onCtrlX(),
      Map<Symbol, Function> keyCallbacks}) {
    if (_equalList(bytes, _keys[#enter])) onEnter();
    else if (_equalList(bytes, _keys[#ctrlX])) onCtrlX();
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

  Future<Input> nextInput(String tabCompletion(String input)) async {
    _open = true;
    _tabCompletion = tabCompletion;
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

  Future close() async {
    return _stdinBroadcastSubscription.cancel();
  }

  void _writeOutput(Output output) {
    stdout.write(output.ansi);
  }

  void _write(String chars) {
    _writeOutput(new Output(chars));
  }

  Future rawInput() async {
    _prompt._highlightRaw = true;
    final returnValue = inferType((await nextInput(null)).toString());
    _prompt._highlightRaw = false;
    return returnValue;
  }
}
