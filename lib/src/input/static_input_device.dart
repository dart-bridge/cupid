part of cupid;

class StaticInputDevice implements InputDevice {
  final List<String> _inputs;

  StaticInputDevice(List<String> this._inputs);

  Future<Input> nextInput() async {
    if (_inputs.length > 0)
      return new Input(_inputs.removeAt(0));
    return new Input('exit');
  }

  Future close() async {}
}
