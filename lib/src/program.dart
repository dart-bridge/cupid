part of cupid;

class Program {
  IoDevice _io;
  Shell _shell;

  Program() {
    this._io = new ConsoleIoDevice();
    this._shell = new Shell();
  }

  Program.using(IoDevice this._io, Shell this._shell);

  Future init() async {
    _allDeclarations(reflectClass(this.runtimeType)).forEach((k, v) {
      if (v.metadata.any((m) => m.reflectee is Command)) {
        addCommand(reflect(this).getField(k).reflectee);
      }
    });
    await _io.setUp();
    await setUp();
  }

  Map<Symbol, DeclarationMirror> _allDeclarations(ClassMirror classMirror) {
    var declarations = new Map.from(classMirror.declarations);
    if (classMirror.mixin != classMirror && classMirror.mixin != null)
      declarations.addAll(_allDeclarations(classMirror.mixin));
    if (classMirror.superclass != Object && classMirror.superclass != null)
      declarations.addAll(_allDeclarations(classMirror.superclass));
    return declarations;
  }

  void setPrompter(prompter) {
    if (prompter is Function) return _io.setPrompter(prompter);
    _io.setPrompter(() => prompter);
  }

  Future setUp() async {
  }

  Future tearDown() async {
  }

  Future ask(Question question) async {
    _io.outputInColor('\n<underline><yellow>${question.sentence}</yellow></underline>\n');
    var input = Input._parsePrimitive(await _io.rawInput());
    try {
      question.validate(input);
    } catch (e) {
      printDanger(e.toString());
      return ask(question);
    }
    return input;
  }

  printInfo(String info) {
    _io.outputInColor('<blue>$info</blue>\n');
  }

  printDanger(String info) {
    _io.outputInColor('<red>$info</red>\n');
  }

  printWarning(String info) {
    _io.outputInColor('<yellow>$info</yellow>\n');
  }

  printAccomplishment(String info) {
    _io.outputInColor('<green>$info</green>\n');
  }

  void addCommand(command) {
    _shell.addCommand(command);
  }

  Future execute(Symbol command) {
    return _zoned(() {
      return _shell.execute(command);
    });
  }

  Future waitForInput() {
    return _zoned(() async {
      return _shell.input(await _io.input());
    });
  }

  Future _zoned(body()) async {
    try {
      await runZoned(() {
        return body();
      },
      zoneSpecification: new ZoneSpecification(
          print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
            _io.output(line + '\n');
          }));
    } on InputException {
      rethrow;
    } on ProgramExitingException {
      rethrow;
    } on ProgramReloadingException {
      rethrow;
    } catch (e, s) {
      _io.outputError(e, s);
    }
  }

  Future run([Input input]) async {
    try {
      await _zoned(init);
      await _zoned(_runCycle);
      await _exit();
    } on ProgramReloadingException {
      await _reload();
    }
  }

  Future _exit() async {
    await _zoned(tearDown);
    await _io.close();
  }

  Future _runCycle() async {
    try {
      await waitForInput();
    } on InputException catch (e) {
      _io.outputInColor('<red>${e.toString()}</red> <gray>Type \'help\' for details</gray>\n');
    } on ProgramExitingException {
      return;
    } on ProgramReloadingException {
      rethrow;
    }
    await _runCycle();
  }

  @Command('Clear the terminal screen')
  void clear() {
    Console.eraseDisplay(1);
    Console.moveCursor(row: 0, column: 0);
  }

  @Command('Exit the application')
  void exit() {
    throw new ProgramExitingException();
  }

  @Command('Restart the application')
  Future reload() {
    throw new ProgramReloadingException();
  }

  Future _reload() async {
    await _exit();
    Isolate.spawnUri(Platform.script, [], null);
  }

  @Command('See a list of all available commands')
  @Option(#command, 'See a description of a specific command')
  void help([String command]) {
    if (command == null) return _helpAll();
    _helpFor(new Symbol(command));
  }

  void _helpAll() {
    _io.outputInColor('\n<blue><underline>Available commands:</underline></blue>\n\n'
    '  ${_helpRows().join('\n  ')}\n\n');
  }

  List<String> _helpRows() {
    List<String> usages = _commandUsages();
    List<String> descriptions = _commandDescriptions();
    var longestUsageLength = 0;
    usages.forEach((u) => longestUsageLength = max(longestUsageLength, u.length));
    usages = usages.map((u) => u.padRight(longestUsageLength + 2)).toList();
    var rows = [];
    usages.asMap().forEach((i, u) => rows.add(u + descriptions[i]));
    return rows;
  }

  List<InstanceMirror> _sortedCommands() {
    return (_shell._commands.keys.toList()
      ..sort((Symbol a, Symbol b) => MirrorSystem.getName(a).compareTo(MirrorSystem.getName(b))))
    .map((Symbol s) => _shell._commands[s]).toList();
  }

  List<String> _commandDescriptions() {
    return _sortedCommands()
    .map(_shell._commandAnnotation)
    .map((Command a) => '<italic><gray>${a.description}</gray></italic>')
    .toList();
  }

  List<String> _commandUsages() {
    return _sortedCommands().map(_usageOfCommand).toList();
  }

  void _helpFor(Symbol command) {

  }

  String _usageOfCommand(InstanceMirror command) {
    var name = _shell._getSymbol(command);
    List<String> arguments = _argumentsOfCommand(command);
    return '<yellow><bold>${MirrorSystem.getName(name)}</bold></yellow> <red>'
    '${arguments.join(' ')}</red>';
  }

  List<String> _argumentsOfCommand(InstanceMirror command) {
    return _shell._commandMethod(command).parameters.map(_describeParam).toList();
  }

  String _describeParam(ParameterMirror param) {
    if (param.isNamed) return _describeNamedParam(param);
    return _describePositionalParam(param);
  }

  String _describeNamedParam(ParameterMirror param) {
    var takesValue = param.type.reflectedType != bool;
    var value = takesValue ? '${param.type.reflectedType}' : '';
    var name = MirrorSystem.getName(param.simpleName);
    var dashes = name.length > 1 ? '--' : '-';
    return '[$dashes$name${takesValue ? '=' : ''}$value]';
  }

  String _describePositionalParam(ParameterMirror param) {
    var name = MirrorSystem.getName(param.simpleName);
    if (param.isOptional) return '[$name]';
    return name;
  }
}

class ProgramReloadingException {
}

class ProgramExitingException {

}