class Report {
  Report(this.year, this.cash);

  int year;
  double cash;

  @override
  String toString() {
    return '$year - $cash';
  }
}
