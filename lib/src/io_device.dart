part of cupid;

abstract class IoDevice {
  void output(String output);
  void outputInColor(String output);
  Future<Input> input();
}
