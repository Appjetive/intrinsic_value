abstract class AnnualGrowthError {
  AnnualGrowthError({required this.message});

  final String message;
}

class AnnualGrowthCalcError extends AnnualGrowthError {
  AnnualGrowthCalcError({required super.message});
}
