import 'package:intrinsic_value/enums/command.dart';

/// Extension to convert a nullable `String` to a `Command` enum value.
extension CommandString on String {
  Command command() => switch (this) {
        'ag' => Command.ag,
        'iv' => Command.iv,
        String() => Command.none,
      };
}
