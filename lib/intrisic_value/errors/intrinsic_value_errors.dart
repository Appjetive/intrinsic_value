abstract class IntrinsicValueError {
  IntrinsicValueError({required this.message});
  final String message;
}

class IntrinsicValueCalculationError extends IntrinsicValueError {
  IntrinsicValueCalculationError({required super.message});
}
