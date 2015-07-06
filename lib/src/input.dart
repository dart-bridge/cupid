part of cupid;

class Input {
  Symbol _command;
  final List positionalArguments = [];
  final Map<Symbol, dynamic> namedArguments = {};
  String _raw;

  Input(List<String> arguments) {
    arguments = arguments.toList();
    if (arguments.length == 0) throw new InvalidInputException('Empty input');
    _raw = arguments.join(' ');
    _command = new Symbol(arguments.removeAt(0));
    namedArguments.addAll(_parseOptions(arguments.where(_isOption)));
    positionalArguments.addAll(_parsePrimitives(arguments.where(_isNotOption)));
  }

  String get raw => _raw;

  bool _isOption(String element) {
    return element.startsWith('-');
  }

  bool _isNotOption(String element) {
    return !_isOption(element);
  }

  Map<Symbol, dynamic> _parseOptions(Iterable<String> a) {
    return new Map.fromIterables(a.map(_keyOfOption), a.map(_valueOfOption));
  }

  Iterable _parsePrimitives(Iterable<String> arguments) {
    return arguments.map(_parsePrimitive);
  }

  Symbol get command => _command;

  static _parsePrimitive(String p) {
    if (p == '') return true;
    if (_matches(p, r'''^(['"])[^\1]*\1$''')) return p.substring(1, p.length-1);
    if (_matches(p, r'^\d+$')) return int.parse(p);
    if (_matches(p, r'^\d*[.,]\d+$')) return double.parse(p);
    return p;
  }

  static bool _matches(String input, String regExp) {
    return new RegExp(regExp).hasMatch(input);
  }

  Symbol _keyOfOption(String element) {
    return new Symbol(_optionParts(element)[0]);
  }

  _valueOfOption(String element) {
    return _parsePrimitive(_optionParts(element)[1]);
  }

  List<String> _optionParts(String option) {
    return new RegExp(r'^--?([^=]+)=?(.*)$').firstMatch(option).groups([1, 2]);
  }
}
