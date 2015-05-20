# cupid

An easy to use shell application wrapper

## Usage

Create your program like this:

```dart
class MyApp extends Program {

  setUp() {
    print('set things up!');
  }

  tearDown() {
    print('tear things down!');
  }

  @Command('Say hello')
  greet() {
    print('Hello, world!')
  }
}
```

To run the program, you need the two first arguments from the `main` function 
(the arguments and the potential isolate message).

A nice way to do it is like this:

```dart
main(a, m) => new MyApp().run(a, m);
```

Note that it is a bad idea to turn the main method into a getter, as it doesn't
work when called from an isolate. So *DON'T* do `get main => new MyApp().run`.

## Set up and tear down

The point of having a shell app instead of a standard command line program is that you
can place things in the memory, and manipulate it through commands. To start up services
(for example connect to the database, or create an HTTP server), we can place that in the
`setUp` method. Likewise we can put tear down functionality in `tearDown`, which will be run
before the program exits after the command *exit* has been run.

### NOTE

> `tearDown` will not be executed if the program is interrupted with <kbd>^</kbd><kbd>C</kbd>

## Todo

* Command args and flags!
* Write documentation comments in the code
* Write some tests