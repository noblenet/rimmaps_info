import 'dart:io';
import 'dart:convert';

class HdFileInfo {
  late String fileName;
  late String path;
  late List<String> content;
  late int noOfLinesFound;

  HdFileInfo({
    required this.fileName,
    required this.path,
    required this.content,
    required this.noOfLinesFound,
  });

  @override
  String toString() {
    return '$fileName,$path,$content,$noOfLinesFound';
  }

  static String getCsvHeader() {
    return 'fileName,path,projection,dataType,columns,rows,firstPixelX,firstPixelY,increaseX,increaseY,longitudeDegrees,longitudeMinutes,longitudeSeconds,latitudeDegrees,latitudeMinutes,latitudeSeconds,earthRadius,noOfLinesFound';
  }

  String toCsv() {
    return '$fileName,$path,$content,$noOfLinesFound';
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'path': path,
      'content': content,
      'noOfLinesFound': noOfLinesFound,
    };
  }
}

String getSpecificValueFromLine(String line, int start, int end) {
  try {
    return line.substring(start, end).trim();
  } catch (e) {
    return 'N/A';
  }
}

HdFileInfo readHdFile(String filePath) {
  try {
    var file = File(filePath);
    var lines = file.readAsLinesSync();

    while (lines.length < 7) {
      lines.add('N/A');
    }

    return HdFileInfo(
      fileName: file.uri.pathSegments.last,
      path: file.uri.path,
      content: lines,
      noOfLinesFound: lines.length,
    );
  } catch (e) {
    print('Error reading file $filePath: $e');
    return HdFileInfo(
      fileName: 'Error',
      path: filePath,
      content: [],
      noOfLinesFound: 0,
    );
  }
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Vælg venligst en sti som parameter.');
    exit(1);
  }

  var stopwatch = Stopwatch()..start();

  var folderPath = arguments[0];
  var directory = Directory(folderPath);

  var hdFiles = _listHdFiles(directory);

  var csvContent = '${HdFileInfo.getCsvHeader()}\n';
  var jsonContentList = <Map<String, dynamic>>[];

  for (var hdFile in hdFiles) {
    var fileInfo = readHdFile(hdFile.path);
    csvContent += '${fileInfo.toCsv()}\n';

    var jsonContent = fileInfo.toJson();
    jsonContentList.add(jsonContent);
  }

  var jsonFile = File('$folderPath/resultat.json');
  jsonFile.writeAsStringSync(jsonEncode(jsonContentList));

  var csvFile = File('$folderPath/resultat.csv');
  csvFile.writeAsStringSync(csvContent);

  stopwatch.stop();
  print('CSV-fil og JSON-fil er genereret med succes i mappe: $folderPath');
  print('Antal filer behandlet: ${hdFiles.length}');
  print('Tid brugt: ${stopwatch.elapsed}');
}

List<File> _listHdFiles(Directory directory) {
  var hdFiles = <File>[];

  for (var entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.hd')) {
      hdFiles.add(entity);
    }
  }

  return hdFiles;
}
