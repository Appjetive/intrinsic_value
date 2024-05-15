import 'package:intrinsic_value/command/enums/command.dart';

extension CommandString on String? {
  Command command() {
    switch (this) {
      case 'ag':
        return Command.ag;
      default:
        return Command.iv;
    }
  }
}
