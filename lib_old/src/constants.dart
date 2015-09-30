part of cupid;

class Command {
  final String description;
  const Command(String this.description);
}

class Option {
  final Symbol name;
  final String description;
  const Option(Symbol this.name,
               String this.description);
}

class Question {
  final String sentence;
  final Type type;
  final String match;
  final String message;
  const Question(String this.sentence,
                 {Type this.type,
                 String this.match,
                 String this.message});

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