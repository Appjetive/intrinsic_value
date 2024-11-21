// import 'package:fpdart/fpdart.dart';
// import 'package:intrinsic_value/functions/command_parser.dart';
// import 'package:intrinsic_value/functions/command_result.dart';
// import 'package:intrinsic_value/enums/command.dart';
// import 'package:intrinsic_value/errors/intrinsic_value_errors.dart';
// import 'package:test/test.dart';

// import 'utilities.dart' show getContainer;

// void main() {
//   final container = getContainer();

//   group(
//     'Test Intrisic value functions',
//     () {
//       test(
//         'Intrinsic value calculator is throwing errors',
//         () {
//           expect(container.isSome(), true);

//           Either<IntrinsicValueError, (Command, double)>.tryCatch(
//             () => container.fold(
//               () => throw IntrinsicValueCalculationError(
//                 message: 'Error setting up the container',
//               ),
//               (ref) => ref
//                   .read(podCommandParser)
//                   .bind(
//                     (parser) => ref.read(
//                       podCommandResult(parser: parser, arguments: ["iv"]),
//                     ),
//                   )
//                   .getOrElse((l) => throw l),
//             ),
//             (o, s) => o as IntrinsicValueError,
//           ).mapLeft(
//             (l) => expect(l, isA<IntrinsicValueParseError>()),
//           );
//         },
//       );

//       test('calculate Intrinsic value of Google', () {
//         expect(container.isSome(), true);

//         Either<IntrinsicValueError, (Command, double)>.tryCatch(
//           () => container.fold(
//             () => throw IntrinsicValueCalculationError(
//               message: 'Error setting up the container',
//             ),
//             (ref) => ref
//                 .read(podCommandParser)
//                 .bind(
//                   (parser) => ref.read(
//                     podCommandResult(
//                       parser: parser,
//                       arguments: ["iv", "--stock", "./stocks/alphabet"],
//                     ),
//                   ),
//                 )
//                 .getOrElse((l) => throw l),
//           ),
//           (o, s) => o as IntrinsicValueError,
//         ).fold(
//           (l) => expect(l, isA<IntrinsicValueParseError>()),
//           (r) => expect(r.$2, 936.52),
//         );
//       });

//       test(
//         'calculate Intrinsic value of Microsoft with 15% growth, 5 years, 15% of inflation and 30% of margin',
//         () {
//           expect(container.isSome(), true);

//           Either<IntrinsicValueError, (Command, double)>.tryCatch(
//             () => container.fold(
//               () => throw IntrinsicValueCalculationError(
//                 message: 'Error setting up the container',
//               ),
//               (ref) => ref
//                   .read(podCommandParser)
//                   .bind(
//                     (parser) => ref.read(
//                       podCommandResult(
//                         parser: parser,
//                         arguments: [
//                           "iv",
//                           "--stock",
//                           "./stocks/msft",
//                           "-g",
//                           "15",
//                           "-y",
//                           "5",
//                           "-f",
//                           "30",
//                           "-d",
//                           "15",
//                         ],
//                       ),
//                     ),
//                   )
//                   .getOrElse((l) => throw l),
//             ),
//             (o, s) => o as IntrinsicValueError,
//           ).fold(
//             (l) => expect(l, isA<IntrinsicValueParseError>()),
//             (r) => expect(r.$2, 1326.96),
//           );
//         },
//       );
//     },
//   );
// }

import 'package:intrinsic_value/enums/command.dart';
import 'package:intrinsic_value/functions/command_parser.dart';
import 'package:intrinsic_value/functions/command_result.dart';
import 'package:intrinsic_value/functions/intrinsic_value.dart';
import 'package:intrinsic_value/models/intrinsic_value_model.dart';
import 'package:test/test.dart';

void main() {
  final parserResult = CommandParser.getParser();

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
              (argResult) => IntrinsicValue.parseIvParams(argResult),
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
              arguments: ["iv", "--stock", "./stocks/alphabet"],
            ).bind(
              (argResult) => IntrinsicValue.parseIvParams(argResult),
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
