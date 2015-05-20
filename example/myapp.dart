import 'package:cupid/cupid.dart';
import 'dart:async';
import 'dart:io';

main(a, m) => new MyApp()
  ..addCommand(greet)
  ..run(a, m);

@Command('Greet someone')
greet(String name) {
  print('Hello, $name');
}

class MyApp extends Program {

  HttpServer _server;

  setUp() {
    displayHelp();
    start();
  }

  tearDown() {
    if (watchStreamController != null) {
      watchStreamController.cancel();
    }
    stop();
  }

  @Command('Throws an exception')
  trigger() {
    throw new Exception('This is a sample exception');
  }

  @Command('Tail the error log in the console')
  tail() async {
    var errorFile = new File('cupid_error.log');
    String contents = await errorFile.readAsString();
    errorFile.watch().listen((event) async {
      print('change');
      var oldContents = contents;
      contents = await errorFile.readAsString();
      print(contents.replaceFirst(oldContents, ''));
    });
    print('tailing');
  }

  @Command('Start the server')
  Future start() async {
    if (_server != null) {
      return print('The server is already running');
    }
    _server = await HttpServer.bind('localhost', 1337);
    _server.listen((req) => req.response
      ..write('Det fungerar')
      ..close());
    print('Server started on http://localhost:1337');
  }

  @Command('Stop the server')
  Future stop() async {
    if (_server == null) {
      return print('The server is not running, so it cannot be stopped');
    }
    await _server.close();
    _server = null;
    print('Server stopped');
  }

  StreamSubscription watchStreamController;

  @Command('Watch the application for changes, and reload when change happens')
  watch() async {
    var watchDir = new Directory('..').watch(recursive: true);

    watchStreamController = watchDir.listen((FileSystemEvent event) {
      if (event.path.endsWith('.dart')) reload(['watch']);
    });
    print('Watching the application...');
  }

  @Command('Stop watching the application for changes')
  unwatch() async {
    watchStreamController.cancel();
    print('No longer watching.');
  }
}
