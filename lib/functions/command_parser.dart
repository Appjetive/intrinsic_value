import 'package:args/args.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/enums/command.dart';

/// This class provides functionality to parse command-line arguments for commands.
///
/// The [CommandParser] uses [Either] from functional programming to handle potential
/// errors during the construction of [ArgParser] instances.
class CommandParser {
  /// Constructs an [ArgParser] for command-line interface options.
  ///
  /// This method uses [Either] to handle potential errors during parser creation.
  static Either<Exception, ArgParser> getParser() => Either.Do(
        ($) {
          final argParser = ArgParser(allowTrailingOptions: false);
          // Adds a usage separator to clarify how to use the commands.
          argParser.addSeparator(
            "Usage: ${Command.iv.name} [options] | ${Command.ag.name} [options]",
          );

          // Adds the 'iv' command with its specific sub-parser.
          argParser.addCommand(
            Command.iv.name,
            $(_buildIvCommand()),
          );

          // Adds the 'ag' command with its specific sub-parser.
          argParser.addCommand(
            Command.ag.name,
            $(_buildAgCommand()),
          );
          return argParser;
        },
      );
}

/// Builds the argument parser for the 'iv' command.
///
/// Configures options specific to intrinsic value calculations.
Either<Exception, ArgParser> _buildIvCommand() => Either.tryCatch(
      () {
        final ivCommand = ArgParser();

        ivCommand.addSeparator('Usage: iv --stock="stock-config" [arguments]');
        ivCommand.addSeparator('Available arguments:');

        // Option for specifying the stock configuration file.
        ivCommand.addOption(
          'stock',
          abbr: 's',
          mandatory: true,
          help: 'Path to the stock config file',
          valueHelp: './stocks/msft',
        );
        // Option for setting the expected annual growth rate.
        ivCommand.addOption(
          'growth',
          abbr: 'g',
          defaultsTo: '10',
          help: '% Growth per year',
        );
        // Option for the prediction period in years.
        ivCommand.addOption(
          'years',
          abbr: 'y',
          defaultsTo: '5',
          help: 'Amount of years to predict',
        );
        // Option for the annual discount rate applied to future cash flows.
        ivCommand.addOption(
          'discount',
          abbr: 'd',
          defaultsTo: '15',
          help: '% Discount per year',
        );
        // Option for a safety margin in the valuation process.
        ivCommand.addOption(
          'safety',
          abbr: 'f',
          defaultsTo: '30',
          help: '% safety margin',
        );
        return ivCommand;
      },
      (o, s) => throw o, // Converts any error into an exception.
    );

/// Builds the argument parser for the 'ag' command.
///
/// Configures options for analysis within a range of values.
Either<Exception, ArgParser> _buildAgCommand() => Either.tryCatch(
      () {
        final agCommand = ArgParser();
        agCommand.addSeparator(
          'Usage: ag --min={number} --max={number} [arguments]',
        );
        agCommand.addSeparator('Available arguments:');
        // Option for setting the minimum value for analysis.
        agCommand.addOption(
          'min',
          mandatory: true,
          help: 'Min value',
        );
        // Option for setting the maximum value for analysis.
        agCommand.addOption(
          'max',
          mandatory: true,
          help: 'Max value',
        );
        // Option for specifying the number of years for the analysis.
        agCommand.addOption(
          'years',
          abbr: 'y',
          defaultsTo: '5',
          help: 'Amount of years',
        );
        return agCommand;
      },
      (o, s) => throw o, // Converts any error into an exception.
    );
