part of cupid;

class StdOutputDevice implements OutputDevice {
  void output(Output output) {
    stdout.write(output.plain);
  }
}
