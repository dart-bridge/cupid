
Function overridePrintFunction = null;

void print(Object obj) {
  if (overridePrintFunction != null) return overridePrintFunction(obj);

  stdout.writeln(obj);
}