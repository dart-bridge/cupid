part of cupid;

class Shell {

  final List<String> history = [];

  _Input _currentInput;

  Function prompter = () => '>> ';

  StreamController _outputController = new StreamController<List<String>>();

  Stream get output {
    return _outputController.stream;
  }

  _clearLine() {
    Console.moveToColumn(Console.columns);
    Console.eraseLine(1);
    Console.moveToColumn(0);
  }

  send() {
    print(prompter() + _currentInput.value);

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
    stdout.write(prompter() + _currentInput.value);
    Console.moveToColumn(_currentInput.currentColumn + 1 + prompter().length);
  }

  print(obj) {
    _clearLine();
    stdout.writeln(obj);
    renderInput();
  }

  stdin(List<int> chars) {
    String value = new String.fromCharCodes(chars);

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