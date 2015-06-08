part of cupid;

class Prompt {
  StreamController<String> _controller = new StreamController.broadcast();
  String _buffer = '';

  Prompt() {
    stdin.echoMode = false;
    stdin.lineMode = false;
    Console.init();
    stdin.listen(_char);
  }

  _char(List<int> char) {
    stdout.write(char);
    if (char[0] == 10) {
      _controller.add(_buffer);
      _buffer = '';
    } else {
//      _buffer += UTF8.decode(char).trim();
//      hide();
//      show();
    }
  }

  hide() {
    Console.moveToColumn(Console.readLine().length);
    Console.eraseLine();
    Console.moveToColumn(0);
  }

  show() {
    stdout.write('> ');
  }

  Future<String> input() {
    stdout.write('listening');
    return _controller.stream.first;
  }
}
