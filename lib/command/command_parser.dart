import 'package:args/args.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:intrinsic_value/command/errors/command_errors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_parser.g.dart';

@riverpod
Either<CommandError, ArgParser> commandParser(CommandParserRef ref) =>
    Either.Do(
      ($) {
        final argParser = ArgParser(allowTrailingOptions: false);
        argParser.addSeparator(
          "Usage: ${Command.iv.name} [options] | ${Command.ag.name} [options]",
        );

        argParser.addCommand(
          Command.iv.name,
          $(_buildIvCommand()),
        );

        argParser.addCommand(
          Command.ag.name,
          $(_buildAgCommand()),
        );
        return argParser;
      },
    );

Either<CommandError, ArgParser> _buildIvCommand() => Either.tryCatch(
      () {
        final ivCommand = ArgParser();

        ivCommand.addSeparator('Usage: iv --stock="stock-config" [arguments]');
        ivCommand.addSeparator('Available arguments:');

        ivCommand.addOption(
          'stock',
          abbr: 's',
          mandatory: true,
          help: 'Path to the stock config file',
          valueHelp: './stocks/msft',
        );
        ivCommand.addOption(
          'growth',
          abbr: 'g',
          defaultsTo: '10',
          help: '% Growth per year',
        );
        ivCommand.addOption(
          'years',
          abbr: 'y',
          defaultsTo: '5',
          help: 'Amount of years to predict',
        );
        ivCommand.addOption(
          'discount',
          abbr: 'd',
          defaultsTo: '15',
          help: '% Discount per year',
        );
        ivCommand.addOption(
          'safety',
          abbr: 'f',
          defaultsTo: '30',
          help: '% safety margin',
        );
        return ivCommand;
      },
      (o, s) => CommandIntrinsicValueError(),
    );

Either<CommandError, ArgParser> _buildAgCommand() => Either.tryCatch(
      () {
        final agCommand = ArgParser();
        agCommand.addSeparator(
          'Usage: ag --min={number} --max={number} [arguments]',
        );
        agCommand.addSeparator('Available arguments:');
        agCommand.addOption(
          'min',
          mandatory: true,
          help: 'Min value',
        );
        agCommand.addOption(
          'max',
          mandatory: true,
          help: 'Max value',
        );
        agCommand.addOption(
          'years',
          abbr: 'y',
          defaultsTo: '5',
          help: 'Amount of years',
        );
        return agCommand;
      },
      (o, s) => CommandAnnualGrowthError(),
    );
