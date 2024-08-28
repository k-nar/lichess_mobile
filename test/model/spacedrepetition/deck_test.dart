import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'dart:convert';
import 'package:lichess_mobile/src/model/spacedrepetition/deck.dart';  // Adjust the import to your actual package


void main() {
  group('Deck.loadFromJSON', () {
    test('should load Deck from valid JSON string', () {
      // Arrange
      final jsonContent = File('assets/test/deck_test.json').readAsStringSync();

      // Act
      final deck = Deck.loadFromJSON(jsonContent);

      // Assert
      expect(deck, isNotNull);
      expect(deck!.allPuzzles.length, 83);
      expect(deck.allPuzzles.first.puzzle.id, 'ZUuvO');
    });

    test('should return null on invalid JSON string', () {
      // Arrange
      final invalidJsonContent = '{"allPuzzles": [ {"puzzleID": "puzzle_1"}],'; // Missing closing braces

      // Act
      final deck = Deck.loadFromJSON(invalidJsonContent);

      // Assert
      expect(deck, isNull);
    });
  });
}