// Generate a random string of 20 char
import 'dart:math';

String generateRandomKey() {
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
  const lenght = 20;
  Random r = Random();
  return String.fromCharCodes(
    Iterable.generate(
      lenght,
      (_) => ch.codeUnitAt(
        r.nextInt(ch.length),
      ),
    ),
  );
}
