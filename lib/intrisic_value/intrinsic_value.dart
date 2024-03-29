import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:intrinsic_value/intrisic_value/errors/intrinsic_value_errors.dart';
import 'package:intrinsic_value/intrisic_value/models/intrinsic_value_model.dart';
import 'package:intrinsic_value/intrisic_value/models/report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'intrinsic_value.g.dart';

@riverpod
fpdart.Either<IntrinsicValueError, double> calculateIntrinsicValue(
  CalculateIntrinsicValueRef ref, {
  required ArgResults commandResult,
  bool debug = false,
}) =>
    fpdart.Either<IntrinsicValueError, double>.Do(
      ($) {
        final values = $(_parseCommandResult(commandResult));

        final freeCashReports = $(_getFreeCashReports(values: values));
        final freeCashDiscountedReports = $(
          _getFreeCashReportsDiscounted(
            currentYear: values.currentYear,
            reports: freeCashReports,
            discountPercentPerYear: values.discountPercentPerYear,
          ),
        );

        if (debug) {
          // Print free cash reports
          for (final e in freeCashReports) {
            print('${e.toString()}\n');
          }
          print(
            'Terminal Value = ${freeCashReports.last.cash * values.multiplierAvgPastYears}',
          );

          print('\n\n====DISCOUNTS===\n\n');

          for (final e in freeCashDiscountedReports) {
            print('${e.toString()}\n');
          }
        }

        return $(
          _calculateIntrinsicValue(
            cashOnHand: values.cashOnHand,
            freeCashDiscountedReports: freeCashDiscountedReports,
            freeCashReports: freeCashReports,
            multiplierAvgPastYears: values.multiplierAvgPastYears,
            discountPercentPerYear: values.discountPercentPerYear,
            safetyMarginPercent: values.safetyMarginPercent,
          ),
        );
      },
    );

fpdart.Either<IntrinsicValueError, IntrinsicValueModel> _parseCommandResult(
  ArgResults argResults,
) =>
    fpdart.Either.tryCatch(
      () {
        // Getting options
        final growPercentPerYear = fpdart.Option.tryCatch(
          () => double.parse(argResults['growth']),
        ).getOrElse(() => 10);

        final yearsToPredict = fpdart.Option.tryCatch(
          () => int.parse(argResults['years']),
        ).getOrElse(() => 5);

        final discountPercentPerYear = fpdart.Option.tryCatch(
          () => double.parse(argResults['discount']),
        ).getOrElse(() => 15);

        final safetyMarginPercent = fpdart.Option.tryCatch(
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
                lineParts.first.trim(): fpdart.Either.tryCatch(
                  () => num.parse(lineParts.last.trim()),
                  (_, __) => Exception(),
                ).getOrElse((l) => throw l),
              };
            },
          ),
        );

        final cashOnHand = fpdart.Option.fromNullable(
          stockValues['cashOnHand'],
        ).flatMap((t) => fpdart.some(t.toDouble()));

        final cashInCurrentYear = fpdart.Option.fromNullable(
          stockValues['cashInCurrentYear'],
        ).flatMap((t) => fpdart.some(t.toDouble()));

        final currentYear = fpdart.Option.fromNullable(
          stockValues['currentYear'],
        ).flatMap((t) => fpdart.some(t.toInt()));

        final multiplierAvgPastYears = fpdart.Option.fromNullable(
          stockValues['multiplierAvgPastYears'],
        ).flatMap((t) => fpdart.some(t.toDouble()));

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
      (o, s) => IntrinsicValueParseError(message: 'Error parsing stock values'),
    );

fpdart.Either<IntrinsicValueError, List<String>> _readStockFile(String path) =>
    fpdart.Either.tryCatch(
      () => File(path).readAsLinesSync(),
      (o, s) => IntrinsicValueStockFileError(
        message: 'The stock file doesn\'t exist in the provided path.',
      ),
    );

fpdart.Either<IntrinsicValueError, List<Report>> _getFreeCashReports({
  required IntrinsicValueModel values,
}) =>
    fpdart.Either.tryCatch(
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
      (_, __) => IntrinsicValueCalculationError(
        message: 'Error generating a terminal value reports',
      ),
    );

fpdart.Either<IntrinsicValueError, List<Report>> _getFreeCashReportsDiscounted({
  required int currentYear,
  required List<Report> reports,
  double discountPercentPerYear = 15,
}) =>
    fpdart.Either.tryCatch(
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
      (o, s) => IntrinsicValueCalculationError(
        message: 'Error generating a terminal value discounted',
      ),
    );

fpdart.Either<IntrinsicValueError, double> _calculateIntrinsicValue({
  required List<Report> freeCashDiscountedReports,
  required List<Report> freeCashReports,
  required double cashOnHand,
  required double multiplierAvgPastYears,
  double safetyMarginPercent = 30,
  double discountPercentPerYear = 15,
}) =>
    fpdart.Either.tryCatch(
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
      (o, s) => IntrinsicValueCalculationError(
        message: 'Error calculating the intrinsic value',
      ),
    );
