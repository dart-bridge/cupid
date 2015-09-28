part of cupid;

typedef Future Invoker(List positional, Map<Symbol, dynamic> named);

class Program {
  final Shell _shell;
  final Map<Symbol, Invoker> _commands = {};

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
    return _shell.run(execute);
  }

  Future<Output> execute(Input input) async {
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
  }

  bool _isRestMethod(ClosureMirror method) {
    return method.function.parameters
        .where((p) => !p.isNamed)
        .length == 1
        && method.function.parameters[0].type.isSubtypeOf(reflectType(List));
  }

  Future ask(Question question) async {

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
  help() {
    _commands.keys.forEach(print);
  }

  @Command('Exit and restart the program')
  Future reload([List<String> arguments]) async {
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
