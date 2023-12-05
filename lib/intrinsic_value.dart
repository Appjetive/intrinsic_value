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

void calculate() {
  double growPercentPerYear = 10;
  double growInDecimals = growPercentPerYear / 100 + 1;
  double multiplierAvg = 10;
  double discountPercentPerYear = 15;
  double discountInDecimals = discountPercentPerYear / 100 + 1;
  double safetyMarginPercent = 30;
  double safetyMarginInDecimals = safetyMarginPercent / 100;
  double cashOnHand = 67.15;

  final List<Report> freeCashNext = [];
  int yearsToPredict = 10;
  int currentYear = 2016;
  double cashInCurrentYear = 53.50;

  for (int i = 0; i < yearsToPredict; i++) {
    cashInCurrentYear = double.parse(
      (cashInCurrentYear * growInDecimals).toStringAsFixed(2),
    );
    currentYear++;
    freeCashNext.add(
      Report(currentYear, cashInCurrentYear),
    );
  }

  double terminalValue = freeCashNext.last.cash * multiplierAvg;

  final List<Report> freeCashNextDiscounted = [];
  int currentYearDiscounted = 2017;

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
  double intrinsicValueAdded = intrinsicValue + cashOnHand;
  double intrinsicValueSafe = double.parse(
    (intrinsicValueAdded - (intrinsicValueAdded * safetyMarginInDecimals))
        .toStringAsFixed(2),
  );

  // Print
  freeCashNext.forEach(
    (e) {
      print('${e.toString()} Billions\n');
    },
  );
  print('Terminal Value = $terminalValue Billions');

  print('\n\n====DISCOUNTS===\n\n');

  freeCashNextDiscounted.forEach(
    (e) {
      print('${e.toString()} Billions\n');
    },
  );

  print('Terminal value discounted = $terminalValueDiscounted Billions');
  print('Intrinsic Value = $intrinsicValue Billions');
  print('Intrinsic Value plus cash on hand = $intrinsicValueAdded Billions');
  print('Intrinsic Value with safety margin = $intrinsicValueSafe Billions');
}
