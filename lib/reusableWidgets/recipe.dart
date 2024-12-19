class Recipe {
  final int id;
  final String title;
  final String image;
  

  Recipe({
    required this.id,
    required this.title,
    required this.image,
  });

  // Factory constructor to create a Recipe from a Map (decoded JSON object)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'] ?? 'assets/onion.jpg',
    );
  }
}