import "dart:convert";
import "dart:ffi";

import "arena.dart";

/// Represents a String in C memory, managed by an [Arena].
class CString extends Pointer<Int8> {
  /// Allocates a [CString] in the current [Arena] and populates it with
  /// [dartStr].
  factory CString(String dartStr) => CString.inArena(Arena.current(), dartStr);

  /// Allocates a [CString] in [arena] and populates it with [dartStr].
  factory CString.inArena(Arena arena, String dartStr) =>
      arena.scoped(CString.allocate(dartStr));

  /// Allocate a [CString] not managed in and populates it with [dartStr].
  ///
  /// This [CString] is not managed by an [Arena]. Please ensure to [free] the
  /// memory manually!
  factory CString.allocate(String dartStr) {
    List<int> units = Utf8Encoder().convert(dartStr);
    Pointer<Int8> str = allocate(count: units.length + 1);
    for (int i = 0; i < units.length; ++i) {
      str.elementAt(i).store(units[i]);
    }
    str.elementAt(units.length).store(0);
    return str.cast();
  }

  /// Read the string for C memory into Dart.
  static String fromUtf8(CString str) {
    if (str == null) return null;
    int len = 0;
    while (str.elementAt(++len).load<int>() != 0);
    List<int> units = List(len);
    for (int i = 0; i < len; ++i) units[i] = str.elementAt(i).load();
    return Utf8Decoder().convert(units);
  }
}
