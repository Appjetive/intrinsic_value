abstract class CommandError {
  CommandError({required this.message});
  final String message;
}

class CommandErrorUsage extends CommandError {
  CommandErrorUsage({required super.message});
}

class CommandNotFoundError extends CommandError {
  CommandNotFoundError({super.message = 'Command not found'});
}

class CommandIntrinsicValueError extends CommandError {
  CommandIntrinsicValueError({
    super.message = 'Error generating the IV command',
  });
}

class CommandAnnualGrowthError extends CommandError {
  CommandAnnualGrowthError({
    super.message = 'Error generating the AG command',
  });
}
