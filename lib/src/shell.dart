part of cupid;

class InputException {
  const InputException();
}

class NoSuchCommandException extends InputException {
  final Symbol command;
  const NoSuchCommandException(Symbol this.command);

  String toString() {
    return 'No such command: ${MirrorSystem.getName(command)}';
  }
}

class InvalidInputException extends InputException {
  final String message;
  const InvalidInputException(String this.message);

  String toString() {
    return message;
  }
}

class Shell {
  Map<Symbol, InstanceMirror> _commands = <Symbol, dynamic>{};

  void addCommand(command) {
    var commandMirror = reflect(command);
    _commands[_getSymbol(commandMirror)] = commandMirror;
  }

  Symbol _getSymbol(InstanceMirror command) {
    if (command is ClosureMirror)
      return command.function.simpleName;
    return reflectType(command.reflectee).simpleName;
  }

  Future execute(Symbol command,
                 [List positionalArguments,
                 Map<Symbol, dynamic> namedArguments]) {
    if (positionalArguments == null) positionalArguments = [];
    if (namedArguments == null) namedArguments = <Symbol, dynamic>{};

    var commandMirror = _validInput(command, positionalArguments, namedArguments);

    if (commandMirror is ClosureMirror)
      return _executeFunction(
          commandMirror,
          positionalArguments,
          namedArguments);
    return _executeClass(
        reflectType(commandMirror.reflectee),
        positionalArguments,
        namedArguments);
  }

  InstanceMirror _validInput(Symbol command,
                            List positionalArguments,
                            Map<Symbol, dynamic> namedArguments) {
    if (!_commands.containsKey(command)) throw new NoSuchCommandException(command);
    var mirror = _commands[command];
    _validateInput(_commandMethod(mirror), positionalArguments, namedArguments);
    return mirror;
  }

  void _validateInput(MethodMirror commandMethod,
                    List positionalArguments,
                    Map<Symbol, dynamic> namedArguments) {
    var positional = new List.from(positionalArguments);
    var named = new Map.from(namedArguments);
    for (var param in commandMethod.parameters) {
      _validateParam(param, positional, named);
    }
    if (positional.length > 0)
      throw new InvalidInputException('Too many arguments: ${positional.join(', ')}');
    if (named.length > 0)
      throw new InvalidInputException(
          'Unknown option: ${MirrorSystem.getName(named.keys.elementAt(0))}');
  }

  void _validateParam(ParameterMirror parameter,
                      List positionalArguments,
                      Map<Symbol, dynamic> namedArguments) {
    if (parameter.isNamed)
      _validateParamValue(parameter, namedArguments.remove(parameter.simpleName));
    else
      _validateParamValue(parameter, positionalArguments.removeAt(0));
  }

  void _validateParamValue(ParameterMirror parameter, Object value) {
    var name = MirrorSystem.getName(parameter.simpleName);
    if (value == null && !parameter.isOptional)
      throw new InvalidInputException('Parameter [$name] is obligatory');
    if (value != null && value.runtimeType != parameter.type.reflectedType)
      throw new InvalidInputException(
          'Parameter [$name] must be of type [${parameter.type.reflectedType}]');
  }

  Future _executeClass(ClassMirror classMirror, List positional, Map named) async {
    return classMirror
    .newInstance(const Symbol(''), positional, named)
    .invoke(#execute, []).reflectee;
  }

  Future _executeFunction(ClosureMirror closureMirror, List positional, Map named) async {
    return closureMirror.apply(positional, named).reflectee;
  }

  Future input(Input input) {
    return execute(input.command, input.positionalArguments, input.namedArguments);
  }

  MethodMirror _commandMethod(InstanceMirror command) {
    if (command is ClosureMirror) return command.function;
    var classMirror = reflectClass(command.reflectee);
    return classMirror.declarations[classMirror.simpleName] as MethodMirror;
  }

  List<InstanceMirror> _annotations(InstanceMirror command) {
    if (command is ClosureMirror) return command.function.metadata;
    return reflectType(command.reflectee).metadata;
  }

  Command _commandAnnotation(InstanceMirror command) {
    var commands = _annotations(command).where((m) => m.reflectee is Command);
    if (commands.length == 0) return const Command(null);
    return commands.first.reflectee;
  }

  Iterable<Option> _optionAnnotations(InstanceMirror command) {
    return _annotations(command)
    .where((m) => m.reflectee is Option)
    .map((m) => m.reflectee);
  }

  Option _option(InstanceMirror command, Symbol option) {
    var options = _optionAnnotations(command).where((o) => o.name == option);
    if (options.length == 0) return new Option(option, null);
    return options.first;
  }

  String describeCommand(Symbol name) {
    if (!_commands.containsKey(name)) return null;
    return _commandAnnotation(_commands[name]).description;
  }

  String describeOption(Symbol command, Symbol option) {
    if (!_commands.containsKey(command)) return null;
    return _option(_commands[command], option).description;
  }

  ParameterMirror _parameter(InstanceMirror command, Symbol name) {
    return _commandMethod(command).parameters
    .firstWhere((p) => p.simpleName == name);
  }

  Type typeOfOption(Symbol command, Symbol option) {
    if (!_commands.containsKey(command)) return dynamic;
    var param = _parameter(_commands[command], option);
    if (param == null) return null;
    return param.type.reflectedType;
  }

  optionDefault(Symbol command, Symbol option) {
    if (!_commands.containsKey(command)) return null;
    var param = _parameter(_commands[command], option);
    if (param == null) return null;
    return (param.defaultValue == null) ? null : param.defaultValue.reflectee;
  }
}
