import 'dart:math';

import 'package:args/args.dart' show ArgResults;
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/models/annual_growth_args.dart';

class AnnualGrowth {
  static Either<Exception, double> calculateAnualGrowth(
    AnnualGrowthArgs args,
  ) =>
      Either.tryCatch(
        () {
          if (args.startPrice == 0 || args.yearsToGrow == 0) {
            throw Exception('Division by 0');
          }

          final growth =
              (pow(args.finalPrice / args.startPrice, 1 / args.yearsToGrow) -
                      1) *
                  100;
          return double.parse(growth.toStringAsFixed(2));
        },
        (error, _) => (error is Exception)
            ? error
            : Exception('Error calculating annual growth'),
      );

  static Either<Exception, AnnualGrowthArgs> parseAgParams(
    ArgResults argResults,
  ) =>
      Either.tryCatch(
        () => AnnualGrowthArgs(
          startPrice: double.parse(argResults['min']),
          finalPrice: double.parse(argResults['max']),
          yearsToGrow: int.parse(argResults['years']),
        ),
        (o, s) => Exception('Error parsing options'),
      );
}
