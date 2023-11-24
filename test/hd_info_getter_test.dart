import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import '../bin/hd_info_getter.dart';

// Lav en mock af File-klassen
class MockFile extends Mock implements File {}

void main() {
  test('createCsvFile should print the correct message', () {
    // Opret en instans af MockFile
    final mockFile = MockFile();

    // Kald createCsvFile-funktionen med mockFile
    createCsvFile('mock/path', 'mock_csv', fileFactory: (path) => mockFile);

    // Tjek om funktionen udskriver det forventede budskab
    verify(mockFile.writeAsStringSync(captureAny)).called(1);

    // Hent den fangete udskrift
    String printedMessage =
        verify(mockFile.writeAsStringSync(captureAny)).captured[0];

    // Tjek om det udskrevne budskab er korrekt
    expect(printedMessage,
        'Opretter CSV-fil fra sti: mock/path med navn: mock_csv.csv');
  });
}
