import 'dart:math';

import 'package:args/args.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:intrinsic_value/annual_growth/errors/annual_growth_errors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'annual_growth.g.dart';

@riverpod
fpdart.Either<AnnualGrowthError, double> calculateAnualGrowth(
  CalculateAnualGrowthRef ref,
  ArgResults argResults,
) =>
    fpdart.Either.tryCatch(
      () => _parseParams(argResults).match(
        (l) => throw l,
        (r) => fpdart.Option.Do(
          ($) {
            final start = $(r.$1);
            final end = $(r.$2);
            final years = $(r.$3);

            if (start == 0 || years == 0) {
              throw AnnualGrowthCalcError(message: 'Division by 0');
            }

            final growth = (pow(end / start, 1 / years) - 1) * 100;
            return double.parse(growth.toStringAsFixed(2));
          },
        ).getOrElse(
          () => throw AnnualGrowthCalcError(message: 'Undefined error'),
        ),
      ),
      (error, _) => (error is AnnualGrowthError)
          ? error
          : AnnualGrowthCalcError(message: 'Error calculating annual growth'),
    );

fpdart.Either<
    AnnualGrowthError,
    (
      fpdart.Option<double>,
      fpdart.Option<double>,
      fpdart.Option<int>,
    )> _parseParams(ArgResults argResults) => fpdart.Either.tryCatch(
      () {
        final minValue =
            fpdart.Option.tryCatch(() => double.parse(argResults['min']));
        final maxValue =
            fpdart.Option.tryCatch(() => double.parse(argResults['max']));
        final years =
            fpdart.Option.tryCatch(() => int.parse(argResults['years']));

        return (minValue, maxValue, years);
      },
      (o, s) => AnnualGrowthCalcError(message: 'Error parsing options'),
    );
