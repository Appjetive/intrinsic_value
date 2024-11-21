import 'package:intrinsic_value/enums/command.dart';
import 'package:intrinsic_value/functions/command_parser.dart';
import 'package:intrinsic_value/functions/command_result.dart';
import 'package:intrinsic_value/functions/intrinsic_value.dart';
import 'package:intrinsic_value/models/intrinsic_value_model.dart';
import 'package:test/test.dart';

void main() {
  final parserResult = CommandParser.getParser();

  test(
    'Reading from the stock file throws an error',
    () {
      final agParams = parserResult
          .bind(
            (parser) => CommandResult.getCommandResult(
              parser: parser,
              commandName: Command.iv.name,
              arguments: ["iv", "--stock", "./stocks/missing"],
            ).bind(
              (argResult) => IntrinsicValue.readStockFile(argResult['stock']),
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
    'Reading from the stock file is OK',
    () {
      final agParams = parserResult
          .bind(
            (parser) => CommandResult.getCommandResult(
              parser: parser,
              commandName: Command.iv.name,
              arguments: ["iv", "--stock", "./stocks/acls"],
            ).bind(
              (argResult) => IntrinsicValue.readStockFile(argResult['stock']),
            ),
          )
          .fold(
            (l) => l,
            (r) => r,
          );
      expect(agParams, isA<Map<String, num>>());
    },
  );

  test(
    'Parse Intrisic Value params throws an error',
    () {
      final agParams = parserResult
          .bind(
            (parser) => CommandResult.getCommandResult(
              parser: parser,
              commandName: Command.iv.name,
              arguments: ['iv'],
            ).bind(
              (argResult) => IntrinsicValue.parseIvParams(
                argResults: argResult,
                stockValues: {},
              ),
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
    'Parse Intrisic Value params is OK',
    () {
      final agParams = parserResult
          .bind(
            (parser) => CommandResult.getCommandResult(
              parser: parser,
              commandName: Command.iv.name,
              arguments: ["iv", "--stock", "./stocks/acls"],
            ).bind(
              (argResult) =>
                  IntrinsicValue.readStockFile(argResult['stock']).bind(
                (stockValues) => IntrinsicValue.parseIvParams(
                  argResults: argResult,
                  stockValues: stockValues,
                ),
              ),
            ),
          )
          .fold(
            (l) => l,
            (r) => r,
          );
      expect(agParams, isA<IntrinsicValueModel>());
    },
  );

  test(
    'calculate Intrinsic value of random values is OK',
    () {
      final intrinsicValue = IntrinsicValue.calculateIntrinsicValue(
        args: IntrinsicValueModel(
          currentYear: 2024,
          cashInCurrentYear: 1.3,
          multiplierAvgPastYears: 13,
          cashOnHand: 3.2,
          growPercentPerYear: 10,
          yearsToPredict: 5,
          discountPercentPerYear: 14,
          safetyMarginPercent: 30,
        ),
      ).fold(
        (l) => l,
        (r) => r,
      );
      expect(intrinsicValue, isA<double>());
    },
  );

  test(
    'Calculate Intrinsic value of the stock on 2023, with 59.48 of free cash flow, P/E of 25, 111.26 of cash, 15% growth, 5 years, 15% of inflation and 30% of margin',
    () {
      final intrinsicValue = IntrinsicValue.calculateIntrinsicValue(
        args: IntrinsicValueModel(
          currentYear: 2023,
          cashInCurrentYear: 59.48,
          multiplierAvgPastYears: 25,
          cashOnHand: 111.26,
          growPercentPerYear: 15,
          yearsToPredict: 5,
          discountPercentPerYear: 15,
          safetyMarginPercent: 30,
        ),
      ).fold(
        (l) => l,
        (r) => r,
      );
      expect(intrinsicValue, isA<double>());
      expect(intrinsicValue, 1326.96);
    },
  );
}
