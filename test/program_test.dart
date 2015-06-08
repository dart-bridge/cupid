import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:cupid/cupid.dart';
import 'dart:async';

class ProgramTest implements TestCase {
  Program program;
  MockIoDevice io;
  Shell shell;

  setUp() {
    io = new MockIoDevice();
    shell = new Shell();
    program = new Program.using(io, shell);
    io.program = program;
  }

  tearDown() {
  }

  @test
  it_pipes_the_output_of_a_command_to_an_output_dependency() async {
    program.addCommand(command);
    await program.execute(#command);
    expect(io.wasOutput, equals('output\n'));
  }

  @test
  it_waits_for_input_then_runs_a_command() async {
    program.addCommand(inputCommand);
    io.willInput = new Input(['inputCommand', 'argument']);
    await program.waitForInput();
    expect(io.wasOutput, equals('Flag set: false\nArgument: argument\n'));
  }

  @test
  it_can_be_run_to_always_wait_for_next_input_or_exit() async {
    program.addCommand(command);
    io.willInput = new Input(['command']);
    await program.run();
    expect(io.hasBeenCalledOnce, isTrue);
    expect(io.wasOutput, equals('output\n'));
  }
}

class MockIoDevice implements IoDevice {
  Input willInput;
  String wasOutput = '';
  bool hasBeenCalledOnce = false;
  Program program;

  Future<Input> input() async {
    if (hasBeenCalledOnce) {
      program.exit();
    }
    hasBeenCalledOnce = true;
    return willInput;
  }

  void output(String output) {
    wasOutput += output;
  }

  void outputInColor(String output) {
    wasOutput += output;
  }

  void outputError(error, StackTrace stack) {
  }
}

@Command('Example command')
command() {
  print('output');
}

@Command('Test input command')
@Option(#argument, 'An argument')
@Option(#flag, 'A flag')
inputCommand(String argument, {bool flag}) {
  print('Flag set: ${flag == true}');
  print('Argument: $argument');
}
