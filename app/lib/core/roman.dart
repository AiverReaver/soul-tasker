/// [n] (1 or more) in roman numerals: phase counts and lesson lists.
String romanNumeral(int n) {
  const steps = [
    (1000, 'M'), (900, 'CM'), (500, 'D'), (400, 'CD'), (100, 'C'), (90, 'XC'),
    (50, 'L'),
    (40, 'XL'),
    (10, 'X'),
    (9, 'IX'),
    (5, 'V'),
    (4, 'IV'),
    (1, 'I'), //
  ];
  var rest = n;
  final out = StringBuffer();
  for (final (value, symbol) in steps) {
    while (rest >= value) {
      out.write(symbol);
      rest -= value;
    }
  }
  return out.toString();
}
