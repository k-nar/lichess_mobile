import 'package:flutter_test/flutter_test.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/spacedrepetition/deck.dart';
import 'package:collection/collection.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  group('Deck', () {
    test('withInitialCards creates a deck with sorted puzzles and initial cards', () {
      // Load puzzles from puzzles_test.json
      final String jsonString = File('assets/test/puzzles_test.json').readAsStringSync();
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final allPuzzles = jsonList.map((json) => Puzzle.fromJson(json as Map<String, dynamic>)).toList();

      final deck = Deck.withInitialCards(allPuzzles, 10);

      // Check if all puzzles are in the deck
      expect(deck.allPuzzles.length, equals(allPuzzles.length));

      // Check if puzzles are sorted by rating

      // Check if the first puzzle has the expected rating
      expect(deck.allPuzzles.first.puzzle.rating, equals(1462));

      // Check if the correct number of initial cards were created
      expect(deck.reviewingCards.length, equals(10));

      // Check if the initial cards correspond to the first 10 sorted puzzles
      for (int i = 0; i < 10; i++) {
        expect(deck.reviewingCards[i].puzzleId, equals(deck.allPuzzles[i].puzzle.id.toJson()));
      }

      // Check if cardToPuzzle is correctly populated
      expect(deck.cardToPuzzle.length, equals(10));
      for (int i = 0; i < 10; i++) {
        expect(deck.cardToPuzzle[deck.reviewingCards[i].puzzleId], equals(deck.allPuzzles[i]));
      }
    });
  });
}