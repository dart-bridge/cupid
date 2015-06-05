import 'dart:io';
import 'package:cupid/cupid.dart';
export 'package:cupid/init.dart';

class MyProgram extends Program {
  HttpServer server;

  setUp() {
    this.addCommand(externalCommand);
  }

  tearDown() async {
    await stop();
  }

  @Command('Start the server')
  @Option(int, #port, 'The port to run the server on', defaultValue: 1337)
  @Option(String, #host, 'The host to listen to', defaultValue: 'localhost')
  start({String host, int port}) async {
    server = await HttpServer.bind(host, port);
    server.listen(handleRequests);
    print('Server is running on ${server.address}');
  }

  @Command('Stop the server')
  stop() async {
    await server.close();
    print('Server stopped');
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