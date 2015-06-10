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

  void autocomplete(List<String> commands, Program program) {
    var autocompletable = commands.where((c) => c.startsWith(value)).toList();
    if (autocompletable.length == 0) return null;
    if (autocompletable.length == 1) return value = autocompletable[0];
    String commonBeginning = _commonBeginning(autocompletable);
    if (commonBeginning == value) program.execute(new Input(['help']));
    else value = commonBeginning;
    return null;
  }

  String _commonBeginning(Iterable<String> all) {
    var longest = _longestOf(all);
    var out = '';
    for (var i = 0; i<longest.length;i++) {
      var char = longest[i];
      if (all.every((s) => s[i] == char))
        out += char;
      else return out;
    }
    return out;
  }

  String _longestOf(Iterable<String> all) {
    return (all.toList()..sort((String a, String b) => a.length.compareTo(b.length))).first;
  }
}
