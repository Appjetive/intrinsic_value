import 'dart:io';
import 'dart:math';
import 'package:args/args.dart' show ArgResults;
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/models/intrinsic_value_model.dart';
import 'package:intrinsic_value/models/report.dart';

class IntrinsicValue {
  static Either<Exception, double> calculateIntrinsicValue({
    required IntrinsicValueModel args,
    bool debug = false,
  }) =>
      Either<Exception, double>.Do(
        ($) {
          final freeCashReports = $(_getFreeCashReports(values: args));
          final freeCashDiscountedReports = $(
            _getFreeCashReportsDiscounted(
              currentYear: args.currentYear,
              reports: freeCashReports,
              discountPercentPerYear: args.discountPercentPerYear,
            ),
          );

          if (debug) {
            // Print free cash reports
            for (final e in freeCashReports) {
              print('${e.toString()}\n');
            }
            print(
              'Terminal Value = ${freeCashReports.last.cash * args.multiplierAvgPastYears}',
            );

            print('\n\n====DISCOUNTS===\n\n');

            for (final e in freeCashDiscountedReports) {
              print('${e.toString()}\n');
            }
          }

          return $(
            _calculateIntrinsicValue(
              cashOnHand: args.cashOnHand,
              freeCashDiscountedReports: freeCashDiscountedReports,
              freeCashReports: freeCashReports,
              multiplierAvgPastYears: args.multiplierAvgPastYears,
              discountPercentPerYear: args.discountPercentPerYear,
              safetyMarginPercent: args.safetyMarginPercent,
            ),
          );
        },
      );

  static Either<Exception, IntrinsicValueModel> parseIvParams(
    ArgResults argResults,
  ) =>
      Either.tryCatch(
        () {
          // Getting options
          final growPercentPerYear = Option.tryCatch(
            () => double.parse(argResults['growth']),
          ).getOrElse(() => 10);

          final yearsToPredict = Option.tryCatch(
            () => int.parse(argResults['years']),
          ).getOrElse(() => 5);

          final discountPercentPerYear = Option.tryCatch(
            () => double.parse(argResults['discount']),
          ).getOrElse(() => 15);

          final safetyMarginPercent = Option.tryCatch(
            () => double.parse(argResults['safety']),
          ).getOrElse(() => 30);

          final stockValues = _readStockFile(argResults['stock']).match(
            (l) => throw l,
            (fileLines) => fileLines.foldLeft(
              <String, num>{},
              (b, line) {
                final lineParts = line.split('=');
                return {
                  ...b,
                  lineParts.first.trim(): Either.tryCatch(
                    () => num.parse(lineParts.last.trim()),
                    (_, __) => Exception(),
                  ).getOrElse((l) => throw l),
                };
              },
            ),
          );

          final cashOnHand = Option.fromNullable(
            stockValues['cashOnHand'],
          ).flatMap((t) => some(t.toDouble()));

          final cashInCurrentYear = Option.fromNullable(
            stockValues['cashInCurrentYear'],
          ).flatMap((t) => some(t.toDouble()));

          final currentYear = Option.fromNullable(
            stockValues['currentYear'],
          ).flatMap((t) => some(t.toInt()));

          final multiplierAvgPastYears = Option.fromNullable(
            stockValues['multiplierAvgPastYears'],
          ).flatMap((t) => some(t.toDouble()));

          return IntrinsicValueModel(
            growPercentPerYear: growPercentPerYear,
            cashOnHand: cashOnHand.getOrElse(() => throw Exception()),
            cashInCurrentYear: cashInCurrentYear.getOrElse(
              () => throw Exception(),
            ),
            currentYear: currentYear.getOrElse(() => throw Exception()),
            multiplierAvgPastYears: multiplierAvgPastYears.getOrElse(
              () => throw Exception(),
            ),
            yearsToPredict: yearsToPredict,
            discountPercentPerYear: discountPercentPerYear,
            safetyMarginPercent: safetyMarginPercent,
          );
        },
        (o, s) => Exception('Error parsing stock values'),
      );

  static Either<Exception, List<String>> _readStockFile(String path) =>
      Either.tryCatch(
        () => File(path).readAsLinesSync(),
        (o, s) => Exception(
          'The stock file doesn\'t exist in the provided path.',
        ),
      );

  static Either<Exception, List<Report>> _getFreeCashReports({
    required IntrinsicValueModel values,
  }) =>
      Either.tryCatch(
        () => List.generate(
          values.yearsToPredict,
          (i) => values.currentYear + i + 1,
        ).foldLeftWithIndex(
          [],
          (reports, year, i) => reports
            ..add(
              Report(
                year,
                (i == 0 ? values.cashInCurrentYear : reports.last.cash) *
                    (values.growPercentPerYear / 100 + 1),
              ),
            ),
        ),
        (_, __) => Exception(
          'Error generating a terminal value reports',
        ),
      );

  static Either<Exception, List<Report>> _getFreeCashReportsDiscounted({
    required int currentYear,
    required List<Report> reports,
    double discountPercentPerYear = 15,
  }) =>
      Either.tryCatch(
        () => reports.foldLeftWithIndex(
          [],
          (b, t, i) => b
            ..add(
              Report(
                t.year,
                t.cash / pow(discountPercentPerYear / 100 + 1, i + 1),
              ),
            ),
        ),
        (o, s) => Exception(
          'Error generating a terminal value discounted',
        ),
      );

  static Either<Exception, double> _calculateIntrinsicValue({
    required List<Report> freeCashDiscountedReports,
    required List<Report> freeCashReports,
    required double cashOnHand,
    required double multiplierAvgPastYears,
    double safetyMarginPercent = 30,
    double discountPercentPerYear = 15,
  }) =>
      Either.tryCatch(
        () {
          final intrinsicValueAdded =
              freeCashDiscountedReports.map((e) => e.cash).sum +
                  freeCashReports.last.cash *
                      multiplierAvgPastYears /
                      pow((discountPercentPerYear / 100 + 1),
                          freeCashDiscountedReports.length) +
                  cashOnHand;

          if (intrinsicValueAdded.isInfinite) {
            throw Exception('Error');
          }

          return double.parse(
            (intrinsicValueAdded -
                    (intrinsicValueAdded * (safetyMarginPercent / 100)))
                .toStringAsFixed(2),
          );
        },
        (o, s) => Exception(
          'Error calculating the intrinsic value',
        ),
      );
}
