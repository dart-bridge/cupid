import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:cupid/cupid.dart';

class InputTest implements TestCase {
  setUp() {}

  tearDown() {}

  @test
  it_cannot_be_empty() {
    expect(() => new Input(null), throws);
    expect(() => new Input(''), throws);
  }

  @test
  it_creates_a_command_from_an_input_string() {
    expect(new Input('x').command, equals(#x));
  }

  @test
  it_creates_positional_arguments_from_subsequent_words() {
    final input = new Input('x y z');

    expect(input.command, equals(#x));
    expect(input.positionalArguments, equals(['y', 'z']));
  }

  @test
  it_infers_types() {
    final input = new Input('x abc 123 1.2');

    expect(input.command, equals(#x));
    expect(input.positionalArguments, equals(['abc', 123, 1.2]));
  }

  @test
  it_interprets_flags() {
    final input = new Input('x -y');

    expect(input.positionalArguments, equals([]));
    expect(input.namedArguments, equals({
      #y: true
    }));
  }

  @test
  it_integrates() {
    final input = new Input(
        'cmd --flag --other=100 --more="multiple words" pos 1.34');

    expect(input.command, equals(#cmd));
    expect(input.positionalArguments, equals(['pos', 1.34]));
    expect(input.namedArguments, equals({
      #flag: true,
      #other: 100,
      #more: 'multiple words'
    }));
  }
}
