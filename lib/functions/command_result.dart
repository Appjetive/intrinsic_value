import 'package:args/args.dart' show ArgParser, ArgResults, ArgParserException;
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/enums/command.dart';

typedef CommandResultCall = void Function(Command command);

class CommandResult {
  static Either<Exception, ArgResults> buildCommandArgs({
    required ArgParser parser,
    required List<String> arguments,
  }) =>
      Either.tryCatch(
        () => parser.parse(arguments),
        (o, s) {
          if (o is ArgParserException) {
            return Exception(
              switch (Option.fromNullable(
                parser.commands[o.commands.first],
              )) {
                Some<ArgParser>(value: final command) => command.usage,
                None() => parser.usage,
              },
            );
          }
          return Exception(parser.usage);
        },
      ).flatMap(
        (a) => Either.fromNullable(
          a.command,
          () => Exception(parser.usage),
        ),
      );

  static Either<Exception, ArgResults> getCommandResult({
    required ArgParser parser,
    required String commandName,
    required List<String> arguments,
  }) =>
      Either.fromNullable(
        parser.commands[commandName],
        () => Exception(parser.usage),
      ).flatMap(
        (p) => Either.tryCatch(
          () => p.parse(arguments),
          (_, __) => Exception(p.usage),
        ),
      );
}
