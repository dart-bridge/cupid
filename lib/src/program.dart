part of cupid;

typedef Future Invoker(List positional, Map<Symbol, dynamic> named);

class Program {
  final Shell _shell;
  final Map<Symbol, Invoker> _commands = {};
  final List<MethodMirror> _commandDeclarations = [];

  Program([Shell shell])
      : _shell = shell ?? new Shell() {
    _setUpNativeCommands();
  }

  void _setUpNativeCommands() {
    reflect(this).type.instanceMembers.values
        .where((m) => m.metadata.any((i) => i.reflectee is Command))
        .forEach((MethodMirror m) => addCommand(reflect(this)
        .getField(m.simpleName)
        .reflectee));
  }

  Future run([String bootArguments]) async {
    await setUp();
    if (bootArguments != null)
      await executeAll(bootArguments
          .split(',')
          .where((a) => a.trim() != '')
          .map((a) => new Input(a.trim())))
          .forEach((o) => o != null ? _shell._outputDevice.output : null);
    return _shell.run(execute, this._tabCompletion);
  }

  Future<Output> execute(Input input) async {
    if (input.toString().startsWith(':'))
      return _executeExternal(input.toString().substring(1));
    if (!_commands.containsKey(input.command))
      throw new UnknownCommandException(input);
    final command = _commands[input.command];
    try {
      final returnValue = await command(
          input.positionalArguments, input.namedArguments);
      if (returnValue == null)
        return null;
      return new Output('$returnValue');
    } on NoSuchMethodError {
      throw new CommandMismatchException(input);
    }
  }

  Future _executeExternal(String command) async {
    final args = command.split(' ');
    final process = await Process.start(args.removeAt(0), args);
    await process.stdout.map(UTF8.decode).listen(stdout.write).asFuture();
    final exitCode = await process.exitCode;
    if (exitCode != 0)
      printDanger('Exited with exit code $exitCode!');
  }

  Stream<Output> executeAll(Iterable<Input> inputs) async* {
    for (final input in inputs)
      yield await execute(input);
  }

  Future setUp() async {}

  Future tearDown() async {}

  void addCommand(command) {
    ClosureMirror method = reflect(command);
    if (_isRestMethod(method))
      _commands[method.function.simpleName] =
          (p, n) => method
          .apply([p], n)
          .reflectee;
    else
      _commands[method.function.simpleName] =
          (p, n) => method
          .apply(p, n)
          .reflectee;
    _commandDeclarations.add(method.function);
  }

  bool _isRestMethod(ClosureMirror method) {
    return method.function.parameters
        .where((p) => !p.isNamed)
        .length == 1
        && method.function.parameters[0].type.isSubtypeOf(reflectType(List));
  }

  Future ask(Question question) async {
    print('\n<underline><yellow>${question.sentence}</yellow></underline>');
    final input = await _shell._inputDevice.rawInput();
    print('');
    try {
      question.validate(input);
    } catch (e) {
      printDanger(e.toString());
      return ask(question);
    }
    return input;
  }

  void print(anything) {
    _shell._outputDevice.output(
        new Output('$anything\n'));
  }

  void printInfo(anything) => print('<blue>$anything</blue>');

  void printDanger(anything) => print('<red>$anything</red>');

  void printWarning(anything) => print('<yellow>$anything</yellow>');

  void printAccomplishment(anything) => print('<green>$anything</green>');

  // Built in commands
  @Command('Exit the program')
  Future exit() async {
    await _shell.stop();
    await tearDown();
  }

  @Command('Show help screen')
  help([@Option('Search for help') String term]) {
    if (term == null)
      _helpAll();
    else if (_commands.keys.any((s) => MirrorSystem.getName(s) == term))
      _helpCommand(term);
    else
      _narrow(term);
  }

  void _helpAll() {
    print('''
<underline><yellow>Available commands:</yellow></underline>

${_commandDeclarations.map(_describeCommand).map((f) => '  $f').join('\n')}
    '''.trim() + '\n');
  }

  String _describeCommand(MethodMirror command) {
    final List<String> parts = [];
    parts.add('<yellow>${MirrorSystem.getName(command.simpleName)}</yellow>');
    if (command.parameters.isNotEmpty)
      parts.add(command.parameters.map(_describePositional).join(' '));
    return parts.join(' ');
  }

  String _describePositional(ParameterMirror param) {
    var description =
    '<cyan>${MirrorSystem.getName(param.simpleName)}</cyan>='
        '<gray>${param.type.reflectedType}';
    if (param.isNamed)
      description = '--$description';
    else if (param.isOptional)
      description = '[$description]';
    return '<gray>$description</gray>';
  }

  void _helpCommand(String command) {
    _narrow(command);
  }

  void _narrow(String term) {
    print(_commandDeclarations
        .where((m) => MirrorSystem.getName(m.simpleName).startsWith(term))
        .map(_describeCommand)
        .join('\n'));
  }

  @Command('Exit and restart the program')
  Future reload([@Option(
      'Boot arguments for the new instance') List<String> arguments]) async {
    await tearDown();
    final args = arguments ?? [];
    final port = new ReceivePort();
    await Isolate.spawnUri(
        Platform.script,
        args,
        null,
        onExit: port.sendPort);
    await port.first;
    await _shell.stop();
  }

  String _tabCompletion(String input) {
    if (input.contains(' ')) return input;
    if (input == '' || _hasCommand(input)) {
      print('');
      help(input);
      return input;
    }
    if (_matchesSingleCommand(input)) {
      print('');
      final completed = _matchingCommands(input).first;
      help(completed);
      return completed;
    }
    if (_matchesMultipleCommnds(input)) {
      print('');
      help(input);
      return _commonBeginning(input);
    }
    return input;
  }

  bool _hasCommand(String input) {
    return _commands.keys.any((s) => MirrorSystem.getName(s) == input);
  }

  bool _matchesSingleCommand(String input) {
    return _matchingCommands(input).length == 1;
  }

  Iterable<String> _matchingCommands(String input) {
    return _commands.keys
        .map(MirrorSystem.getName)
        .where((String n) => n.startsWith(input));
  }

  bool _matchesMultipleCommnds(String input) {
    return _matchingCommands(input).length > 1;
  }

  String _commonBeginning(String input) {
    return _matchingCommands(input).reduce((a, b) => _commonBeginningOf(a, b));
  }

  String _commonBeginningOf(String a, String b) {
    var aggregate = '';
    for (var i = 0; i < a.length; i++) {
      if (a[i] == b[i])
        aggregate += a[i];
      else return aggregate;
    }
    return aggregate;
  }
}

class InputException implements Exception {
  final Input input;

  InputException(Input this.input);

  toString() => 'InputException: Invalid input [$input]';
}

class UnknownCommandException extends InputException {
  UnknownCommandException(Input input) : super(input);

  toString() =>
      'UnknownCommandException: No such command [${MirrorSystem.getName(
          input.command)}]';
}

class CommandMismatchException extends InputException {
  CommandMismatchException(Input input) : super(input);

  toString() =>
      'CommandMismatchException: [$input] did not match command signature';
}
