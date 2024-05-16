import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/command/command_parser.dart';
import 'package:intrinsic_value/command/command_result.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:intrinsic_value/intrisic_value/errors/intrinsic_value_errors.dart';
import 'package:test/test.dart';

import 'utilities.dart' show getContainer;

void main() {
  final container = getContainer();

  group(
    'Test Intrisic value functions',
    () {
      test(
        'Intrinsic value calculator is throwing errors',
        () {
          expect(container.isSome(), true);

          Either<IntrinsicValueError, (Command, double)>.tryCatch(
            () => container.fold(
              () => throw IntrinsicValueCalculationError(
                message: 'Error setting up the container',
              ),
              (ref) => ref
                  .read(podCommandParser)
                  .bind(
                    (parser) => ref.read(
                      podCommandResult(parser: parser, arguments: ["iv"]),
                    ),
                  )
                  .getOrElse((l) => throw l),
            ),
            (o, s) => o as IntrinsicValueError,
          ).mapLeft(
            (l) => expect(l, isA<IntrinsicValueParseError>()),
          );
        },
      );

      test('calculate Intrinsic value of Google', () {
        expect(container.isSome(), true);

        Either<IntrinsicValueError, (Command, double)>.tryCatch(
          () => container.fold(
            () => throw IntrinsicValueCalculationError(
              message: 'Error setting up the container',
            ),
            (ref) => ref
                .read(podCommandParser)
                .bind(
                  (parser) => ref.read(
                    podCommandResult(
                      parser: parser,
                      arguments: ["iv", "--stock", "./stocks/alphabet"],
                    ),
                  ),
                )
                .getOrElse((l) => throw l),
          ),
          (o, s) => o as IntrinsicValueError,
        ).fold(
          (l) => expect(l, isA<IntrinsicValueParseError>()),
          (r) => expect(r.$2, 936.52),
        );
      });

      test(
        'calculate Intrinsic value of Microsoft with 15% growth, 5 years, 15% of inflation and 30% of margin',
        () {
          expect(container.isSome(), true);

          Either<IntrinsicValueError, (Command, double)>.tryCatch(
            () => container.fold(
              () => throw IntrinsicValueCalculationError(
                message: 'Error setting up the container',
              ),
              (ref) => ref
                  .read(podCommandParser)
                  .bind(
                    (parser) => ref.read(
                      podCommandResult(
                        parser: parser,
                        arguments: [
                          "iv",
                          "--stock",
                          "./stocks/msft",
                          "-g",
                          "15",
                          "-y",
                          "5",
                          "-f",
                          "30",
                          "-d",
                          "15",
                        ],
                      ),
                    ),
                  )
                  .getOrElse((l) => throw l),
            ),
            (o, s) => o as IntrinsicValueError,
          ).fold(
            (l) => expect(l, isA<IntrinsicValueParseError>()),
            (r) => expect(r.$2, 1326.96),
          );
        },
      );
    },
  );
}
