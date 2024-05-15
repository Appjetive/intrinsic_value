import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/annual_growth/annual_growth.dart';
import 'package:intrinsic_value/annual_growth/errors/annual_growth_errors.dart';
import 'package:intrinsic_value/command/command_parser.dart';
import 'package:intrinsic_value/command/command_result.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:intrinsic_value/command/errors/command_errors.dart';
import 'package:test/test.dart';

import 'utilities.dart';

void main() {
  final container = getContainer();

  group(
    'Test AnnualGrowth functions',
    () {
      test(
        'Annual growth calculator is throwing errors',
        () {
          expect(container.isSome(), true);

          final result = container.map(
            (ref) => ref.read(podCommandParser).bind(
                  (parser) => ref.read(
                    podCommandResult(parser: parser, arguments: ["ag"]),
                  ),
                ),
          );

          expect(result.isSome(), true);

          Either.tryCatch(
            () => Either.Do(
              ($) {
                final ref = $(container.toEither(() => throw Error()));
                return ref.read(podCommandParser).bind(
                      (parser) => ref.read(
                        podCommandResult(parser: parser, arguments: ["ag"]),
                      ),
                    );
              },
            ),
            (o, _) => o,
          ).fold(
            (l) => expect(l, isA<AnnualGrowthCalcError>()),
            (r) => expect(r, isA<AnnualGrowthCalcError>()),
          );
        },
      );

      test(
        'Annual growth 10%',
        () {
          expect(container.isSome(), true);
// final ref = $(container.toEither(() => throw Error()));
          Either<CommandError, (Command, double)>.tryCatch(
            () => container.fold(
              () => throw Error(),
              (ref) => ref.read(podCommandParser).bind(
                    (parser) => ref.read(
                      podCommandResult(
                        parser: parser,
                        arguments: [
                          "ag",
                          "--min",
                          "136",
                          "--max",
                          "160",
                          "-y",
                          "1"
                        ],
                      ),
                    ),
                  ),
            ),
            (o, s) => o,
          );

          Option.Do(
            ($) {
              // final ref = $(container);
              // final result = ref.read(
              //   podCalculateAnualGrowth(start: 10, end: 11, years: 1),
              // );
              // expect(result.isRight(), true);

              // expect(
              //   result.getRight().fold(() => null, (t) => t),
              //   10,
              // );
            },
          );
        },
      );

      test(
        'Annual growth 15% y/y for 5 years',
        () {
          expect(container.isSome(), true);

          // Option.Do(
          //   ($) {
          //     final ref = $(container);
          //     final result = ref.read(
          //       podCalculateAnualGrowth(start: 10, end: 20.11, years: 5),
          //     );
          //     expect(result.isRight(), true);

          //     expect(
          //       result.getRight().fold(() => null, (t) => t),
          //       15,
          //     );
          //   },
          // );
        },
      );
    },
  );
}
