import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:cupid/cupid.dart';

class InputTest implements TestCase {

  setUp() {
  }

  tearDown() {}

  @test
  it_is_constructed_with_a_list_of_strings() {
    var input = new Input(['whatever']);
    expect(input.command, equals(#whatever));
  }

  @test
  it_turns_string_arguments_to_positional_arguments() {
    var input = new Input(['command', 'argument1', 'argument2']);
    expect(input.positionalArguments, equals(['argument1', 'argument2']));
  }

  @test
  it_turns_numbers_into_their_correct_type() {
    var input = new Input(['command', '1', '.3']);
    expect(input.positionalArguments, equals([1, .3]));
  }

  @test
  it_turns_arguments_formatted_as_options_into_map_with_their_values() {
    var input = new Input(['command', '--option=value', '--option2=42', '--flag']);
    expect(input.positionalArguments, equals([]));
    expect(input.namedArguments, equals({
      #option: 'value',
      #option2: 42,
      #flag: true,
    }));
  }
}
