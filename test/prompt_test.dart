import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:cupid/cupid.dart';

class PromptTest implements TestCase {
  Prompt prompt;

  setUp() {
    prompt = new Prompt();
  }

  tearDown() {}

  @test
  it_has_content_and_a_cursor() {
    prompt.append('abc');
    expect(prompt.value, equals('abc'));
    expect(prompt.cursor, equals(3));
  }

  @test
  it_can_move_the_cursor_but_not_to_negative_value() {
    prompt.append('abc');
    prompt.cursor--;
    expect(prompt.cursor, equals(2));
    prompt.cursor--;
    prompt.cursor--;
    prompt.cursor--;
    prompt.cursor--;
    expect(prompt.value, equals('abc'));
    expect(prompt.cursor, equals(0));
  }

  @test
  it_cannot_have_a_cursor_beyond_the_value_length() {
    prompt.cursor++;
    expect(prompt.cursor, equals(0));
  }

  @test
  it_can_mass_assign_the_value() {
    prompt.value = 'abcde';
    expect(prompt.value, equals('abcde'));
    expect(prompt.cursor, equals(5));
  }

  @test
  it_can_remove_a_char_at_the_cursor_location() {
    prompt.value = 'abcde';
    prompt.cursor--;
    prompt.backspace();
    expect(prompt.value, equals('abce'));
    expect(prompt.cursor, equals(3));
    prompt.value = '';
    prompt.backspace();
    expect(prompt.value, equals(''));
    expect(prompt.cursor, equals(0));
    prompt.value = 'abc';
    prompt.backspace();
    expect(prompt.value, equals('ab'));
    expect(prompt.cursor, equals(2));
  }

  @test
  it_appends_at_the_cursor_position() {
    prompt.value = 'abcde';
    prompt.cursor--;
    prompt.cursor--;
    prompt.append('&');
    expect(prompt.value, equals('abc&de'));
    expect(prompt.cursor, equals(4));
  }

  @test
  it_can_be_cleared() {
    prompt.value = 'abcde';
    prompt.clear();
    expect(prompt.value, equals(''));
    expect(prompt.cursor, equals(0));
  }
}
