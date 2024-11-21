import 'package:args/args.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/functions/command_parser.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Get parser is OK',
    () {
      final parserResult = CommandParser.getParser();
      expect(parserResult.isRight(), isA<bool>());

      expect(
        parserResult.fold(
          (l) => none(),
          (arg) => arg,
        ),
        isA<ArgParser>(),
      );
    },
  );
}
