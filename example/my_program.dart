import 'dart:io';
import 'package:cupid/cupid.dart';
import 'dart:async';

main() {
  new MyProgram().run();
}

class MyProgram extends Program {
  HttpServer server;

  setUp() async {
    this.addCommand(externalCommand);
  }

  tearDown() async {
    await stop();
  }

  @Command('Start the server')
  @Option(#port, 'The port to run the server on')
  @Option(#host, 'The host to listen to')
  start({String host: 'localhost', int port: 1337}) async {
    await new Future.delayed(const Duration(seconds: 3));
    server = await HttpServer.bind(host, port);
    server.listen(handleRequests);
    printInfo('Server is running on http://$host:$port');
  }

  @Command('Stop the server')
  stop() async {
    await server.close();
    print('Server stopped');
  }

  void handleRequests(HttpRequest request) {
    request.response..write('Response')..close();
  }
}

@Command('Do something from the outside')
externalCommand(Program program) async {
  var ageQuestion = const Question('How old are you?', type: int);
  var nameQuestion = const Question(
      "What's your name?",
      match: r'^[A-Z][a-z]+$',
      message: 'Only first name, please.');

  int age = await program.ask(ageQuestion);
  program.printInfo('Great! Now I know your age!');

  String name = await program.ask(nameQuestion);
  program.printInfo("Thank you, $name, you're $age years old!");
}