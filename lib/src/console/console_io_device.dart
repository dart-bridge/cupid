part of cupid;

class ConsoleIoDevice implements IoDevice {
  StreamController<List<int>> _stdinController = new StreamController.broadcast();
  var _colors = {
    'reset': [0, 0],

    'bold': [1, 22],
    'dim': [2, 22],
    'italic': [3, 23],
    'underline': [4, 24],
    'inverse': [7, 27],
    'hidden': [8, 28],
    'strikethrough': [9, 29],

    'black': [30, 39],
    'red': [31, 39],
    'green': [32, 39],
    'yellow': [33, 39],
    'blue': [34, 39],
    'magenta': [35, 39],
    'cyan': [36, 39],
    'white': [37, 39],
    'gray': [90, 39],
    'grey': [90, 39],

    'bgBlack': [40, 49],
    'bgRed': [41, 49],
    'bgGreen': [42, 49],
    'bgYellow': [43, 49],
    'bgBlue': [44, 49],
    'bgMagenta': [45, 49],
    'bgCyan': [46, 49],
    'bgWhite': [47, 49],
  };

  ConsoleIoDevice() {
    stdin.listen(_stdinController.add);
  }

  Future<Input> input() async {
    List<int> inputChars = await _stdinController.stream.first;
    var input = UTF8.decode(inputChars);
    return new Input(input.trim().split(' '));
  }

  void output(String output) {
    stdout.write(output);
  }

  String _colorize(String output) {
    for (var key in _colors.keys) {
      output = output.replaceAll('<$key>', '\u001b[${_colors[key][0]}m');
      output = output.replaceAll('</$key>', '\u001b[${_colors[key][1]}m');
    }
    return output;
  }

  void outputInColor(String output) {
    this.output(_colorize(output));
  }
}
