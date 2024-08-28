import 'package:flutter_test/flutter_test.dart';
import 'package:lichess_mobile/src/model/spacedrepetition/fsrs_base.dart'; 
import 'package:lichess_mobile/src/model/spacedrepetition/models.dart'; 
import 'package:collection/collection.dart';
import 'dart:math';
void main() {
  group('fsrs_chess', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('testChess', () {
      testChess();
    });
  });
}

void _printSchedulingCards(Map<Rating, SchedulingInfo> schedulingCards) {
  print("again.card: ${schedulingCards[Rating.again]?.card}");
  //print("again.reviewLog: ${schedulingCards[Rating.again]?.reviewLog}\n");
  print("hard.card: ${schedulingCards[Rating.hard]?.card}");
 // print("hard.reviewLog: ${schedulingCards[Rating.hard]?.reviewLog}\n");
  print("good.card: ${schedulingCards[Rating.good]?.card}");
 // print("good.reviewLog: ${schedulingCards[Rating.good]?.reviewLog}\n");
  print("easy.card: ${schedulingCards[Rating.easy]?.card}");
 // print("easy.reviewLog: ${schedulingCards[Rating.easy]?.reviewLog}\n");
  print("\n\n\n");
}

void printDueDates(List<Card> cards) {
  for (var card in cards) {
    print(card.due);
  }
}

void sortDeck(List<Card> deck) {
  deck.sort((a, b) => a.due.compareTo(b.due));
}


void printPuzzlesDueDate(List<Card> deck) {
  for (var card in deck) {
    print('Puzzle ID: ${card.puzzleId}, Due Date: ${card.due}, Stability: ${card.stability}');
  }
}

// Function to simulate user rating
Rating simulateUserRating(String puzzleId) {
    final random = Random();
    return random.nextBool() ? Rating.easy : Rating.hard;
}


void testChess() {

  var f = FSRS();
  //create deck of 10 cards 
  List<Card> deck = List.generate(10, (index) => Card('puzzle_$index'));
  sortDeck(deck);
  printPuzzlesDueDate(deck);

  var now = DateTime.now();

  for (int i = 0; i < 50; i++) {
      var card = deck.first;
      print('reviewing puzzle id ' + card.puzzleId);
      var now = DateTime.now();
      var schedulingCards = f.repeat(card, now);
      var rating = simulateUserRating(card.puzzleId);
      print('puzzle was $rating');
      deck[0] = schedulingCards[rating]!.card;
      print('Card state after rating $rating: ${deck[0].state}');
      sortDeck(deck);
      printPuzzlesDueDate(deck);
  }



  assert(true);

  /*var ratings = [
    Rating.good,
    Rating.good,
    Rating.good,
    Rating.good,
    Rating.good,
    Rating.good,
    Rating.again,
    Rating.again,
    Rating.good,
    Rating.good,
    Rating.good,
    Rating.good,
    Rating.good,
  ];
  var ivlHistory = <int>[];

  for (var rating in ratings) {
    card = schedulingCards[rating]?.card ?? Card();
    var ivl = card.scheduledDays;
    ivlHistory.add(ivl);
    now = card.due;
    schedulingCards = f.repeat(card, now);
    printSchedulingCards(schedulingCards);
  }

  print(ivlHistory);
  assert(ListEquality()
      .equals(ivlHistory, [0, 5, 16, 43, 106, 236, 0, 0, 12, 25, 47, 85, 147]));
      */
}
