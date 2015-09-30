import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:cupid/cupid.dart';

class TerminalPromptTest implements TestCase {
  TerminalPrompt terminalPrompt;

  setUp() {
    terminalPrompt = new TerminalPrompt(['']);
  }

  tearDown() {}

  @test
  it_wraps_an_output_value() {
    expect(terminalPrompt.output.plain, '');
    terminalPrompt.input('x');
    expect(terminalPrompt.output.plain, 'x');
  }

  @test
  it_has_a_cursor_location() {
    expect(terminalPrompt.cursor, equals(0));
    terminalPrompt.input('x');
    expect(terminalPrompt.cursor, equals(1));
  }

  @test
  it_enforces_cursor_is_between_zero_and_length_of_input() {
    terminalPrompt.input('abc');
    expect(terminalPrompt.cursor, equals(3));
    terminalPrompt.cursor -= 3;
    expect(terminalPrompt.cursor, equals(0));
    terminalPrompt.cursor--;
    expect(terminalPrompt.cursor, equals(0));
    terminalPrompt.cursor += 4;
    expect(terminalPrompt.cursor, equals(3));
  }

  @test
  it_has_a_history() {
    terminalPrompt.input('x');
    terminalPrompt.flush();
    terminalPrompt.previous();
    expect(terminalPrompt.flush(), equals('x'));
  }
}
