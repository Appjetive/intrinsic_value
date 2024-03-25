import 'dart:math';

void calculateAnualGrowth(
  double initialValue,
  double finalValue, {
  int years = 10,
}) {
  double anualGrowth = (pow(finalValue / initialValue, 1 / years) - 1) * 100;

  print("Anual Growth: ${anualGrowth.round()}%");
}
