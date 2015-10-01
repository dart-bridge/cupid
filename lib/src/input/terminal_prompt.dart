part of cupid;

class TerminalPrompt {
  int _cursor = 0;
  final List<String> _history;
  final IOSink _historyFile;
  List<String> _workingHistory;
  int _historyCursor = 0;
  bool _highlightRaw = false;

  TerminalPrompt(List<String> history, [IOSink this._historyFile])
      : _history = []..addAll(history.reversed),
        _workingHistory = []..addAll(history.reversed) {
    if (_history[0] != '') {
      _history.insert(0, '');
      _workingHistory.insert(0, '');
    }
  }

  String get _content => _workingHistory[_historyCursor];

  set _content(String value) => _workingHistory[_historyCursor] = value;

  Output get output {
    if (_highlightRaw) return new Output('<cyan>$_content</cyan>');
    if (_content.startsWith(':'))
      return new Output('<gray>:</gray>${_content.substring(1)}');
    final content = _content
        .replaceAllMapped(new RegExp(r'^\w+'), (m) => '<bold>${m[0]}</bold>')
    ;
    return new Output('<yellow>$content</yellow>');
  }

  void set cursor(int value) {
    _cursor = max(0, min(value, _content.length));
  }

  int get cursor => _cursor;

  void input(String input) {
    _content = _content.substring(0, cursor)
        + input
        + _content.substring(cursor);
    cursor += input.length;
  }

  String flush() {
    final flushed = _content;
    _content = '';
    cursor = 0;
    _historyCursor = 0;
    if (flushed != '') {
      _history.insert(0, flushed);
      _workingHistory = _history.toList()
        ..insert(0, '');
      _historyFile?.writeln(flushed);
    }
    return flushed;
  }

  void backspace() {
    if (cursor == 0) return;
    _content = _content.substring(0, cursor - 1) + _content.substring(cursor);
    cursor--;
  }

  void forwardspace() {
    if (cursor == _content.length) return;
    _content =
        _content.substring(0, cursor) + _content.substring(cursor + 1);
  }

  void previous() {
    if (_historyCursor == _workingHistory.length - 1) return;
    _historyCursor++;
    _cursor = _content.length;
  }

  void next() {
    if (_historyCursor == 0) return;
    _historyCursor--;
    _cursor = _content.length;
  }
}
