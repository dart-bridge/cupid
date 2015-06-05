part of cupid;

class Input {
  Symbol _command;
  final List positionalArguments = [];
  final Map<Symbol, dynamic> namedArguments = {};

  Input(List<String> arguments) {
    _command = new Symbol(arguments.removeAt(0));
    namedArguments.addAll(_parseOptions(arguments.where(_isOption)));
    positionalArguments.addAll(_parsePrimitives(arguments.where(_isNotOption)));
  }

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

  _parsePrimitive(String p) {
    if (p == '') return true;
    if (_matches(p, r'^\d+$')) return int.parse(p);
    if (_matches(p, r'^\d*[.,]\d+$')) return double.parse(p);
    return p;
  }

  bool _matches(String input, String regExp) {
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
