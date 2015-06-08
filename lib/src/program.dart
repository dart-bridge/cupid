part of cupid;

class Program {
  IoDevice _io;
  Shell _shell;

  Program() {
    this._io = new ConsoleIoDevice();
    this._shell = new Shell();
    _init();
  }

  Program.using(IoDevice this._io, Shell this._shell) {
    _init();
  }

  void _init() {
    reflectClass(this.runtimeType).declarations.forEach((k, v) {
      if (v.metadata.any((m) => m.reflectee is Command)) {
        addCommand(reflect(this).getField(k).reflectee);
      }
    });
  }

  ask(Question question) {

  }

  printInfo(String info) {

  }

  void addCommand(command) {
    _shell.addCommand(command);
  }

  Future execute(Symbol command) {
    return _zoned(() {
      return _shell.execute(command);
    });
  }

  Future waitForInput() async {
    return _zoned(() async {
      return _shell.input(await _io.input());
    });
  }

  Future _zoned(body()) {
    return runZoned(() {
      return body();
    }, zoneSpecification: new ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          _io.output(line + '\n');
        }));
  }

  Future run() async {
    try {
      await waitForInput();
    } on InputException catch(e) {
      _io.outputInColor('<red>${e.toString()}</red>\n');
    } on ProgramExitingException {
      return;
    }
    await run();
  }

  void exit() {
    throw new ProgramExitingException();
  }
}

class ProgramExitingException {

}