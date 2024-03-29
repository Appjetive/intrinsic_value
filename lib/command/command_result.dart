import 'package:args/args.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/annual_growth/annual_growth.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:intrinsic_value/command/errors/command_errors.dart';
import 'package:intrinsic_value/command/extensions/command_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_result.g.dart';

typedef CommandResultCall = void Function(Command command);

@riverpod
Either<CommandError, Function> commandResult(
  CommandResultRef ref, {
  required ArgParser parser,
  required List<String> arguments,
}) =>
    Either.Do(
      ($) {
        final command = $(_buildCommand(parser: parser, arguments: arguments));
        final commandResult = $(
          _buildCommandResult(
            parser: parser,
            command: command.name.command(),
            arguments: arguments,
          ),
        );

        return () => switch (command.name.command()) {
              Command.iv => (),
              Command.ag =>
                ref.read(podCalculateAnualGrowth(commandResult)).match(
                      (l) => print(l.message),
                      (r) => print('Annual growth: %$r'),
                    ),
              Command.none => (),
            };
      },
    );

Either<CommandError, ArgResults> _buildCommand({
  required ArgParser parser,
  required List<String> arguments,
}) =>
    Either.tryCatch(
      () => parser.parse(arguments),
      (o, s) {
        return CommandErrorUsage(message: parser.usage);
      },
    ).flatMap(
      (a) => Either.fromNullable(
        a.command,
        () => CommandErrorUsage(message: parser.usage),
      ),
    );

Either<CommandError, ArgResults> _buildCommandResult({
  required ArgParser parser,
  required Command command,
  required List<String> arguments,
}) =>
    Either.fromNullable(
      parser.commands[command.name],
      () => CommandErrorUsage(message: parser.usage),
    ).flatMap(
      (p) => Either.tryCatch(
        () => p.parse(arguments),
        (_, __) => CommandErrorUsage(message: p.usage),
      ),
    );
