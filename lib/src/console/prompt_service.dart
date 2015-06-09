part of cupid;

class PromptService {
  Prompt _prompt = new Prompt();
  Completer _completer;
  bool _enabled = false;
  int __historyCursor = -1;
  final List<String> _history = [];
  String _stash = '';
  ConsoleIoDevice _device;
  StreamSubscription _stdinSubscription;
  bool _highlightInput = true;
  Function _prompter = () => '> ';
  File historyFile = new File('.cupid_history');

  PromptService(ConsoleIoDevice this._device) {
    Console.init();
    stdin.echoMode = false;
    stdin.lineMode = false;
    _stdinSubscription = stdin.map((c) => UTF8.decode(c)).listen(_input);
  }

  int get _historyCursor => __historyCursor;

  void set _historyCursor(int value) {
    __historyCursor = max(-1, min(_history.length - 1, value));
    if (_historyCursor == -1) _prompt.value = _stash;
    else _prompt.value = _history[_historyCursor];
  }

  _renderPrompt() {
    Console.moveToColumn(0);
    stdout.write(_device._colorize('${_prompter()}${_highlightValue()}'));
    _repositionCursor();
  }

  String _highlightValue() {
    if (!_highlightInput) return '<magenta>${_prompt.value}</magenta>';
    var value = _prompt.value
    .replaceFirstMapped(new RegExp(r'^(\w+)'), (m) {
      return '<yellow><bold>${m[1]}</bold>';
    })
    .replaceAllMapped(new RegExp(r'''(--?)(\w+)(?:(=)((['"])([^\4]+)\4|[^\s]+))?'''), (m) {
      var dashes = m[1];
      var key = m[2];
      var equals = m[3] == null ? '' : m[3];
      var value = m[4] == null ? '' : m[4];
      var valueColor = new RegExp(r'^[0-9.]+$').hasMatch(value) ? 'magenta' : 'green';
      return '</yellow><gray>$dashes</gray><red>$key</red><gray>$equals</gray><$valueColor><italic>$value</italic></$valueColor><yellow>';
    });
    return '$value</yellow>';
  }

  int _prompterLength() {
    return (_prompter() as String).replaceAll(new RegExp(r'</?[^>]+>'), '').length;
  }

  _clearPrompt() {
    Console.moveToColumn(_prompterLength() + _prompt.value.length + 1);
    Console.eraseLine(1);
    Console.moveToColumn(0);
  }

  _render() {
    _clearPrompt();
    _renderPrompt();
  }

  _repositionCursor() {
    Console.moveToColumn(_prompterLength() + _prompt.cursor + 1);
  }

  _input(String char) {
    if (!_enabled) return null;
    else if (char == KeyCode.UP) _historyUp();
    else if (char == KeyCode.DOWN) _historyDown();
    else if (char == KeyCode.LEFT) {
      _prompt.cursor--;
      return _repositionCursor();
    }
    else if (char == KeyCode.RIGHT) {
      _prompt.cursor++;
      return _repositionCursor();
    }
    else if (char == new String.fromCharCodes([127])) _prompt.backspace();
    else if (char == '\n') return _send();
    else _prompt.append(char.replaceAll('\n', ' '));
    if (_historyCursor == -1) _stash = _prompt.value;
    _render();
  }

  _historyUp() {
    _clearPrompt();
    _historyCursor++;
  }

  _historyDown() {
    _clearPrompt();
    _historyCursor--;
  }

  _send() {
    if (_prompt.value != '')
      _history.insert(0, _prompt.value);
    _completer.complete(_prompt.value);
    stdout.write('\n');
    _historyCursor = -1;
    _stash = '';
  }

  Future<String> input() async {
    _completer = new Completer();
    _enabled = true;
    _renderPrompt();
    var updatingPrompter = new Stream.periodic(const Duration(seconds: 1)).listen((_) => _render());
    var input = await _completer.future;
    await updatingPrompter.cancel();
    var sink = historyFile.openWrite(mode: APPEND)
      ..writeln(input);
      await sink.close();
    _enabled = false;
    _clearPrompt();
    _prompt.clear();
    _clearPrompt();
    return input;
  }

  void output(String output) {
    if (_enabled) _clearPrompt();
    stdout.write(output);
    if (_enabled) _renderPrompt();
  }

  Future close() {
    return _stdinSubscription.cancel();
  }

  Future<String> rawInput() async {
    _highlightInput = false;
    String raw = await input();
    _highlightInput = true;
    return raw;
  }

  Future loadHistory() async {
    if (await historyFile.exists())
      _history.addAll((await historyFile.readAsLines()).reversed);
  }
}
