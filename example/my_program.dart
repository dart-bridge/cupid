import 'dart:io';
import 'dart:async';
import 'package:cupid/cupid.dart';

//main(args) => new MyProgram().run(args.join(' '));
main() => new Program(new Shell(new StdInputDevice(), new StdOutputDevice())).run();

class MyProgram extends Program {
  HttpServer server;

  setUp() {
    this.print('<green>Setting up</green>');
    addCommand(externalCommand);
  }

  tearDown() async {
    this.print('<green>Tearing down</green>');
    await stop();
  }

  @Command('Asynchronous command')
  async() async {
    this.print('<yellow><underline>Begin</underline></yellow>');
    await new Future.delayed(const Duration(seconds: 2));
    this.print('<yellow><underline>End</underline></yellow>');
  }

  @Command('Start the server')
  start({
  @Option('The port to run the server on') String host: 'localhost',
  @Option('The host to listen to') int port: 1337
  }) async {
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
        match: r'^[A-Z][a-z]+$',
        message: 'Only first name, please.');

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