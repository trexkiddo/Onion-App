class RecipeDetails {
  final int id;
  final String title;
  final String image;
  final int servings;
  final int prepareTime;
  final List<Map<String, dynamic>> ingredients;
  final String sourceUrl;

  RecipeDetails({
    required this.id,
    required this.title,
    required this.image,
    required this.servings,
    required this.prepareTime,
    required this.ingredients,
    required this.sourceUrl,
  });

  // Factory constructor to create a RecipeDetails from a Map (decoded JSON object)
  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    return RecipeDetails(
      id: json['id'],
      title: json['title'],
      image: json['image'] ?? 'assets/onion.jpg',
      servings: json['servings'],
      prepareTime: json['readyInMinutes'],
      ingredients: List<Map<String, dynamic>>.from(json['ingredients']),
      sourceUrl: json['sourceUrl'] ?? ""
    );
  }
}