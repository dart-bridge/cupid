part of cupid;

class LogIoDevice implements IoDevice {
  IOSink _sink;

  Future close() {
    return _sink.close();
  }

  Future<Input> input() {
    return new Completer().future;
  }

  void output(String output) {
    _sink.write(output);
  }

  void outputError(error, Chain stack) {
    _sink.writeln(stack.terse.toString().split('\n').reversed.join('\n'));
    _sink.writeln(error);
  }

  void outputInColor(String output) {
    this.output(output.replaceAll('</?\w+>',''));
  }

  Future<String> rawInput() {
    return new Completer().future;
  }

  void setPrompter(Function prompter) {
  }

  Future setUp() async {
    _sink = new File('cupid.log').openWrite(mode: APPEND);
  }

  Future abortInput() async {
  }
}
