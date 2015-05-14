part of cupid;

class Program {
  InstanceMirror get _program => reflect(this);

  Shell shell = new Shell();

  void displayHelp() {
    print('\nAvailable commands:\n');

    _allCommands.forEach((MethodMirror commandMethod) {
      var name = MirrorSystem.getName(commandMethod.simpleName);

      var description = _getHelper(commandMethod).description;

      print('$name\t$description');
    });

    print('exit\tGracefully exit the application');
    print('reload\tRerun the application startup sequence');

    print('\nhelp\tDisplay this message\n');
  }

  Command _getHelper(MethodMirror commandMethod) {
    return (commandMethod.metadata
        .firstWhere((e) => e.reflectee is Command)).reflectee;
  }

  List<MethodMirror> get _allCommands {
    var list = <MethodMirror>[];

    _program.type.declarations
        .forEach((Symbol name, DeclarationMirror declaration) {
      if (declaration is! MethodMirror) return;

      if (_isCommandMethod(declaration)) {
        list.add(declaration);
      }
    });

    return list;
  }

  _initialEnvironment() {
    Console.init();

    stdin.lineMode = false;

    stdin.echoMode = false;

    shell.setUpInput();

    _overridePrint();
  }

  _overridePrint() {
    overridePrintFunction = shell.print;
  }

  _attemptBuiltInCommands(args) async {
    switch (args[0]) {
      case 'exit':
        return await exitCommand();
        break;

      case 'clear':
        return await _clearCommand();
        break;

      case 'reload':
        return await reload();
        break;

      case '?':
      case '-?':
      case '--?':
      case 'help':
      case '-h':
      case '--help':
        return await _helpCommand();
        break;
    }
    return true;
  }

  bool _isCommandMethod(MethodMirror method) {
    return method.metadata.any((InstanceMirror e) => e.reflectee is Command);
  }

  _attemptProvidedCommands(List<String> args) {
    args = args.getRange(0, args.length).toList();

    var name = new Symbol(args.removeAt(0));

    if (_program.type.declarations.containsKey(name)) {
      MethodMirror method = _program.type.declarations[name];

      if (_isCommandMethod(method)) {
        _program.invoke(name, args);
        return;
      }
    }
    return true;
  }

  _input(List<String> args) async {
    if (args.isEmpty) return;

    if (await _attemptBuiltInCommands(args)) {
      if (await _attemptProvidedCommands(args)) {
        print('Invalid command: ${args[0]}');
      }
    }
  }

  exitCommand() async {
    await _letTearDown();

    Console.eraseLine(1);

    Console.moveToColumn(0);

    exit(0);
  }

  _clearCommand() async {
    shell._clearLine();
    stdout.write('\n' * Console.rows);
    Console.moveCursor(row: 0, column: 0);
    shell.renderInput();
  }

  reload([List<String> args]) async {
    if (args == null) args = [];

    await _letTearDown();

    Console.eraseLine(1);

    Console.moveToColumn(0);

    var isolate = await Isolate.spawnUri(Platform.script, args, shell.history);
  }

  _helpCommand() async {
    displayHelp();
  }

  _startListening() {
    shell.output.listen(_input);

    stdin.listen(shell.stdin);

    shell.renderInput();
  }

  _letSetUp() async {
    var setUpSymbol = const Symbol('setUp');

    if (_program.type.declarations.containsKey(setUpSymbol)) return _program
        .invoke(setUpSymbol, []).reflectee;
  }

  _letTearDown() async {
    var setUpSymbol = const Symbol('tearDown');

    if (_program.type.declarations.containsKey(setUpSymbol)) return _program
        .invoke(setUpSymbol, []);
  }

  run(List<String> arguments, dynamic message) async {
    if (message is List<String>) {
      shell.history.addAll(message);
    }

    _initialEnvironment();

    await _letSetUp();

    _startListening();

    arguments.forEach((String arg) {
      _input([arg]);
    });
  }
}
