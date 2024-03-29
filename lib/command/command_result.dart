import 'package:args/args.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:intrinsic_value/annual_growth/annual_growth.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:intrinsic_value/command/errors/command_errors.dart';
import 'package:intrinsic_value/command/extensions/command_extension.dart';
import 'package:intrinsic_value/intrisic_value/intrinsic_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_result.g.dart';

typedef CommandResultCall = void Function(Command command);

@riverpod
fpdart.Either<CommandError, Function> commandResult(
  CommandResultRef ref, {
  required ArgParser parser,
  required List<String> arguments,
}) =>
    fpdart.Either.Do(
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
              Command.iv => ref
                  .read(podCalculateIntrinsicValue(
                    commandResult: commandResult,
                    debug: true,
                  ))
                  .match(
                    (l) => print(l.message),
                    (r) => print('Intrinsic Value = $r'),
                  ),
              Command.ag =>
                ref.read(podCalculateAnualGrowth(commandResult)).match(
                      (l) => print(l.message),
                      (r) => print('Annual growth: %$r'),
                    ),
              Command.none => (),
            };
      },
    );

fpdart.Either<CommandError, ArgResults> _buildCommand({
  required ArgParser parser,
  required List<String> arguments,
}) =>
    fpdart.Either.tryCatch(
      () => parser.parse(arguments),
      (o, s) {
        if (o is ArgParserException) {
          return CommandErrorUsage(
            message: switch (fpdart.Option.fromNullable(
              parser.commands[o.commands.first],
            )) {
              fpdart.Some<ArgParser>(value: final command) => command.usage,
              fpdart.None() => parser.usage,
            },
          );
        }
        return CommandErrorUsage(message: parser.usage);
      },
    ).flatMap(
      (a) => fpdart.Either.fromNullable(
        a.command,
        () => CommandErrorUsage(message: parser.usage),
      ),
    );

fpdart.Either<CommandError, ArgResults> _buildCommandResult({
  required ArgParser parser,
  required Command command,
  required List<String> arguments,
}) =>
    fpdart.Either.fromNullable(
      parser.commands[command.name],
      () => CommandErrorUsage(message: parser.usage),
    ).flatMap(
      (p) => fpdart.Either.tryCatch(
        () => p.parse(arguments),
        (_, __) => CommandErrorUsage(message: p.usage),
      ),
    );
