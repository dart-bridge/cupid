part of cupid;

class TerminalOutputDevice implements OutputDevice {
  void output(Output output) {
    stdout.write(output.ansi);
  }
}
