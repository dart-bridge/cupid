part of cupid;

class Prompt {
  String _value = '';
  int _cursor = 0;

  String get value => _value;

  void set value(String value) {
    _value = value;
    cursor = value.length;
  }

  void append(String char) {
    _value = value.substring(0, cursor) + char + value.substring(cursor);
    cursor += char.length;
  }

  int get cursor => _cursor;

  void set cursor(int value) {
    _cursor = max(0, min(_value.length, value));
  }

  void backspace() {
    if (cursor == 0) return;
    _value = value.substring(0, cursor - 1)
    + value.substring(cursor);
    cursor--;
  }

  void clear() {
    value = '';
  }
}
