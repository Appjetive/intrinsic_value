import 'dart:io';

import 'package:args/args.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/annual_growth/annual_growth.dart';
import 'package:intrinsic_value/command/command_parser.dart';
import 'package:intrinsic_value/command/command_result.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:intrinsic_value/intrisic_value/intrinsic_value.dart'
    as intrinsic_value;
import 'package:intrinsic_value/annual_growth/annual_growth.dart'
    as anual_growth;
import 'package:riverpod/riverpod.dart';

final ref = ProviderContainer();

void main(List<String> args) {
  Either.tryCatch(
    () {
      final runner = ref.read(podCommandParser).bind(
            (parser) => ref.read(
              podCommandResult(parser: parser, arguments: args),
            ),
          );
      runner.fold(
        (l) => print(l.message),
        (r) => r(),
      );
    },
    (o, s) {
      print('Error generating commands');
    },
  );

  // final argParser = ref.read(podCommandParser);

  // argParser.match(
  //   (l) => print(l.message),
  //   (r) {
  //     final argResultCommand = r.parse(args);

  //     ref.read(anual_growth.podCalculateAnualGrowth(argResultCommand));
  //   },
  // );

  // final parseResult = argParser.parse(args);

  // final String? commandName = parseResult.command?.name;

  // switch (commandName.command()) {
  //   case Command.iv:
  //     final ArgResults ivParseResult = ivCommand.parse(args);
  //     if (!calculateIV(ivParseResult)) {
  //       print(ivCommand.usage);
  //     }
  //     break;
  //   case Command.ag:
  //     final ArgResults agParseResults = agCommand.parse(args);
  //     if (!calculateAnualGrowth(agParseResults)) {
  //       print(agCommand.usage);
  //     }
  //     break;
  //   default:
  //     print(argParser.usage);
  // }
}

bool calculateIV(ArgResults argResults) {
  // if (!argResults.wasParsed('stock')) {
  //   return false;
  // }
  // final stockFile = File(argResults['stock']);

  // if (!stockFile.existsSync()) {
  //   print('The stock file doesn\'t exist in the provided path.');
  //   return false;
  // }

  // // Read the file
  // var fileLines = stockFile.readAsLinesSync();
  // var stockValues = Map<String, dynamic>();

  // for (String line in fileLines) {
  //   var lineParts = line.split('=');
  //   if (lineParts.length == 2) {
  //     var key = lineParts[0].trim();
  //     var value = lineParts[1].trim();

  //     // Parse the value if it's a number, otherwise treat as a string
  //     if (double.tryParse(value) != null) {
  //       stockValues[key] = double.parse(value);
  //     } else if (int.tryParse(value) != null) {
  //       stockValues[key] = int.parse(value);
  //     } else {
  //       // Remove quotes
  //       stockValues[key] = value.replaceAll('"', '');
  //     }
  //   }
  // }

  // List<IVKey> keysRequired = [
  //   IVKey.currentYear,
  //   IVKey.cashInCurrentYear,
  //   IVKey.multiplierAvgPastYears,
  //   IVKey.cashOnHand,
  // ];

  // bool validation = keysRequired
  //     .map(
  //       (key) => validateKey(stockValues, key),
  //     )
  //     .every((e) => e == true);

  // if (!validation) {
  //   return false;
  // }

  // // Getting options
  // double growPercentPerYear = 10;
  // if (argResults.wasParsed('growth')) {
  //   growPercentPerYear =
  //       double.tryParse(argResults['growth']) ?? growPercentPerYear;
  // }

  // int yearsToPredict = 5;
  // if (argResults.wasParsed('years')) {
  //   yearsToPredict = int.tryParse(argResults['years']) ?? yearsToPredict;
  // }

  // double discountPercentPerYear = 15;
  // if (argResults.wasParsed('discount')) {
  //   discountPercentPerYear =
  //       double.tryParse(argResults['discount']) ?? discountPercentPerYear;
  // }

  // double safetyMarginPercent = 30;
  // if (argResults.wasParsed('safety')) {
  //   safetyMarginPercent =
  //       double.tryParse(argResults['safety']) ?? safetyMarginPercent;
  // }

  // final intrinsicValue = ref.read(intrinsic_value.podCalculateIntrinsicValue(
  //   currentYear: stockValues['currentYear'].toInt(),
  //   cashInCurrentYear: stockValues['cashInCurrentYear'].toDouble(),
  //   multiplierAvgPastYears: stockValues['multiplierAvgPastYears'].toInt(),
  //   cashOnHand: stockValues['cashOnHand'].toDouble(),
  //   growPercentPerYear: growPercentPerYear,
  //   yearsToPredict: yearsToPredict,
  //   discountPercentPerYear: discountPercentPerYear,
  //   safetyMarginPercent: safetyMarginPercent,
  //   debug: false,
  // ));

  // intrinsicValue.match(
  //   (l) => print(l.message),
  //   (r) => print('Intrinsic Value = $r'),
  // );
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

  // ref
  //     .read(anual_growth.podCalculateAnualGrowth(
  //       start: minValue,
  //       end: maxValue,
  //       years: int.tryParse(argResults['years']) ?? 5,
  //     ))
  //     .match(
  //       (l) => print(l.message),
  //       (r) => print('Annual growth: %$r'),
  //     );
  return true;
}

// bool validateKey(Map<String, dynamic> stockValues, IVKey key) {
//   if (stockValues.containsKey(key.name)) {
//     return true;
//   }
//   print('The $key value is required');
//   return false;
// }

// Terminal value discounted = 343.04 Billions
// Intrinsic Value = 765.44 Billions
// Intrinsic Value plus cash on hand = 832.59 Billions
// Intrinsic Value with safety margin = 582.81 Billions