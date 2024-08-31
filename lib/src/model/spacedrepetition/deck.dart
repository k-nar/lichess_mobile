import 'dart:collection';

import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/spacedrepetition/fsrs_base.dart';
import 'package:lichess_mobile/src/model/spacedrepetition/models.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';


class Deck {
  List<Puzzle> allPuzzles;
  List<Card> reviewingCards;
  HashMap<String, Puzzle> cardToPuzzle;
  HashMap<String, Rating> session;

  Deck(this.allPuzzles, {this.reviewingCards = const []})
      : cardToPuzzle = HashMap<String, Puzzle>(),
        session = HashMap<String, Rating>() {
    _sortPuzzlesByRating();
    _initializeReviewingCards();
  }

  void _initializeReviewingCards() {
    for (var card in reviewingCards) {
      var puzzle = allPuzzles.firstWhere((puzzle) => puzzle.puzzle.id.toJson() == card.puzzleId);
      cardToPuzzle[card.puzzleId] = puzzle;
    }
  }

  void _sortPuzzlesByRating() {
    allPuzzles.sort((a, b) => a.puzzle.rating.compareTo(b.puzzle.rating));
  }

  void _sortDeck() {
    reviewingCards.sort((a, b) => a.due.compareTo(b.due));
  }

  bool shouldAddCard() {
    if (reviewingCards.isEmpty) return true;

    if (session.length == reviewingCards.length &&
        session.values.every((rating) => rating == Rating.easy)) {
      return true;
    }
    return false;
  }

  Card get nextCard {

    if (shouldAddCard() && reviewingCards.length < allPuzzles.length) {
      var nextPuzzle = allPuzzles[reviewingCards.length];
      var newCard = Card(nextPuzzle.puzzle.id.toJson());
      reviewingCards.add(newCard);
      cardToPuzzle[newCard.puzzleId] = nextPuzzle;
    }

    _sortDeck();
    return reviewingCards.first;
  }

  void rateCurrentCard(Rating rating) {
    var currentCard = nextCard;
    session[currentCard.puzzleId] = rating;

    // Update the card state using the FSRS system
    var fsrs = FSRS();
    var now = DateTime.now();
    var schedulingCards = fsrs.repeat(currentCard, now);
    currentCard = schedulingCards[rating]!.card;

    // Sort the deck again after rating the card
    _sortDeck();
  }

  // Convert a Deck instance to JSON
  Map<String, dynamic> toJson() => {
        'puzzles': allPuzzles.map((puzzle) => puzzle.toJson()).toList(),
        'cards': reviewingCards.map((card) => card.toJson()).toList(),
       // 'session': session.map((puzzleID, rating) => MapEntry(puzzleID, rating.toString())),
      };

  // Create a Deck instance from JSON
  factory Deck.fromJson(Map<String, dynamic> json) {
    var allPuzzles = (json['puzzles'] as List)
                     .map((p) => Puzzle.fromJson(p as Map<String, dynamic>))
                    .toList();
    var reviewingCards = (json['cards'] as List)
                        .map((c) => Card.fromJson(c as Map<String, dynamic>))
                        .toList();

    var deck = Deck(allPuzzles, reviewingCards: reviewingCards);

   /* deck.session = HashMap<String, Rating>.from(
      (json['session'] as Map<String, dynamic>).map(
        (puzzleID, rating) => MapEntry(puzzleID, Rating.values.firstWhere((r) => r.toString() == rating)),
      ),
    );
  */
    deck._initializeReviewingCards(); // Ensure cardToPuzzleBeingReviewed is correctly populated

    return deck;
  }

  // New factory method
  factory Deck.withInitialCards(List<Puzzle> puzzles, int initialNbCards) {
    // Sort puzzles by rating
    puzzles.sort((a, b) => a.puzzle.rating.compareTo(b.puzzle.rating));

    // Create initial cards
    var initialCards = puzzles.take(initialNbCards).map((puzzle) => 
      Card(puzzle.puzzle.id.toJson())
    ).toList();

    return Deck(puzzles, reviewingCards: initialCards);
  }

  // Function to save the Deck to a JSON file
  Future<void> saveToDisk(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String jsonDeck = jsonEncode(toJson());
      await file.writeAsString(jsonDeck);
      print('Deck saved to disk at ${file.path}');
    } catch (e) {
      print('Error saving deck to disk: $e');
    }
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Load a Deck instance from a JSON string
  static Deck? loadFromJSON(String jsonContent) {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonContent) as Map<String, dynamic>;
      return Deck.fromJson(jsonMap);
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }

  // Load a Deck instance from a file resource
  static Future<Deck?> loadFromDisk(String resourceName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$resourceName');
      if (await file.exists()) {
        final String jsonDeck = await file.readAsString();
        return loadFromJSON(jsonDeck);
      } else {
        print('File not found');
        return null;
      }
    } catch (e) {
      print('Error loading deck from disk: $e');
      return null;
    }
  }
}

