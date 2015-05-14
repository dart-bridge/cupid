import 'package:cupid/cupid.dart';
import 'dart:async';
import 'dart:io';

main(a, m) => new MyApp().run(a, m);

class MyApp extends Program {
  bool _serverRunning = false;

  setUp() {
    print('Set up environment');
  }

  tearDown() {
    print('Tear down environment');
    if (watchStreamController != null) {
      watchStreamController.cancel();
    }
    stop();
  }

  @Command('Start the server')
  start() {
    if (_serverRunning) {
      return print('The server is already running');
    }
    _serverRunning = true;
    print('Server started');
  }

  @Command('Stop the server')
  stop() {
    if (!_serverRunning) {
      return print('The server is not running, so it cannot be stopped');
    }
    _serverRunning = false;
    print('Server stopped');
  }

  StreamSubscription watchStreamController;

  @Command('Watch the application for changes, and reload when change happens')
  watch() async {
    var watchDir = new Directory('..').watch(recursive: true);

    watchStreamController = watchDir.listen((FileSystemEvent event) {
      if (event.path.endsWith('.dart')) prog.reload(['watch']);
    });
  }

  @Command('Stop watching the application for changes')
  unwatch() async {
    watchStreamController.cancel();
  }
}
