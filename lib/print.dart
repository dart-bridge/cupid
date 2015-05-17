import 'dart:io';

Function overridePrintFunction = null;

@override
void print(Object obj) {
  if (overridePrintFunction != null) return overridePrintFunction(obj);

  stdout.writeln(obj);
}