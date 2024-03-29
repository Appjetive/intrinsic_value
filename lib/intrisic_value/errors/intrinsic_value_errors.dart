abstract class IntrinsicValueError {
  IntrinsicValueError({required this.message});
  final String message;
}

class IntrinsicValueCalculationError extends IntrinsicValueError {
  IntrinsicValueCalculationError({required super.message});
}

class IntrinsicValueParseError extends IntrinsicValueError {
  IntrinsicValueParseError({required super.message});
}

class IntrinsicValueStockFileError extends IntrinsicValueError {
  IntrinsicValueStockFileError({required super.message});
}
