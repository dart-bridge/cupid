part of cupid;

abstract class IoDevice {
  void output(String output);

  void outputInColor(String output);

  Future<Input> input();

  void outputError(error, Chain stack);

  Future close();

  Future<String> rawInput();

  void setPrompter(Function prompter);

  Future setUp();
}
