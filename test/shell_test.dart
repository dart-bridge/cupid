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
  it_throws_when_command_is_not_registered() {
    expect(() => shell.execute(#functionCommand),
    throwsA(const isInstanceOf<NoSuchCommandException>()));
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

  @test
  it_can_describe_a_command() {
    shell.addCommand(functionCommand);
    shell.addCommand(ClassCommand);
    expect(shell.describeCommand(#functionCommand), equals('Test command'));
    expect(shell.describeCommand(#ClassCommand), equals('Test command'));
  }

  @test
  it_can_describe_an_option() {
    shell.addCommand(functionCommandWithPositional);
    shell.addCommand(ClassCommandWithPositional);
    expect(shell.describeOption(#functionCommandWithPositional, #input), equals('An input option'));
    expect(shell.describeOption(#ClassCommandWithPositional, #input), equals('An input option'));
  }

  @test
  it_can_get_the_type_of_an_option() {
    shell.addCommand(functionCommandWithPositional);
    shell.addCommand(ClassCommandWithPositional);
    expect(shell.typeOfOption(#functionCommandWithPositional, #input), equals(String));
    expect(shell.typeOfOption(#ClassCommandWithPositional, #input), equals(String));
  }

  @test
  it_can_get_the_default_value_of_an_option() {
    shell.addCommand(functionCommandWithPositional);
    shell.addCommand(functionCommandWithNamed);
    shell.addCommand(ClassCommandWithNamed);
    expect(shell.optionDefault(#functionCommandWithPositional, #input), isNull);
    expect(shell.optionDefault(#functionCommandWithNamed, #input), equals('input'));
    expect(shell.optionDefault(#ClassCommandWithNamed, #input), equals('input'));
  }

  @test
  it_allows_for_optional_arguments() async {
    shell.addCommand(functionCommandWithOptional);
    expect(await shell.execute(#functionCommandWithOptional), isNull);
    expect(await shell.execute(#functionCommandWithOptional, ['input']), equals('input'));
  }

  @test
  it_throws_invalid_input_if_non_optional_param_is_missing() async {
    shell.addCommand(functionCommandWithPositional);
    expect(() => shell.execute(#functionCommandWithPositional), throwsA(const isInstanceOf<InvalidInputException>()));
  }

  @test
  it_supports_a_rest_like_signature() async {
    shell.addCommand(functionCommandWithListArgument);
    expect(await shell.execute(#functionCommandWithListArgument, ['one', 'two', 'three']), equals(['one', 'two', 'three']));
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
@Option(#input, 'An input option')
functionCommandWithPositional(String input) {
  return '$input output';
}

@Command('Test command')
@Option(#input, 'An input option')
class ClassCommandWithPositional {
  String input;

  ClassCommandWithPositional(String this.input);

  execute() {
    return '$input output';
  }
}

@Command('Test command')
@Option(#input, 'An input option')
functionCommandWithNamed({String input: 'input'}) {
  return '$input output';
}

@Command('Test command')
@Option(#input, 'An input option')
class ClassCommandWithNamed {
  String input;

  ClassCommandWithNamed({String this.input: 'input'});

  execute() {
    return '$input output';
  }
}

@Command('Test command')
@Option(#input, 'An optional input')
functionCommandWithOptional([String input]) {
  return input;
}

@Command('Test command')
@Option(#input, 'A list input')
functionCommandWithListArgument([List<String> input]) {
  return input;
}