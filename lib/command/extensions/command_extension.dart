import 'package:intrinsic_value/command/enums/command.dart';

extension CommandString on String? {
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
