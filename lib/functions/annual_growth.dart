import 'dart:math';

import 'package:args/args.dart' show ArgResults;
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/models/annual_growth_args.dart';

/// Class for handling calculations related to annual growth.
class AnnualGrowth {
  /// Calculates the annual growth rate.
  ///
  /// This method computes the annual growth rate given the starting price,
  /// the final price, and the number of years over which growth occurred.
  /// It handles edge cases like division by zero.
  ///
  /// Returns an `Either` containing either an `Exception` or the calculated growth rate as a `double`.
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

  /// Parses command line arguments into `AnnualGrowthArgs`.
  ///
  /// This method attempts to parse the command line arguments into the
  /// required format for calculating annual growth. It throws an exception
  /// if the parsing fails.
  ///
  /// Returns an `Either` containing either an `Exception` or `AnnualGrowthArgs`.
  static Either<Exception, AnnualGrowthArgs> parseAgParams(
    ArgResults argResults,
  ) =>
      Either.tryCatch(
        () => AnnualGrowthArgs(
          startPrice: double.parse(argResults['min']),
          finalPrice: double.parse(argResults['max']),
          yearsToGrow: int.parse(argResults['years']),
        ),
        (o, s) => Exception(o),
      );
}
