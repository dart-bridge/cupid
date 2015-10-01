library cupid;

import 'dart:mirrors';
import 'dart:async';
import 'dart:io';
import 'dart:math' show min, max;
import 'dart:convert' show Encoding, UTF8;
import 'dart:isolate';

import 'src/input/stdin_broadcast.dart';
import 'package:console/console.dart';
import 'package:stack_trace/stack_trace.dart';

part 'src/shell.dart';

part 'src/program.dart';

part 'src/constants.dart';

part 'src/validator.dart';

part 'src/input.dart';

part 'src/output.dart';

part 'src/input_device.dart';

part 'src/output_device.dart';

part 'src/input/std_input_device.dart';

part 'src/input/static_input_device.dart';

part 'src/input/terminal_input_device.dart';

part 'src/input/terminal_prompt.dart';

part 'src/output/file_output_device.dart';

part 'src/output/std_output_device.dart';

part 'src/output/terminal_output_device.dart';

Future cupid(Program program, List<String> arguments, SendPort connector) {
  if (connector == null)
    return _masterCupid(arguments);

  final args = arguments.join(' ');
  return _childCupid(program, args, connector);
}

Future _masterCupid(List<String> arguments) async {
  await _spawnChild(arguments);
  await stdinBroadcast.cancel();
}

Future _spawnChild(List<String> arguments) async {
  final reloadRequestReceiver = new ReceivePort();
  var shouldReload = false;
  reloadRequestReceiver.listen((List<String> args) async {
    if (args is! List)
      return shouldReload = false;
    shouldReload = true;
    arguments = await _mergeArguments(args, arguments);
  });

  final connector = new ReceivePort();
  connector.first.then((List ports) {
    final stdinPort = ports[0];
    final reloadRequestPort = ports[1];
    final terminal = ports[2];
    if (terminal) {
      stdinBroadcast.echoMode = false;
      stdinBroadcast.lineMode = false;
    } else {
      stdinBroadcast.echoMode = true;
      stdinBroadcast.lineMode = true;
    }
    stdinBroadcast.listen(stdinPort.send);
    reloadRequestPort.send(reloadRequestReceiver.sendPort);
    connector.close();
  });

  final onExitReceiver = new ReceivePort();

  await Isolate.spawnUri(Platform.script,
      arguments,
      connector.sendPort,
      onExit: onExitReceiver.sendPort);

  await onExitReceiver.first;
  reloadRequestReceiver.close();
  onExitReceiver.close();

  if (shouldReload)
    return _spawnChild(arguments);
}

Future<List<String>> _mergeArguments(List<String> a, List<String> b) async {
  a ??= [];
  b ??= [];
  final argumentString = a.join(' ') + ',' + b.join(' ');
  var arguments = argumentString.split(',').map((s) => s.trim()).toList();
  arguments.sort();
  arguments = await new Stream.fromIterable(arguments).distinct().toList();
  return arguments.join(',').split(' ');
}

Future _childCupid(Program program, String arguments,
    SendPort connector) async {
  final stdinPort = new ReceivePort();
  final reloadRequestPort = new ReceivePort();
  connector.send([
    stdinPort.sendPort,
    reloadRequestPort.sendPort,
    program._shell._inputDevice is TerminalInputDevice
  ]);

  final SendPort reloadPort = await reloadRequestPort.first;
  reloadRequestPort.close();

  final Stream<List<int>> stdinBroadcast = stdinPort;

  await program.run(
      bootArguments: arguments,
      stdinBroadcast: stdinBroadcast,
      reloadPort: reloadPort);

  Isolate.current.kill();
}
