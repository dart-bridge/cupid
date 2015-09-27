part of cupid;

abstract class InputDevice {
  static Output prompt = new Output('<blue>></blue> ');

  InputDevice(InputDevice this._input);

  Future open();

  Future<Input> nextInput();

  Future close();
}
