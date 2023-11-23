import 'package:args/args.dart';

void main(List<String> arguments) {
  final ArgParser argParser = ArgParser()
    ..addOption('path', abbr: 'p', mandatory: true, help: 'Sti til inputfilen')
    ..addOption('name',
        abbr: 'n', mandatory: true, help: 'Navn på outputfilerne')
    ..addOption('output',
        abbr: 'o',
        defaultsTo: 'csv',
        allowed: ['csv', 'json'],
        help: 'Outputformat (csv eller json)')
    ..addOption('log',
        abbr: 'l',
        defaultsTo: 'info',
        allowed: ['info', 'debug'],
        help: 'Logningsniveau (info eller debug)');

  try {
    final ArgResults args = argParser.parse(arguments);

    if (args.arguments.isEmpty) {
      print('Ingen parametre angivet. Brug følgende kommando:');
      print(argParser.usage);
      return;
    }

    final String path = args['path'];
    final String name = args['name'];
    final String outputFormat = args['output'];
    final String logLevel = args['log'];

    // Eksempel: Opret CSV-fil
    if (outputFormat == 'csv') {
      createCsvFile(path, name);
    }

    // Eksempel: Opret JSON-fil
    if (outputFormat == 'json') {
      createJsonFile(path, name);
    }

    // Logning
    if (logLevel == 'debug') {
      debugLogging();
    } else {
      infoLogging();
    }
  } on ArgParserException catch (e) {
    print(e.message);
    print(argParser.usage);
  }
}

void createCsvFile(String path, String name) {
  // Implementer logik for oprettelse af CSV-fil
  print('Opretter CSV-fil fra sti: $path med navn: $name.csv');
}

void createJsonFile(String path, String name) {
  // Implementer logik for oprettelse af JSON-fil
  print('Opretter JSON-fil fra sti: $path med navn: $name.json');
}

void infoLogging() {
  // Implementer logik for info-niveau logning
  print('Logningsniveau: INFO');
}

void debugLogging() {
  // Implementer logik for debug-niveau logning
  print('Logningsniveau: DEBUG');
}
