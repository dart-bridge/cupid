part of cupid;

class Shell {
  final InputDevice _inputDevice;
  final OutputDevice _outputDevice;
  final Completer _programCompleter = new Completer();

  Shell([InputDevice inputDevice, OutputDevice outputDevice])
      :
        _inputDevice = inputDevice != null ? inputDevice : stdout.hasTerminal
            ? new TerminalInputDevice()
            : new StdInputDevice(),
        _outputDevice = outputDevice != null ? outputDevice : stdout.hasTerminal
            ? new TerminalOutputDevice()
            : new StdOutputDevice();

  Future run(Future<Output> runner(Input input)) async {
    await _inputDevice.open();
    _runShell(runner);
    await _programCompleter.future;
    await _inputDevice.close();
  }

  Future _runShell(Future<Output> runner(Input input)) async {
    final input = await _inputDevice.nextInput();
    if (input != null)
      _outputDevice.output(await runner(input));
    if (!_programCompleter.isCompleted)
      return _runShell(runner);
  }

  void stop() {
    _programCompleter.complete();
  }
}