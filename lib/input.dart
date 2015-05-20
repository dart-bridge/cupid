part of cupid;

class _Input {
  List<String> _lines;

  int _currentLine = 0;

  get currentLine => _currentLine;

  set currentLine(val) {
    _currentLine = max(0, min(_lines.length - 1, val));
  }

  int _currentColumn = 0;

  get currentColumn => _currentColumn;

  set currentColumn(val) {
    _currentColumn = max(0, min(value.length, val));
  }

  _Input.fromHistory(List<String> history) {
    _lines = history.getRange(0, history.length).toList().reversed.toList();

    _lines.insert(0, '');
  }

  String get value {
    return _lines[currentLine];
  }

  set value(val) {
    _lines[currentLine] = val;
  }

  void insert(String val) {
    value = value.substring(0, currentColumn) +
        val +
        value.substring(currentColumn);

    currentColumn += val.length;
  }

  void moveUp() {
    currentLine++;
    currentColumn = value.length;
  }

  void moveDown() {
    currentLine--;
    currentColumn = value.length;
  }

  void moveRight() {
    currentColumn++;
  }

  void moveLeft() {
    currentColumn--;
  }

  void backspace() {
    if (value == '') return;

    value =
        value.substring(0, currentColumn - 1) + value.substring(currentColumn);
    currentColumn--;
  }
}
