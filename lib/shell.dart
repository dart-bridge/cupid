part of cupid;

class Shell {

  final List<String> history = [];

  _Input _currentInput;

  Function prompter = () => '>> ';

  StreamController _outputController = new StreamController<List<String>>();

  bool _enabled = false;

  bool get enabled => _enabled;

  void set enabled(bool val) {
    _enabled = val;
    renderInput();
  }

  Stream get output {
    return _outputController.stream;
  }

  _clearLine() {
    try {
      Console.moveToColumn(Console.columns);
    } on StdoutException {
    }
    Console.eraseLine(1);
    Console.moveToColumn(0);
  }

  send() {
    Console.setTextColor(Color.CYAN.id);
    print(prompter() + _currentInput.value);
    Console.resetAll();

    if (_currentInput.value == '') return;

    var asArgs = _currentInput.value.split(' ');

    asArgs = asArgs.where((s) => s != '');

    _outputController.add(asArgs.toList());

    history.add(_currentInput.value);

    setUpInput();

    renderInput();
  }

  setUpInput([List<String> initialHistory]) {
    var historyBase = history;

    if (initialHistory != null) {

      historyBase = initialHistory;
    }

    _currentInput = new _Input.fromHistory(historyBase);
  }

  renderInput() {
    _clearLine();
    if (_currentInput == null) return;
    Console.setTextColor(Color.CYAN.id);
    stdout.write(prompter() + _currentInput.value);
    Console.resetAll();
    Console.moveToColumn(_currentInput.currentColumn + 1 + prompter().length);
  }

  print(obj) {
    _clearLine();
    stdout.writeln(obj);
    if (enabled) {
      renderInput();
    }
  }

  stdin(List<int> chars) {
    String value = UTF8.decode(chars);

    InputKey keyType = KeyMapper.keyType(chars);

    switch (keyType) {

      case(InputKey.INPUT):
        _currentInput.insert(value);
        break;

      case(InputKey.UP):
        _currentInput.moveUp();
        break;
      case(InputKey.DOWN):
        _currentInput.moveDown();
        break;
      case(InputKey.RIGHT):
        _currentInput.moveRight();
        break;
      case(InputKey.LEFT):
        _currentInput.moveLeft();
        break;
      case(InputKey.BACKSPACE):
        _currentInput.backspace();
        break;
      case(InputKey.RETURN):
        send();
        break;

      default:
        print(chars);
        break;
    }

    renderInput();
  }
}
