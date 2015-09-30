part of cupid;

class Command {
  final String description;
  const Command(String this.description);
}

class Option {
  final String description;
  final String match;
  final String message;
  const Option(String this.description,
      {String this.match,
      String this.message});

  void validate(answer) {
    return new _Validator(null, match, message).validate(answer);
  }
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
    return new _Validator(type, match, message).validate(answer);
  }
}