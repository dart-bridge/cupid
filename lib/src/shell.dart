part of cupid;

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

    var commandMirror = _commands[command];
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

  Future _executeClass(ClassMirror classMirror, List positional, Map named) async {
    return classMirror.newInstance(const Symbol(''), positional, named).invoke(#execute, []).reflectee;
  }

  Future _executeFunction(ClosureMirror closureMirror, List positional, Map named) async {
    return closureMirror.apply(positional, named).reflectee;
  }

  Future input(Input input) {
    return execute(input.command, input.positionalArguments, input.namedArguments);
  }
}
