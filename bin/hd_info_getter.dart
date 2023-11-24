import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'dart:math' as math;
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;

final Logger _logger = Logger('MyApp');

void writeFilesToJson(
    List<String> fileNamesFull, String jsonFileName, Logger logger) {
  for (String fullFileName in fileNamesFull) {
    File textFile = File(fullFileName);

    if (!textFile.existsSync()) {
      _logger.severe('Tekstfilen "$fullFileName" eksisterer ikke.');
      continue; // Spring over til næste fil, hvis filen ikke eksisterer
    }

    try {
      String context = textFile.readAsStringSync();
      logger.fine(context);
      // Brug path-biblioteket til at adskille filnavn og sti
      String fileName = p.basenameWithoutExtension(fullFileName);
      String filePath = p.dirname(fullFileName);

      // Opret et map med de ønskede oplysninger
      Map<String, dynamic> jsonMap = {
        'fileName': fileName,
        'path': filePath,
        'context': context,
      };

      // Konverter map til JSON-streng
      String jsonString = json.encode(jsonMap);

      // Gem JSON i en fil med det ønskede navn
      File jsonFile = File('$jsonFileName.json');
      jsonFile.writeAsStringSync(jsonString);

      logger.info('JSON er blevet gemt i filen: $jsonFileName.json');
    } catch (error) {
      logger.severe('Fejl ved behandling af filen "$fullFileName": $error');
    }
  }
}

void main(List<String> arguments) {
  final ArgParser argParser = ArgParser()
    ..addOption('path', abbr: 'p', mandatory: true, help: 'Sti til inputfilen')
    ..addOption('name',
        abbr: 'n',
        mandatory: false,
        defaultsTo: 'hd-output',
        help: 'Navn på outputfilerne')
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

    _logger.info('Timer starter...');
    final stopwatch = Stopwatch()..start();

    final String path = args['path'];
    final String name = args['name'];
    final String outputFormat = args['output'];
    final String logLevel = args['log'];

    var outputFile = File('log.log');

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      outputFile.writeAsStringSync(
          "${rec.time} | ${rec.level} | ${rec.message} | ${rec.loggerName}\n",
          mode: FileMode.append);
    });

//find the files
    var hdFiles = findHdFiles(path);

    // Eksempel: Opret CSV-fil
    if (outputFormat == 'csv') {
      createCsvFile(path, name);
    }

    // Eksempel: Opret JSON-fil
    if (outputFormat == 'json') {
      writeFilesToJson(hdFiles, name, _logger);
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

List<String> findHdFiles(String folderPath) {
  List<String> hdFiles = [];

  void searchInFolder(String folderPath) {
    Directory(folderPath).listSync().forEach((FileSystemEntity entity) {
      if (entity is File && entity.path.toLowerCase().endsWith('.hd')) {
        hdFiles.add(entity.path);
      } else if (entity is Directory) {
        searchInFolder(entity.path);
      }
    });
  }

  searchInFolder(folderPath);
  return hdFiles;
}

Future<String> callWebApi(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    // Konverter JSON-responsen til et Dart-objekt
    return jsonDecode(response.body);
  } else {
    // Håndter fejl
    throw Exception('Fejl ved kald til web-API: ${response.statusCode}');
  }
}

Map<String, dynamic> readAndMapHdFile(String filePath) {
  String fileContent = File(filePath).readAsStringSync();

  // Implementer logik for at mappe teksten til dataobjektet
  // ...

  // Returner det dataobjekt, f.eks. et Map
  return {'content': fileContent};
}

void createCsvFile(String path, String name) {
  // Implementer logik for oprettelse af CSV-fil
  print('Opretter CSV-fil fra sti: $path med navn: $name.csv');
}

void infoLogging() {
  // Implementer logik for info-niveau logning
  print('Logningsniveau: INFO');
}

void debugLogging() {
  // Implementer logik for debug-niveau logning
  print('Logningsniveau: DEBUG');
}
