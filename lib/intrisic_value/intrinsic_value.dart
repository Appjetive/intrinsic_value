import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/intrisic_value/errors/intrinsic_value_errors.dart';
import 'package:intrinsic_value/intrisic_value/models/report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'intrinsic_value.g.dart';

@riverpod
Either<IntrinsicValueError, double> calculateIntrinsicValue(
  CalculateIntrinsicValueRef ref, {
  required int currentYear,
  required double cashInCurrentYear,
  required int multiplierAvgPastYears,
  required double cashOnHand,
  required double growPercentPerYear,
  int yearsToPredict = 10,
  double discountPercentPerYear = 15,
  double safetyMarginPercent = 30,
  bool debug = false,
}) =>
    Either<IntrinsicValueError, double>.Do(
      ($) {
        final freeCashReports = $(
          _getFreeCashReports(
            currentYear: currentYear,
            multiplierAvgPastYears: multiplierAvgPastYears,
            cashInCurrentYear: cashInCurrentYear,
            growPercentPerYear: growPercentPerYear,
            yearsToPredict: yearsToPredict,
          ),
        );
        final freeCashDiscountedReports = $(
          _getFreeCashReportsDiscounted(
            currentYear: currentYear,
            reports: freeCashReports,
            discountPercentPerYear: discountPercentPerYear,
          ),
        );

        if (debug) {
          // Print free cash reports
          for (final e in freeCashReports) {
            print('${e.toString()}\n');
          }
          print(
            'Terminal Value = ${freeCashReports.last.cash * multiplierAvgPastYears}',
          );

          print('\n\n====DISCOUNTS===\n\n');

          for (final e in freeCashDiscountedReports) {
            print('${e.toString()}\n');
          }
        }

        return $(
          _calculateIntrinsicValue(
            cashOnHand: cashOnHand,
            freeCashDiscountedReports: freeCashDiscountedReports,
            freeCashReports: freeCashReports,
            multiplierAvgPastYears: multiplierAvgPastYears,
            discountPercentPerYear: discountPercentPerYear,
            safetyMarginPercent: safetyMarginPercent,
          ),
        );
      },
    );

Either<IntrinsicValueError, List<Report>> _getFreeCashReports({
  required int currentYear,
  required int multiplierAvgPastYears,
  required double cashInCurrentYear,
  required double growPercentPerYear,
  int yearsToPredict = 10,
}) =>
    Either.tryCatch(
      () => List.generate(yearsToPredict, (i) => currentYear + i + 1)
          .foldLeftWithIndex(
        [],
        (reports, year, i) => reports
          ..add(
            Report(
              year,
              (i == 0 ? cashInCurrentYear : reports.last.cash) *
                  (growPercentPerYear / 100 + 1),
            ),
          ),
      ),
      (_, __) => IntrinsicValueCalculationError(
        message: 'Error generating a terminal value reports',
      ),
    );

Either<IntrinsicValueError, List<Report>> _getFreeCashReportsDiscounted({
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
      (o, s) => IntrinsicValueCalculationError(
        message: 'Error generating a terminal value discounted',
      ),
    );

Either<IntrinsicValueError, double> _calculateIntrinsicValue({
  required List<Report> freeCashDiscountedReports,
  required List<Report> freeCashReports,
  required double cashOnHand,
  required int multiplierAvgPastYears,
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
      (o, s) => IntrinsicValueCalculationError(
        message: 'Error calculating the intrinsic value',
      ),
    );
