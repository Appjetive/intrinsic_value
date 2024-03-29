import 'package:fpdart/fpdart.dart';
import 'package:intrinsic_value/command/command_parser.dart';
import 'package:intrinsic_value/command/command_result.dart';
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
}
