// lib/models/quote.dart

class Quote {
  final String text;
  final String author;
  final bool isFavorite;

  Quote({required this.text, required this.author, this.isFavorite = false});

  // JSON'dan Quote nesnesi oluşturmak için fabrika metodu (ileride veri tabanı/API için faydalı)
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] as String,
      author: json['author'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
// 