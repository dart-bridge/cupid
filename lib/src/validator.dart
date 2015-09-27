part of cupid;

class _Validator {
  final Type type;
  final String match;
  final String message;

  _Validator(Type this.type, String this.match, String this.message);

  void validate(answer) {
    if (type != null) _validateType(answer);
    if (match != null) _validateExpression(answer);
  }

  void _validateType(Object answer) {
    if (!_typeMatches(answer.runtimeType))
      throw _messageOr('Input must be of type [$type]');
  }

  bool _typeMatches(Type shouldMatch) {
    return reflectType(shouldMatch).isAssignableTo(reflectType(type));
  }

  void _validateExpression(String answer) {
    if (!new RegExp(match).hasMatch(answer))
      throw _messageOr('Input must match the following format: $match');
  }

  String _messageOr(String message) {
    if (this.message != null) return this.message;
    return message;
  }
}
