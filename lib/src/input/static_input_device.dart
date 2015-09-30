part of cupid;

class StaticInputDevice extends InputDevice {
  final List<String> _inputs;

  StaticInputDevice(List<String> this._inputs);

  Future<Input> nextInput(_) async {
    if (_inputs.length > 0)
      return new Input(_inputs.removeAt(0));
    return new Input('exit');
  }

  Future close() async {}

  Future open(_) async {}

  Future rawInput() async {
    return '';
  }
}
