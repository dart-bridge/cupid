part of cupid;

class Command {
  const Command(String description);
}

class Option {
  const Option(Type type, Symbol name, String description, {defaultValue});
}

class Question {
  const Question(String sentence, {Type type, String match, String message});
}