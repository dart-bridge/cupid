# Cupid 0.9.0

## Usage

```dart
import 'dart:io';
import 'package:cupid/cupid.dart';

main(_, __) => cupid(new MyProgram(), _, __);

class MyProgram extends Program {
  HttpServer server;

  setUp() {
    this.addCommand(externalCommand);
  }

  tearDown() async {
    await stop();
  }

  @Command('Start the server')
  start(
  {@Option('The port to run the server on') String host: 'localhost', 
  @Option('The host to listen to') int port: 1337}) async {
    server = await HttpServer.bind(host, port);
    server.listen((r) => r.response.write('Response'));
    printInfo('Server is running on http://$host:$port');
  }

  @Command('Stop the server')
  stop() async {
    if (server == null) return;
    await server.close();
    printInfo('Server stopped');
  }

  @Command('Ask some questions')
  questions() async {
    var ageQuestion = const Question('How old are you?', type: int);
    var nameQuestion = const Question(
        "What's your name?",
        match: r'^[A-Z][a-z]+$');

    int age = await ask(ageQuestion);
    printInfo('Great! Now I know your age!');

    String name = await ask(nameQuestion);
    printInfo("Thank you, $name, you're $age years old!");
  }
}

@Command('Do something from the outside')
externalCommand() async {
  print('Hello world!');
}
```
