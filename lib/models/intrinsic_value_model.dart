class IntrinsicValueModel {
  IntrinsicValueModel({
    required this.currentYear,
    required this.cashInCurrentYear,
    required this.multiplierAvgPastYears,
    required this.cashOnHand,
    required this.growPercentPerYear,
    required this.yearsToPredict,
    required this.discountPercentPerYear,
    required this.safetyMarginPercent,
    this.sharesOutstanding = 1,
  });

  final int currentYear;
  final double cashInCurrentYear;
  final double multiplierAvgPastYears;
  final double cashOnHand;
  final double growPercentPerYear;
  final int yearsToPredict;
  final double discountPercentPerYear;
  final double safetyMarginPercent;
  final double sharesOutstanding;
}
