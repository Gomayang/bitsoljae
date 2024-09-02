import 'package:logger/logger.dart';

final Logger logger = Logger(
  output: ConsoleOutput(),
  printer: PrettyPrinter(
    lineLength: 12,
  ),
);
