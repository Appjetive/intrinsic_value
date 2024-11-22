import 'package:args/args.dart' show ArgParser, ArgResults, ArgParserException;
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/enums/command.dart';

/// Type definition for a callback function that takes a [Command] as its parameter.
typedef CommandResultCall = void Function(Command command);

/// Utility class for handling command-line argument parsing results.
class CommandResult {
  /// Parses command-line arguments using the provided `ArgParser`.
  ///
  /// This method attempts to parse the given arguments. If parsing fails due to incorrect
  /// usage, it throws an exception with the appropriate usage information.
  ///
  /// [parser] - The argument parser to use for parsing.
  /// [arguments] - The list of command-line arguments to parse.
  ///
  /// Returns an [Either] which can be either an [Exception] with usage information or
  /// the parsed [ArgResults].
  static Either<Exception, ArgResults> buildCommandArgs({
    required ArgParser parser,
    required List<String> arguments,
  }) =>
      Either.tryCatch(
        () => parser.parse(arguments),
        (o, s) {
          if (o is ArgParserException) {
            throw Exception(
              switch (Option.fromNullable(
                parser.commands[o.commands.first],
              )) {
                Some<ArgParser>(value: final command) => command.usage,
                None() => parser.usage,
              },
            );
          }
          throw Exception(parser.usage);
        },
      );

  /// Retrieves and parses arguments for a specific command.
  ///
  /// This method first checks if the command exists in the parser, then attempts to parse
  /// the arguments for that command. If the command is not found or parsing fails, it returns
  /// an error with usage information.
  ///
  /// [parser] - The main argument parser containing all commands.
  /// [commandName] - The name of the command whose arguments are to be parsed.
  /// [arguments] - The list of arguments to parse for the specified command.
  ///
  /// Returns an [Either] which can be either an [Exception] with usage information or
  /// the parsed [ArgResults] for the specific command.
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
          (_, __) => throw Exception(p.usage),
        ),
      );
}
