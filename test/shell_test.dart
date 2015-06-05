import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:cupid/cupid.dart';

class ShellTest implements TestCase {

  Shell shell;

  setUp() {
    shell = new Shell();
  }

  tearDown() {}

  @test
  it_executes_commands() async {
    shell.addCommand(functionCommand);
    expect(await shell.execute(#functionCommand), equals('response'));
  }

  @test
  it_executes_commands_as_classes() async {
    shell.addCommand(ClassCommand);
    expect(await shell.execute(#ClassCommand), equals('response'));
  }

  @test
  it_executes_the_commands_with_positional_arguments() async {
    shell.addCommand(functionCommandWithPositional);
    shell.addCommand(ClassCommandWithPositional);
    expect(await shell.execute(#functionCommandWithPositional, ['input']), equals('input output'));
    expect(await shell.execute(#ClassCommandWithPositional, ['input']), equals('input output'));
  }

  @test
  it_can_have_named_parameters_as_well() async {
    shell.addCommand(functionCommandWithNamed);
    shell.addCommand(ClassCommandWithNamed);
    expect(await shell.execute(#functionCommandWithNamed, [], {#input: 'input'}),
    equals('input output'));
    expect(await shell.execute(#ClassCommandWithNamed, [], {#input: 'input'}),
    equals('input output'));
  }

  @test
  it_turns_an_input_structure_into_a_command_execution_call() async {
    shell.addCommand(functionCommandWithNamed);
    var result = await shell.input(new Input(['functionCommandWithNamed', '--input=value']));
    expect(result, equals('value output'));
  }
}


@Command('Test command')
functionCommand() {
  return 'response';
}

@Command('Test command')
class ClassCommand {
  execute() {
    return 'response';
  }
}

@Command('Test command')
functionCommandWithPositional(String input) {
  return '$input output';
}

@Command('Test command')
class ClassCommandWithPositional {
  String input;

  ClassCommandWithPositional(String this.input);

  execute() {
    return '$input output';
  }
}

@Command('Test command')
functionCommandWithNamed({String input}) {
  return '$input output';
}

@Command('Test command')
class ClassCommandWithNamed {
  String input;

  ClassCommandWithNamed({String this.input});

  execute() {
    return '$input output';
  }
}