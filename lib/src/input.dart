part of cupid;

class Input {
  Symbol command;
  List positionalArguments;
  Map<Symbol, dynamic> namedArguments;
  final String _raw;

  Input(String this._raw) {
    if (_raw == null || _raw == '')
      throw new ArgumentError.value(_raw, 'input', 'cannot be null');

    command = _getCommand();
    positionalArguments = _getPositional();
    namedArguments = _getNamed();
  }

  Symbol _getCommand() {
    return new Symbol(_raw
        .split(' ')
        .first);
  }

  List _getPositional() {
    return _raw
        .replaceAll(new RegExp(r'''(['"]).*\1'''), '')
        .split(' ')
        .sublist(1)
        .where(_isNotNamed)
        .map(_inferType)
        .toList();
  }

  bool _isNotNamed(String element) {
    return !element.startsWith('-');
  }

  _inferType(String element) {
    if (new RegExp(r'^(\d+|\d*\.\d+)$').hasMatch(element))
      return num.parse(element);

    return element;
  }

  Map<Symbol, dynamic> _getNamed() {
    final named = {};
    for (final $ in _everyNamed())
      named[new Symbol($[0])] = $[1] == null ? true : _inferType($[1]);
    return named;
  }

  List _everyNamed() {
    return new RegExp(r'''--?(\w+)=?(?:(["'])(.*)\2|([\w.]+))?''')
        .allMatches(_raw)
        .map((Match $) {
      final name = $[1];
      final maybeString = $[3];
      final maybeValue = $[4];
      return [name, maybeString ?? maybeValue];
    }).toList();
  }

  String toString() => _raw;
}
