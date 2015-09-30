part of cupid;

abstract class InputDevice {
  static Output prompt = new Output('<blue>></blue> ');

  InputDevice();

  Future open(Stream<List<int>> stdinBroadcast);

  Future<Input> nextInput(String tabCompletion(String input));

  Future close();

  Future rawInput();

  inferType(String element) {
    if (new RegExp(r'^(\d+|\d*\.\d+)$').hasMatch(element))
      return num.parse(element);

    return element;
  }
}
