import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:cupid/cupid.dart';
import 'dart:async';

class ProgramTest implements TestCase {
  Program program;
  MockInputDevice input;
  MockOutputDevice output;

  setUp() {
    input = new MockInputDevice();
    output = new MockOutputDevice();
    program = new Program(new Shell(input, output));
  }

  tearDown() {}

  @test
  it_can_register_and_execute_a_command() async {
    program.addCommand(mockCommand);

    await program.execute(new Input('mockCommand'));

    expect(output.log, contains('out\n'));
  }

  @test
  it_maps_over_the_input_to_a_method_call() async {
    program.addCommand(mockCommandWithArguments);

    await program.execute(
        new Input('mockCommandWithArguments x 1 '
            '--third=1.2 --fourth="two words"'));

    expect(output.log, contains('x, 1, 1.2, two words\n'));
  }

  @test
  it_allows_a_command_to_receive_the_positional_arguments_as_a_list() async {
    program.addCommand(mockCommandWithRest);

    await program.execute(new Input('mockCommandWithRest a b c'));

    expect(output.log, contains('3: [a, b, c]\n'));
  }

  @Command('')
  mockCommand() {
    program.print('out');
  }

  @Command('')
  mockCommandWithArguments(String first, int second,
      {double third, String fourth}) {
    program.print('$first, $second, $third, $fourth');
  }

  @Command('')
  mockCommandWithRest(List<String> arguments) {
    program.print('${arguments.length}: $arguments');
  }
}

class MockInputDevice extends InputDevice {
  List<String> willReturn = [];

  Future open() async {}

  Future close() async {}

  Future<Input> nextInput(_) async {
    if (willReturn.isNotEmpty)
      return new Input(willReturn.removeAt(0));
    return new Input('exit');
  }

  Future rawInput() async {}
}

class MockOutputDevice implements OutputDevice {
  final List<String> log = [];

  void output(Output output) {
    log.add(output.plain);
  }
}