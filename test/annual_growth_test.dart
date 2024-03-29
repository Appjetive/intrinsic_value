import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/annual_growth/annual_growth.dart';
import 'package:intrinsic_value/annual_growth/errors/annual_growth_errors.dart';
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

          Option.Do(
            ($) {
              final ref = $(container);
              final result = ref.read(
                podCalculateAnualGrowth(start: 0, end: 10, years: 0),
              );
              expect(result.isLeft(), true);

              expect(
                result.fold((l) => l, (r) => r),
                isA<AnnualGrowthCalcError>(),
              );
            },
          );
        },
      );

      test(
        'Annual growth 10%',
        () {
          expect(container.isSome(), true);

          Option.Do(
            ($) {
              final ref = $(container);
              final result = ref.read(
                podCalculateAnualGrowth(start: 10, end: 11, years: 1),
              );
              expect(result.isRight(), true);

              expect(
                result.getRight().fold(() => null, (t) => t),
                10,
              );
            },
          );
        },
      );

      test(
        'Annual growth 15% y/y for 5 years',
        () {
          expect(container.isSome(), true);

          Option.Do(
            ($) {
              final ref = $(container);
              final result = ref.read(
                podCalculateAnualGrowth(start: 10, end: 20.11, years: 5),
              );
              expect(result.isRight(), true);

              expect(
                result.getRight().fold(() => null, (t) => t),
                15,
              );
            },
          );
        },
      );
    },
  );
}
