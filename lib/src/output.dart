part of cupid;

class Output {
  final String _markup;
  final Map<String, List<int>> _colors = {
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

    'background-black': [40, 49],
    'background-red': [41, 49],
    'background-green': [42, 49],
    'background-yellow': [43, 49],
    'background-blue': [44, 49],
    'background-magenta': [45, 49],
    'background-cyan': [46, 49],
    'background-white': [47, 49],

    'black-background': [40, 49],
    'red-background': [41, 49],
    'green-background': [42, 49],
    'yellow-background': [43, 49],
    'blue-background': [44, 49],
    'magenta-background': [45, 49],
    'cyan-background': [46, 49],
    'white-background': [47, 49],
  };

  Output(String this._markup);

  String get plain {
    return _transformTags((color) => '', (color) => '');
  }

  String get ansi {
    return _transformTags((color) => '\u001b[${_colors[color][0]}m',
        (color) => '\u001b[${_colors[color][1]}m');
  }

  String _transformTags(String open(String color), String close(String color)) {
    var output = _markup;
    for (final color in _colors.keys)
        output = output
            .replaceAll('<$color>', open(color))
            .replaceAll('</$color>', close(color));
    return output;
  }

  String toString() => plain;
}
