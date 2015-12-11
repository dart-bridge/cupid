part of cupid;

typedef Future Invoker(List positional, Map<Symbol, dynamic> named);

class Program {
  final Shell _shell;
  final Map<Symbol, Invoker> _commands = {};
  final List<MethodMirror> _commandDeclarations = [];
  SendPort _reloadPort;
  bool _settingUp = false;
  List<String> _shouldReloadAfterSetUp;
  bool _shouldExitAfterSetUp = false;

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

  Future run({String bootArguments: '',
  Stream<List<int>> stdinBroadcast,
  SendPort reloadPort}) {
    return runZoned(() async {
      stdinBroadcast ??= stdin;
      _reloadPort = reloadPort;
      _settingUp = true;
      await setUp();
      _settingUp = false;
      if (_shouldReloadAfterSetUp != null)
        return reload(_shouldReloadAfterSetUp);
      if (_shouldExitAfterSetUp)
        return exit();
      final initialCommands = bootArguments.split(',')
          .where((a) => a.trim() != '')
          .map((a) => new Input(a.trim()));
      return _shell.run(
          initialCommands, execute, this._tabCompletion, stdinBroadcast);
    }, zoneSpecification: new ZoneSpecification(
        print: (self, delegate, zone, line) {
          _shell._inputDevice.beforePrint();
          _shell._outputDevice.output(new Output('$line\n'));
          _shell._inputDevice.afterPrint();
        }));
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
    } on CommandMismatchException {
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
          _createInvoker(method, rest: true);
    else
      _commands[method.function.simpleName] = _createInvoker(method);
    _commandDeclarations.add(method.function);
  }

  Invoker _createInvoker(ClosureMirror closure, {bool rest: false}) {
    return (List positional, Map named) {
      if (_canCall(closure.function, positional, named))
        return closure
            .apply(rest ? [positional] : positional, named)
            .reflectee;
      else throw new CommandMismatchException.placeholder();
    };
  }

  bool _canCall(MethodMirror method, List positional, Map named) {
    final List<ParameterMirror> allPositional = method.parameters
        .where((p) => !p.isNamed).toList();
    final int positionalMinLength = allPositional
        .where((p) => !p.isOptional)
        .length;
    final int positionalMaxLength = allPositional.length;
    final Iterable<Symbol> allNamed = method.parameters
        .where((p) => p.isNamed).map((p) => p.simpleName);
    final bool allNamedExist = named.keys.every((s) => allNamed.contains(s));
    final bool positionalLengthIsOk =
    (positional.length <= positionalMaxLength
        && positional.length >= positionalMinLength)
        || (allPositional.length == 1 && allPositional[0].type
        .isSubtypeOf(reflectType(List)));

    return allNamedExist && positionalLengthIsOk;
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

  void printTable(List<List> table, {int padding: 2}) {
    print(renderTable(table, padding: padding));
  }

  String renderTable(Iterable<List> table, {int padding: 2}) {
    if (table.length == 0) return '';
    final List<int> columnWidths = table.map((row) {
      return row.map((col) => (col is Output ? col.plain.length : '$col'
          .length) + padding).toList();
    }).reduce((Iterable<int> ait, Iterable<int> bit) sync* {
      final a = ait.toList();
      final b = bit.toList();
      for (var i = 0; i < max(a.length, b.length); i++)
        yield max(a[i], b[i]);
    }).toList();
    return table.map((Iterable rowit) {
      List row = rowit.toList();
      var output = '';
      for (var i = 0; i < columnWidths.length; i++)
        output += _padTableCell(row[i], columnWidths[i]);
      return output.trimRight();
    }).join('\n');
  }

  String _padTableCell(cell, int width) {
    int shouldPad;
    if (cell is Output)
      shouldPad = width - cell.plain.length;
    else
      shouldPad = width - '$cell'.length;
    String output = cell is Output ? cell._markup : '$cell';
    return output + (' ' * shouldPad);
  }

  // Built in commands
  @Command('Exit the program')
  Future exit() async {
    if (_settingUp)
      return _shouldExitAfterSetUp = true;

    await _shell.stop();
    await tearDown();
  }

  @Command('Show help screen')
  help([@Option('Search for help') String term]) {
    if (term == null || term == '')
      _helpAll();
    else if (_commands.keys.any((s) => MirrorSystem.getName(s) == term))
      _helpCommand(term);
    else
      _narrow(term);
  }

  void _helpAll() {
    print('''

<underline><yellow>Available commands:</yellow></underline>

${renderTable(_commandDeclarations.map(_describeCommand))}
''');
  }

  List<Output> _describeCommand(MethodMirror command) {
    final List<String> parts = [];
    parts.add('<yellow>  ${MirrorSystem.getName(command.simpleName)}</yellow>');
    parts.add(_usage(command));
    parts.add('<gray>${(command.metadata
        .firstWhere((i) => i.reflectee is Command)
        .reflectee as Command).description}</gray>');
    return parts.map((s) => new Output(s));
  }

  String _usage(MethodMirror command) {
    if (command.parameters.isNotEmpty)
      return command.parameters.map(_describePositional).join(' ');
    return '';
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
    final mirror = _commandDeclarations
        .firstWhere((m) => MirrorSystem.getName(m.simpleName) == command);
    final Command annotation = mirror.metadata
        .firstWhere((i) => i.reflectee is Command)
        .reflectee;
    final usage = _usage(mirror);
    print('''

<yellow><underline>$command</underline> command</yellow>
<cyan>${annotation.description}</cyan>

<gray><underline>Usage:</underline></gray> <red>$command</red> $usage
${mirror.parameters.any((p) => !p.isNamed) ? '''

<gray><underline>Arguments:</underline></gray>
${renderTable(_describePositionalArguments(mirror))}
''' : ''}${mirror.parameters.any((p) => p.isNamed) ? '''

<gray><underline>Flags:</underline></gray>
${renderTable(_describeNamedArguments(mirror))}
''' : ''}''');
  }

  Iterable<List<Output>> _describePositionalArguments(MethodMirror mirror) {
    return mirror.parameters.where((p) => !p.isNamed).map(_describeArgument);
  }

  Iterable<List<Output>> _describeNamedArguments(MethodMirror mirror) {
    return mirror.parameters.where((p) => p.isNamed).map(_describeArgument);
  }

  List<Output> _describeArgument(ParameterMirror element) {
    final parts = <Output>[];
    parts.add(new Output('<red>${MirrorSystem
        .getName(element.simpleName)}</red>'));
    return parts;
  }

  void _narrow(String term) {
    printTable(_commandDeclarations
        .where((m) => MirrorSystem.getName(m.simpleName).startsWith(term))
        .map(_describeCommand));
  }

  @Command('Exit and restart the program')
  Future reload([@Option(
      'Boot arguments for the new instance') List<String> arguments]) async {
    if (_reloadPort == null)
      throw new Exception('Can only use the reload command if the program '
          'initialized with the [cupid] function!');

    if (_settingUp)
      return _shouldReloadAfterSetUp = arguments ?? [];

    _reloadPort.send(arguments);
    await exit();
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

  CommandMismatchException.placeholder() : super(null);

  toString() =>
      'CommandMismatchException: [$input] did not match command signature';
}
