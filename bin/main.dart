import 'dart:io';

import 'package:args/args.dart';
import 'package:intrinsic_value/intrinsic_value.dart' as intrinsic_value;
import 'package:intrinsic_value/anual_growth.dart' as anual_growth;

enum Command {
  iv,
  ag,
  none,
}

enum IVKey {
  currentYear,
  cashInCurrentYear,
  multiplierAvgPastYears,
  cashOnHand,
}

extension _CommandString on String? {
  Command command() {
    switch (this) {
      case 'iv':
        return Command.iv;
      case 'ag':
        return Command.ag;
    }
    return Command.none;
  }
}

void main(List<String> args) {
  final argParser = ArgParser();
  argParser.addSeparator(
    "Usage: ${Command.iv.name} [options] | ${Command.ag.name} [options]",
  );

  final ivCommand = argParser.addCommand(Command.iv.name);
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

  final agCommand = argParser.addCommand(Command.ag.name);
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

  final parseResult = argParser.parse(args);

  final String? commandName = parseResult.command?.name;

  switch (commandName.command()) {
    case Command.iv:
      final ArgResults ivParseResult = ivCommand.parse(args);
      if (!calculateIV(ivParseResult)) {
        print(ivCommand.usage);
      }
      break;
    case Command.ag:
      final ArgResults agParseResults = agCommand.parse(args);
      if (!calculateAnualGrowth(agParseResults)) {
        print(agCommand.usage);
      }
      break;
    default:
      print(argParser.usage);
  }
}

bool calculateIV(ArgResults argResults) {
  if (!argResults.wasParsed('stock')) {
    return false;
  }
  final stockFile = File(argResults['stock']);

  if (!stockFile.existsSync()) {
    print('The stock file doesn\'t exist in the provided path.');
    return false;
  }

  // Read the file
  var fileLines = stockFile.readAsLinesSync();
  var stockValues = Map<String, dynamic>();

  for (String line in fileLines) {
    var lineParts = line.split('=');
    if (lineParts.length == 2) {
      var key = lineParts[0].trim();
      var value = lineParts[1].trim();

      // Parse the value if it's a number, otherwise treat as a string
      if (double.tryParse(value) != null) {
        stockValues[key] = double.parse(value);
      } else if (int.tryParse(value) != null) {
        stockValues[key] = int.parse(value);
      } else {
        // Remove quotes
        stockValues[key] = value.replaceAll('"', '');
      }
    }
  }

  List<IVKey> keysRequired = [
    IVKey.currentYear,
    IVKey.cashInCurrentYear,
    IVKey.multiplierAvgPastYears,
    IVKey.cashOnHand,
  ];

  bool validation = keysRequired
      .map(
        (key) => validateKey(stockValues, key),
      )
      .every((e) => e == true);

  if (!validation) {
    return false;
  }

  // Getting options
  double growPercentPerYear = 10;
  if (argResults.wasParsed('growth')) {
    growPercentPerYear =
        double.tryParse(argResults['growth']) ?? growPercentPerYear;
  }

  int yearsToPredict = 5;
  if (argResults.wasParsed('years')) {
    yearsToPredict = int.tryParse(argResults['years']) ?? yearsToPredict;
  }

  double discountPercentPerYear = 15;
  if (argResults.wasParsed('discount')) {
    discountPercentPerYear =
        double.tryParse(argResults['discount']) ?? discountPercentPerYear;
  }

  double safetyMarginPercent = 30;
  if (argResults.wasParsed('safety')) {
    safetyMarginPercent =
        double.tryParse(argResults['safety']) ?? safetyMarginPercent;
  }

  intrinsic_value.calculateIV(
    currentYear: stockValues['currentYear'].toInt(),
    cashInCurrentYear: stockValues['cashInCurrentYear'].toDouble(),
    multiplierAvgPastYears: stockValues['multiplierAvgPastYears'].toInt(),
    cashOnHand: stockValues['cashOnHand'].toDouble(),
    growPercentPerYear: growPercentPerYear,
    yearsToPredict: yearsToPredict,
    discountPercentPerYear: discountPercentPerYear,
    safetyMarginPercent: safetyMarginPercent,
  );
  return true;
}

bool calculateAnualGrowth(ArgResults argResults) {
  if (!argResults.wasParsed('min') || !argResults.wasParsed('max')) {
    return false;
  }

  final minValue = double.tryParse(argResults['min']);
  final maxValue = double.tryParse(argResults['max']);

  if (minValue == null || maxValue == null) {
    return false;
  }

  anual_growth.calculateAnualGrowth(
    minValue,
    maxValue,
    years: int.tryParse(argResults['years']) ?? 5,
  );
  return true;
}

bool validateKey(Map<String, dynamic> stockValues, IVKey key) {
  if (stockValues.containsKey(key.name)) {
    return true;
  }
  print('The $key value is required');
  return false;
}

// Terminal value discounted = 343.04 Billions
// Intrinsic Value = 765.44 Billions
// Intrinsic Value plus cash on hand = 832.59 Billions
// Intrinsic Value with safety margin = 582.81 Billions