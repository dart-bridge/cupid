part of cupid;

class Shell {
  final InputDevice _inputDevice;
  final OutputDevice _outputDevice;
  final Completer _programCompleter = new Completer();

  Shell([InputDevice inputDevice, OutputDevice outputDevice])
      :
        _inputDevice = inputDevice != null ? inputDevice : _isCapable()
            ? new TerminalInputDevice()
            : new StdInputDevice(),
        _outputDevice = outputDevice != null ? outputDevice : _isCapable()
            ? new TerminalOutputDevice()
            : new StdOutputDevice();

  static bool _isCapable() {
    return stdout.hasTerminal && !Platform.isWindows;
  }

  Future run(
      Iterable<Input> initialCommands,
      Future<Output> runner(Input input),
      String tabCompletion(String input),
      Stream<List<int>> stdinBroadcast) async {
    await _inputDevice.open(stdinBroadcast);
    for (final command in initialCommands)
      await _runInput(runner, command);
    _runShell(runner, tabCompletion);
    await _programCompleter.future;
  }

  Future _runShell(Future<Output> runner(Input input), String tabCompletion(String input)) async {
    // Get the next input from the input device (command prompt)
    final input = await _inputDevice.nextInput(tabCompletion);

    // If the input is not null (empty command), run the input
    if (input != null) await _runInput(runner, input);

    // If exit hasn't been issued, repeat
    if (!_programCompleter.isCompleted) return _runShell(runner, tabCompletion);
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

  Future stop() async {
    await _inputDevice.close();
    _programCompleter.complete();
  }
}