part of cupid;

class Program {
  final Shell _shell;

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
    await new Future.delayed(const Duration(seconds: 2));
    return new Output('<red>EXECUTE</red> $input\n');
  }

  Stream<Output> executeAll(Iterable<Input> inputs) async* {
    for (final input in inputs)
      yield await execute(input);
  }

  Future setUp() async {}

  Future tearDown() async {}

  void addCommand(command) {

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
