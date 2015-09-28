part of cupid;

class TerminalPrompt {
  String _content = '';
  int _cursor = 0;

  Output get output {
    if (_content.startsWith(':'))
      return new Output('<gray>:</gray>${_content.substring(1)}');
    final content = _content
    .replaceAllMapped(new RegExp(r'^\w+'), (m) => '<bold>${m[0]}</bold>')
    ;
    return new Output('<yellow>$content</yellow>');
  }

  int set cursor(int value) {
    _cursor = max(0, min(value, _content.length));
    return cursor;
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
}
