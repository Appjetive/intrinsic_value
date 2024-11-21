import 'package:intrinsic_value/enums/command.dart';
import 'package:intrinsic_value/functions/annual_growth.dart';
import 'package:intrinsic_value/functions/command_parser.dart';
import 'package:intrinsic_value/functions/command_result.dart';
import 'package:intrinsic_value/models/annual_growth_args.dart';
import 'package:test/test.dart';

void main() {
  final parserResult = CommandParser.getParser();
  test(
    'Parse Annual Growth params throws errors',
    () {
      final agParams = parserResult
          .bind(
            (parser) => CommandResult.getCommandResult(
              parser: parser,
              commandName: Command.ag.name,
              arguments: ['ag'],
            ).bind(
              (argResult) => AnnualGrowth.parseAgParams(argResult),
            ),
          )
          .fold(
            (l) => l,
            (r) => r,
          );

      expect(agParams, isA<Exception>());
    },
  );

  test(
    'Parse Annual Growth is OK',
    () {
      final agParams = parserResult
          .bind(
            (parser) => CommandResult.getCommandResult(
              parser: parser,
              commandName: Command.ag.name,
              arguments: [
                "ag",
                "--min",
                "0",
                "--max",
                "0",
              ],
            ).bind(
              (argResult) => AnnualGrowth.parseAgParams(argResult),
            ),
          )
          .fold(
            (l) => l,
            (r) => r,
          );

      expect(agParams, isA<AnnualGrowthArgs>());
    },
  );

  test(
    'Calculate annual growth in 0 years throws an error',
    () {
      final result = AnnualGrowth.calculateAnualGrowth(
        AnnualGrowthArgs(
          startPrice: 245,
          finalPrice: 1456,
          yearsToGrow: 0,
        ),
      ).fold(
        (l) => l,
        (r) => r,
      );

      expect(result, isA<Exception>());
    },
  );

  test(
    'Calculate annual growth 42.82% in 5 year is OK',
    () {
      final result = AnnualGrowth.calculateAnualGrowth(
        AnnualGrowthArgs(
          startPrice: 245,
          finalPrice: 1456,
          yearsToGrow: 5,
        ),
      ).fold(
        (l) => l,
        (r) => r,
      );

      expect(result, isA<double>());
      expect(result, 42.82);
    },
  );
}
