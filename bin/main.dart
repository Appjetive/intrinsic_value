import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/functions/annual_growth.dart';
import 'package:intrinsic_value/functions/command_parser.dart';
import 'package:intrinsic_value/functions/command_result.dart';
import 'package:intrinsic_value/enums/command.dart';
import 'package:intrinsic_value/extensions/command_extension.dart';
import 'package:intrinsic_value/functions/intrinsic_value.dart';

/// Flag to enable or disable debug mode for detailed error logging.
final debug = true;

void main(List<String> args) {
  /// Wraps the main execution in a try-catch for error handling, using `Either` for functional error management.
  Either.tryCatch(
    () => Either<Exception, void>.Do(
      ($) {
        // Parse command line arguments into a command parser object.
        final parser = $(CommandParser.getParser());

        // Build command arguments.
        final commandArgs = $(
          CommandResult.buildCommandArgs(
            parser: parser,
            arguments: args,
          ),
        );

        // Get a command name string from the parsed args.
        final command = Either<Exception, String>.fromNullable(
          commandArgs.name,
          () => Exception('Error identifying the command'),
        );

        // Get the detailed result of the command execution.
        final commandResult = $(
          CommandResult.getCommandResult(
            parser: parser,
            commandName: $(command),
            arguments: args,
          ),
        );

        // Process the command and prepare the output message.
        final messageToPrint = switch ($(command).command()) {
          Command.ag => AnnualGrowth.parseAgParams(commandResult)
              .bind(AnnualGrowth.calculateAnualGrowth)
              .fold(
                (l) => throw l,
                (result) => 'Annual growth: $result',
              ),
          Command.iv => IntrinsicValue.readStockFile(commandResult['stock'])
              .bind((stockValues) => IntrinsicValue.parseIvParams(
                    argResults: commandResult,
                    stockValues: stockValues,
                  ).bind(
                    (args) => IntrinsicValue.calculateIntrinsicValue(
                      args: args,
                      debug: debug,
                    ),
                  ))
              .fold(
                (l) => throw l,
                (result) => 'Intrinsic value: $result',
              ),
          Command.none => throw Exception('Command not implemented'),
        };

        // Print the result to the console.
        return print(messageToPrint);
      },
    ),
    (o, s) {
      // Display any errors that occurred during execution.
      print(o);
      if (debug) {
        // If in debug mode, also print the stack trace for detailed debugging.
        print(StackTrace.current);
      }
    },
  );
}
