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
    // Get the next input from the input device (command prompt)
    final input = await _inputDevice.nextInput();

    // If the input is not null (empty command), run the input
    if (input != null) await _runInput(runner, input);

    // If exit hasn't been issued, repeat
    if (!_programCompleter.isCompleted) return _runShell(runner);
  }

  Future _runInput(Future<Output> runner(Input input), Input input) async {
    // Run the runner with the input zoned
    final returnValue = await _runZoned(() => runner(input));

    // If the output from the command is not null, send it to the output device
    if (returnValue != null) _outputDevice.output(returnValue);
  }

  Future _runZoned(body()) async {
    final completer = new Completer();
    runZoned(() async {
      final returnValue = await body();
      completer.complete(returnValue);
    }, onError: (e, s) {
      completer.complete(_onThrow(e, s));
    });
    return completer.future;
  }

  Output _onThrow(Exception exception, StackTrace stack) {
    return new Output('<red>$exception</red>\n');
  }

  void stop() {
    _programCompleter.complete();
  }
}