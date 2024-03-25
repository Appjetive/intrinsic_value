import 'dart:math';
import 'package:collection/collection.dart';

class Report {
  Report(this.year, this.cash);

  int year;
  double cash;

  @override
  String toString() {
    return '$year - $cash';
  }
}

void calculateIV({
  required int currentYear,
  required double cashInCurrentYear,
  required int multiplierAvgPastYears,
  required double cashOnHand,
  required double growPercentPerYear,
  int yearsToPredict = 10,
  double discountPercentPerYear = 15,
  double safetyMarginPercent = 30,
  bool debug = false,
}) {
  double growInDecimals = growPercentPerYear / 100 + 1;
  double discountInDecimals = discountPercentPerYear / 100 + 1;
  double safetyMarginInDecimals = safetyMarginPercent / 100;

  final List<Report> freeCashNext = [];
  int currentYearProcessing = currentYear;

  for (int i = 0; i < yearsToPredict; i++) {
    cashInCurrentYear = double.parse(
      (cashInCurrentYear * growInDecimals).toStringAsFixed(2),
    );
    currentYearProcessing++;
    freeCashNext.add(
      Report(currentYearProcessing, cashInCurrentYear),
    );
  }

  double terminalValue = double.parse(
    (freeCashNext.last.cash * multiplierAvgPastYears).toStringAsFixed(2),
  );

  final List<Report> freeCashNextDiscounted = [];
  int currentYearDiscounted = currentYear + 1;

  for (int i = 0, len = freeCashNext.length; i < len; i++) {
    double discFreeCash = freeCashNext[i].cash / pow(discountInDecimals, i + 1);
    freeCashNextDiscounted.add(
      Report(
        currentYearDiscounted,
        double.parse(discFreeCash.toStringAsFixed(2)),
      ),
    );
    currentYearDiscounted++;
  }

  double terminalValueDiscounted = double.parse(
    (terminalValue / pow(discountInDecimals, freeCashNextDiscounted.length))
        .toStringAsFixed(2),
  );

  double intrinsicValue =
      freeCashNextDiscounted.map((e) => e.cash).sum + terminalValueDiscounted;
  intrinsicValue = double.parse(intrinsicValue.toStringAsFixed(2));
  double intrinsicValueAdded = double.parse(
    (intrinsicValue + cashOnHand).toStringAsFixed(2),
  );
  double intrinsicValueSafe = double.parse(
    (intrinsicValueAdded - (intrinsicValueAdded * safetyMarginInDecimals))
        .toStringAsFixed(2),
  );

  if (debug) {
// Print
    freeCashNext.forEach(
      (e) {
        print('${e.toString()}\n');
      },
    );
    print('Terminal Value = $terminalValue');

    print('\n\n====DISCOUNTS===\n\n');

    freeCashNextDiscounted.forEach(
      (e) {
        print('${e.toString()}\n');
      },
    );
  }

  print('Terminal value discounted = $terminalValueDiscounted');
  print('Intrinsic Value = $intrinsicValue Billions');
  print('Intrinsic Value plus cash on hand = $intrinsicValueAdded');
  print('Intrinsic Value with safety margin = $intrinsicValueSafe');
}
