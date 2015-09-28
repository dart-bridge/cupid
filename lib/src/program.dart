part of cupid;

typedef Future Invoker(List positional, Map<Symbol, dynamic> named);

class Program {
  final Shell _shell;
  final Map<Symbol, Invoker> _commands = {};

  Program([Shell shell])
      : _shell = shell ?? new Shell();

  Future run([String bootArguments]) async {
    await setUp();
    if (bootArguments != null && bootArguments != '')
      await executeAll(bootArguments
          .split(',')
          .map((a) => new Input(a.trim())))
          .forEach(_shell._outputDevice.output);
    return _shell.run(execute);
  }

  Future<Output> execute(Input input) async {
    final returnValue = await _commands[input.command]
    (input.positionalArguments, input.namedArguments);
    if (returnValue == null)
      return null;
    return new Output('$returnValue');
  }

  Stream<Output> executeAll(Iterable<Input> inputs) async* {
    for (final input in inputs)
      yield await execute(input);
  }

  Future setUp() async {}

  Future tearDown() async {}

  void addCommand(command) {
    ClosureMirror method = reflect(command);
    _commands[method.function.simpleName] =
        (p, n) => method.apply(p, n).reflectee;
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
    _shell.stop();
    await tearDown();
  }
}
