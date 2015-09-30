import 'dart:io';
import 'dart:async';
import 'dart:convert';

StdinBroadcast stdinBroadcast = new StdinBroadcast(stdin);

class StdinBroadcast implements Stdin {
  final Stdin _stdin;
  final StreamController<List<int>> _controller
  = new StreamController.broadcast();
  StreamSubscription _stdinSubscription;

  StdinBroadcast(Stdin this._stdin) {
    _stdinSubscription = _stdin.listen(_controller.add);
  }

  Stream<List<int>> get _stream => _controller.stream;

  @override
  Future<bool> any(bool test(List<int> element)) {
    return _stream.any(test);
  }

  @override
  Stream<List<int>> asBroadcastStream(
      {void onListen(StreamSubscription<List<int>> subscription), void onCancel(
          StreamSubscription<List<int>> subscription)}) {
    return this;
  }

  @override
  Stream asyncExpand(Stream convert(List<int> event)) {
    return _stream.asyncExpand(convert);
  }

  @override
  Stream asyncMap(convert(List<int> event)) {
    return _stream.asyncMap(convert);
  }

  @override
  Future<bool> contains(Object needle) {
    return _stream.contains(needle);
  }

  @override
  Stream<List<int>> distinct(
      [bool equals(List<int> previous, List<int> next)]) {
    return _stream.distinct(equals);
  }

  @override
  Future drain([futureValue]) {
    return _stream.drain(futureValue);
  }

  @override
  Future<List<int>> elementAt(int index) {
    return _stream.elementAt(index);
  }

  @override
  Future<bool> every(bool test(List<int> element)) {
    return _stream.every(test);
  }

  @override
  Stream expand(Iterable convert(List<int> value)) {
    return _stream.expand(convert);
  }

  @override
  Future<List<int>> get first => _stream.first;

  @override
  Future firstWhere(bool test(List<int> element), {Object defaultValue()}) {
    return _stream.firstWhere(test, defaultValue: defaultValue);
  }

  @override
  Future fold(initialValue, combine(previous, List<int> element)) {
    return _stream.fold(initialValue, combine);
  }

  @override
  Future forEach(void action(List<int> element)) {
    return _stream.forEach(action);
  }

  @override
  Stream<List<int>> handleError(Function onError, {bool test(error)}) {
    return _stream.handleError(onError, test: test);
  }

  @override
  bool get isBroadcast => true;

  @override
  Future<bool> get isEmpty => _stream.isEmpty;

  @override
  Future<String> join([String separator = ""]) {
    return _stream.join(separator);
  }

  @override
  Future<List<int>> get last => _stream.last;

  @override
  Future lastWhere(bool test(List<int> element), {Object defaultValue()}) {
    return _stream.lastWhere(test, defaultValue: defaultValue);
  }

  @override
  Future<int> get length => _stream.length;

  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _stream.listen(onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }

  @override
  Stream map(convert(List<int> event)) {
    return _stream.map(convert);
  }

  @override
  Future pipe(StreamConsumer<List<int>> streamConsumer) {
    return _stream.pipe(streamConsumer);
  }

  @override
  Future<List<int>> reduce(
      List<int> combine(List<int> previous, List<int> element)) {
    return _stream.reduce(combine);
  }

  @override
  Future<List<int>> get single => _stream.single;

  @override
  Future<List<int>> singleWhere(bool test(List<int> element)) {
    return _stream.singleWhere(test);
  }

  @override
  Stream<List<int>> skip(int count) {
    return _stream.skip(count);
  }

  @override
  Stream<List<int>> skipWhile(bool test(List<int> element)) {
    return _stream.skipWhile(test);
  }

  @override
  Stream<List<int>> take(int count) {
    return _stream.take(count);
  }

  @override
  Stream<List<int>> takeWhile(bool test(List<int> element)) {
    return _stream.takeWhile(test);
  }

  @override
  Stream timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) {
    return _stream.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<List<int>>> toList() {
    return _stream.toList();
  }

  @override
  Future<Set<List<int>>> toSet() {
    return _stream.toSet();
  }

  @override
  Stream transform(StreamTransformer<List<int>, dynamic> streamTransformer) {
    return _stream.transform(streamTransformer);
  }

  @override
  Stream<List<int>> where(bool test(List<int> event)) {
    return _stream.where(test);
  }

  bool get echoMode {
    return _stdin.echoMode;
  }

  void set echoMode(bool value) {
    _stdin.echoMode = value;
  }

  bool get lineMode {
    return _stdin.lineMode;
  }

  void set lineMode(bool value) {
    _stdin.lineMode = value;
  }

  @override
  int readByteSync() {
    throw new UnsupportedError(
        'The original stdin is claimed by the broadcast.');
  }

  @override
  String readLineSync(
      {Encoding encoding: SYSTEM_ENCODING, bool retainNewlines: false}) {
    throw new UnsupportedError(
        'The original stdin is claimed by the broadcast.');
  }

  Future cancel() async {
    await _stdinSubscription.cancel();
    await _controller.close();
  }
}
