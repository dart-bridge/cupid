part of cupid;

IOSink _errorLog = new File('cupid_error.log').openWrite(mode: FileMode.APPEND);

errorHandler(error, StackTrace stack, [Shell shell]) {

  Function printer = print;

  if (shell != null) printer = shell.print;

  String stackString = stack.toString().split('\n').reversed.join('\n');

  String errorString = error.toString().split('\n').join('\n  ');

  String logString = '[${new DateTime.now()}]$stackString\n\n$errorString\n\n';

  _errorLog.add(logString.codeUnits);

//  Console.setTextColor(Color.RED.id);
//  printer(stackString);
  Console.setTextColor(Color.WHITE.id);
  printer('');
  Console.setBackgroundColor(Color.RED.id);
  printer('\n  $errorString\n');
  Console.resetAll();
  printer('');
}

class Program {
  InstanceMirror get _program => reflect(this);

  final Shell shell = new Shell();

  final List<ClosureMirror> _addedCommands = [];

  void displayHelp() {
    Console.setUnderline(true);
    Console.setTextColor(Color.CYAN.id);
    print('\nAvailable commands:\n');
    Console.setUnderline(false);

    _allCommands.forEach((MethodMirror commandMethod) {
      var name = MirrorSystem.getName(commandMethod.simpleName);

      var description = _getHelper(commandMethod).description;

      print('$name\t$description');
    });

    print('exit\tGracefully exit the application');
    print('reload\tRerun the application startup sequence');

    print('\nhelp\tDisplay this message\n');

    Console.resetAll();
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
    list.addAll(_addedCommands.map((m) => m.function));

    return list;
  }

  _initialEnvironment() {
    Console.init();

    stdin.lineMode = false;

    stdin.echoMode = false;

    shell.setUpInput();

    shell.enabled = true;
  }

  _wrapInZone(callback()) {
    runZoned(callback, zoneSpecification: new ZoneSpecification(
        print: (self, parent, zone, message) => shell.print(message)
    ), onError: (e, s) {
      errorHandler(e, s, shell);
      shell.renderInput();
    });
  }

  _attemptBuiltInCommands(args) async {
    switch (args[0]) {
      case 'exit':
        return await exitCommand();

      case 'clear':
        return await _clearCommand();

      case 'reload':
        return await reload();

      case '?':
      case '-?':
      case '--?':
      case 'help':
      case '-h':
      case '--help':
        return await _helpCommand();
    }
    return true;
  }

  bool _isCommandMethod(MethodMirror method) {
    return method.metadata.any((InstanceMirror e) => e.reflectee is Command);
  }

  Future<bool> _attemptProvidedCommands(List<String> args) async {
    args = args.getRange(0, args.length).toList();

    var name = new Symbol(args.removeAt(0));

    if (_program.type.declarations.containsKey(name)) {
      MethodMirror method = _program.type.declarations[name];

      if (_isCommandMethod(method)) {
        await _program.invoke(name, args);
        return false;
      }
    }
    return true;
  }

  Future<bool> _attemptAddedCommands(List<String> args) async {
    for (var closure in _addedCommands) {
      if (_isCommandMethod(closure.function)) {
        await closure.apply(args..removeAt(0));
        return false;
      }
    }
    return true;
  }

  addCommand(Function commandClosure) {
    _addedCommands.add(reflect(commandClosure));
  }

  Future _input(List<String> args) async {
    if (args.isEmpty) return;

    shell.enabled = false;

    if (await _attemptBuiltInCommands(args)) {
      if (await _attemptProvidedCommands(args)) {
        if (await _attemptAddedCommands(args)) {
          Console.setTextColor(Color.RED.id);
          print('Invalid command: ${args[0]}\tEnter "help" for details');
          Console.resetAll();
        }
      }
    }
    shell.enabled = true;
  }

  exitCommand() async {

    await _tearDownProcedure();

    exit(0);
  }

  Future _tearDownProcedure() async {

    Console.eraseLine(1);

    Console.moveToColumn(0);

    await _letTearDown();

    Console.eraseLine(1);

    Console.moveToColumn(0);
  }

  _clearCommand() async {
    shell._clearLine();
    stdout.write('\n' * Console.rows);
    Console.moveCursor(row: 0, column: 0);
    shell.renderInput();
  }

  reload([List<String> args]) async {
    if (args == null) args = [];

    await _tearDownProcedure();

    await Isolate.spawnUri(Platform.script, args, shell.history);
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

    if (_program.type.declarations.containsKey(setUpSymbol)) return await _program
    .invoke(setUpSymbol, []).reflectee;
  }

  _letTearDown() async {
    var setUpSymbol = const Symbol('tearDown');

    if (_program.type.declarations.containsKey(setUpSymbol)) return await _program
    .invoke(setUpSymbol, []).reflectee;
  }

  run(List<String> arguments, dynamic message) async {
    _wrapInZone(() async {

      if (message is List<String>) {
        shell.history.addAll(message);
      }

      await _letSetUp();

      await _initialEnvironment();

      _startListening();

      _input(arguments);
    });
  }
}