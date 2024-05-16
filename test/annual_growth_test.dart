import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/annual_growth/errors/annual_growth_errors.dart';
import 'package:intrinsic_value/command/command_parser.dart';
import 'package:intrinsic_value/command/command_result.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:test/test.dart';

import 'utilities.dart' show getContainer;

void main() {
  final container = getContainer();

  group(
    'Test AnnualGrowth functions',
    () {
      test(
        'Annual growth calculator is throwing errors',
        () {
          expect(container.isSome(), true);

          Either<AnnualGrowthError, (Command, double)>.tryCatch(
            () => container.fold(
              () => throw AnnualGrowthCalcError(
                message: 'Error setting up the container',
              ),
              (ref) => ref
                  .read(podCommandParser)
                  .bind(
                    (parser) => ref.read(
                      podCommandResult(parser: parser, arguments: ["ag"]),
                    ),
                  )
                  .getOrElse((l) => throw l),
            ),
            (o, s) => o as AnnualGrowthError,
          ).mapLeft(
            (l) => expect(l, isA<AnnualGrowthCalcError>()),
          );
        },
      );

      test(
        'Annual growth 10%',
        () {
          expect(container.isSome(), true);

          Either<AnnualGrowthError, (Command, double)>.tryCatch(
            () => container.fold(
              () => throw AnnualGrowthCalcError(
                message: 'Error setting up the container',
              ),
              (ref) => ref
                  .read(podCommandParser)
                  .bind(
                    (parser) => ref.read(
                      podCommandResult(parser: parser, arguments: [
                        "ag",
                        "--min",
                        "10",
                        "--max",
                        "11",
                        "-y",
                        "1",
                      ]),
                    ),
                  )
                  .getOrElse((l) => throw l),
            ),
            (o, s) => o as AnnualGrowthError,
          ).fold(
            (l) => expect(l, isA<(Command, double)>()),
            (r) {
              expect(r, isA<(Command, double)>());
              expect(r.$2, 10);
            },
          );
        },
      );

      test(
        'Annual growth 15% y/y for 5 years',
        () {
          expect(container.isSome(), true);

          Either<AnnualGrowthError, (Command, double)>.tryCatch(
            () => container.fold(
              () => throw AnnualGrowthCalcError(
                message: 'Error setting up the container',
              ),
              (ref) => ref
                  .read(podCommandParser)
                  .bind(
                    (parser) => ref.read(
                      podCommandResult(parser: parser, arguments: [
                        "ag",
                        "--min",
                        "10",
                        "--max",
                        "20.11",
                        "-y",
                        "5",
                      ]),
                    ),
                  )
                  .getOrElse((l) => throw l),
            ),
            (o, s) => o as AnnualGrowthError,
          ).fold(
            (l) => expect(l, isA<(Command, double)>()),
            (r) {
              expect(r, isA<(Command, double)>());
              expect(r.$2, 15);
            },
          );
        },
      );
    },
  );
}
