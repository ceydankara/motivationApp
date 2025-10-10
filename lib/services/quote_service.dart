// lib/services/quote_service.dart

import 'dart:math';
import '../models/quote.dart';

final List<Quote> allQuotes = [
  Quote(text: "Başlamak için mükemmel olmak zorunda değilsin, mükemmel olmak için başlamak zorundasın.", author: "Zig Ziglar"),
  Quote(text: "Hayal edebiliyorsan, yapabilirsin.", author: "Walt Disney"),
  Quote(text: "Başarı, hazırlık fırsatla buluştuğunda ortaya çıkar.", author: "Seneca"),
  Quote(text: "Bugün yapabileceğin en iyi şey, dün yaptığından daha iyi olmaktır.", author: "Roy T. Bennett"),
  Quote(text: "Hayalleriniz gerçekleşmez, onları gerçekleştirirsiniz.", author: "Les Brown"),
  Quote(text: "İmkansız, cesaretsizlerin sözlüğünde bulunan bir kelimedir.", author: "Napoleon Bonaparte"),
  Quote(text: "Başarısızlık, başarıya giden yolda bir durak değil, başarıya giden yolda bir adımdır.", author: "Robert Kiyosaki"),
  Quote(text: "Sadece düşünmek yetmez, harekete geçmek gerekir.", author: "Tony Robbins"),
];

class QuoteService {
  final _random = Random();

  Quote getRandomQuote() {
    return allQuotes[_random.nextInt(allQuotes.length)];
  }
}
