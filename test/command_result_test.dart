import 'package:args/args.dart';
import 'package:intrinsic_value/enums/command.dart';
import 'package:intrinsic_value/functions/command_parser.dart';
import 'package:intrinsic_value/functions/command_result.dart';
import 'package:test/test.dart';

void main() {
  final parserResult = CommandParser.getParser();

  test(
    'Building Command Arguments is throwing command Error usage',
    () {
      final commandArgs = parserResult
          .bind(
            (parser) => CommandResult.buildCommandArgs(
              parser: parser,
              arguments: [],
            ),
          )
          .fold(
            (l) => l,
            (args) => args,
          );
      expect(commandArgs, isA<Exception>());
    },
  );

  test(
    'Building Command Arguments is OK',
    () {
      final commandArgs = parserResult
          .bind(
            (parser) => CommandResult.buildCommandArgs(
              parser: parser,
              arguments: ['ag'],
            ),
          )
          .fold(
            (l) => l,
            (args) => args,
          );
      expect(commandArgs, isA<ArgResults>());
    },
  );

  test(
    'Get AG command result is OK',
    () {
      final commandResult = parserResult
          .bind(
            (parser) => CommandResult.getCommandResult(
              parser: parser,
              commandName: Command.ag.name,
              arguments: ['ag'],
            ),
          )
          .fold(
            (l) => l,
            (result) => result,
          );
      expect(commandResult, isA<ArgResults>());
    },
  );
}
