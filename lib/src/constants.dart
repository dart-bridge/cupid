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
}