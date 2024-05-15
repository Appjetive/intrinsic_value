import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/command/command_parser.dart';
import 'package:intrinsic_value/command/command_result.dart';
import 'package:intrinsic_value/command/enums/command.dart';
import 'package:riverpod/riverpod.dart';

final ref = ProviderContainer();

void main(List<String> args) {
  Either.tryCatch(
    () {
      ref
          .read(podCommandParser)
          .bind(
            (parser) => ref.read(
              podCommandResult(parser: parser, arguments: args),
            ),
          )
          .fold(
            (l) => print(l.message),
            (r) => switch (r.$1) {
              Command.iv => print('Intrinsic value: ${r.$2}'),
              Command.ag => print('Annual growth: ${r.$2}'),
            },
          );
    },
    (o, s) {
      print('Error generating commands');
    },
  );
}
