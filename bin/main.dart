import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/functions/annual_growth.dart';
import 'package:intrinsic_value/functions/command_parser.dart';
import 'package:intrinsic_value/functions/command_result.dart';
import 'package:intrinsic_value/enums/command.dart';
import 'package:intrinsic_value/extensions/command_extension.dart';
import 'package:intrinsic_value/functions/intrinsic_value.dart';

final debug = true;

void main(List<String> args) {
  Either.tryCatch(
    () => Either<Exception, void>.Do(
      ($) {
        final parser = $(CommandParser.getParser());
        final commandArgs = $(
          CommandResult.buildCommandArgs(
            parser: parser,
            arguments: args,
          ),
        );
        final command = commandArgs.name.command();

        final commandResult = $(
          CommandResult.getCommandResult(
            parser: parser,
            commandName: command.name,
            arguments: args,
          ),
        );

        final messageToPrint = switch (command) {
          Command.ag => AnnualGrowth.parseAgParams(commandResult)
              .bind(AnnualGrowth.calculateAnualGrowth)
              .fold(
                (l) => throw l,
                (result) => 'Annual growth: $result',
              ),
          Command.iv => IntrinsicValue.parseIvParams(commandResult)
              .bind(
                (args) => IntrinsicValue.calculateIntrinsicValue(
                  args: args,
                  debug: debug,
                ),
              )
              .fold(
                (l) => throw l,
                (result) => 'Intrinsic value: $result',
              ),
        };

        return print(messageToPrint);
      },
    ),
    (o, s) {
      print(o);
      if (debug) {
        print(StackTrace.current);
      }
    },
  );
}
