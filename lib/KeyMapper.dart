part of cupid;

enum InputKey { UNKNOWN, INPUT, UP, DOWN, RIGHT, LEFT, BACKSPACE, RETURN }

class KeyMapper {
  static bool _is(List<int> charCodes, List<int> compare) {
    if (charCodes.length != compare.length) return false;

    for (var i = 0; i < charCodes.length; ++i) {
      if (charCodes[i] != compare[i]) return false;
    }

    return true;
  }

  static InputKey keyType(List<int> charCodes) {
    String stringValue = new String.fromCharCodes(charCodes);

    if ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#€%&/()=?`´+_-:.;,><\'*¨^ '
        .split('')
        .contains(stringValue)) {
      return InputKey.INPUT;
    }

    if (_is(charCodes, [10])) return InputKey.RETURN;
    if (_is(charCodes, [27, 91, 65])) return InputKey.UP;
    if (_is(charCodes, [27, 91, 66])) return InputKey.DOWN;
    if (_is(charCodes, [27, 91, 67])) return InputKey.RIGHT;
    if (_is(charCodes, [27, 91, 68])) return InputKey.LEFT;
    if (_is(charCodes, [127])) return InputKey.BACKSPACE;

    return InputKey.UNKNOWN;
  }
}
