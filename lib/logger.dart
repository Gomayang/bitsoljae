import 'package:logger/logger.dart';

final Logger logger = Logger(
  level: Level.all,
  output: ConsoleOutput(),
  printer: PrettyPrinter(
    lineLength: 12,
  ),
);
