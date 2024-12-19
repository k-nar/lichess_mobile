import 'package:flutter_test/flutter_test.dart';
import 'package:lichess_mobile/src/model/spacedrepetition/fsrs_base.dart'; 
import 'package:lichess_mobile/src/model/spacedrepetition/models.dart'; 
import 'package:collection/collection.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      testRepeat();
    });
  });
}

void printSchedulingCards(Map<Rating, SchedulingInfo> schedulingCards) {
  print("again.card: ${schedulingCards[Rating.again]?.card}");
  print("again.reviewLog: ${schedulingCards[Rating.again]?.reviewLog}");
  print("hard.card: ${schedulingCards[Rating.hard]?.card}");
  print("hard.reviewLog: ${schedulingCards[Rating.hard]?.reviewLog}");
  print("good.card: ${schedulingCards[Rating.good]?.card}");
  print("good.reviewLog: ${schedulingCards[Rating.good]?.reviewLog}");
  print("easy.card: ${schedulingCards[Rating.easy]?.card}");
  print("easy.reviewLog: ${schedulingCards[Rating.easy]?.reviewLog}");
  print("");
}

void testRepeat() {
  var f = FSRS();
  f.p.w = [
    1.14,
    1.01,
    5.44,
    14.67,
    5.3024,
    1.5662,
    1.2503,
    0.0028,
    1.5489,
    0.1763,
    0.9953,
    2.7473,
    0.0179,
    0.3105,
    0.3976,
    0.0,
    2.0902
  ];
  var card = Card();
  var now = DateTime(2022, 11, 29, 12, 30, 0, 0);
  var schedulingCards = f.repeat(card, now);
  printSchedulingCards(schedulingCards);

  var ratings = [
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
}