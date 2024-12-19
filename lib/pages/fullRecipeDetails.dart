import 'package:flutter/material.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipeDetails.dart';

class FullRecipeDetailsPage extends StatelessWidget {
  final RecipeDetails details;

  const FullRecipeDetailsPage({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(details.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              details.image,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/onion.jpg',  
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Preparation Time: ${details.prepareTime} mins',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Servings: ${details.servings}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ingredients:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...details.ingredients.map((ingredient) {
                    final name = ingredient['name'] ?? 'Unknown ingredient';
                    final amount = ingredient['amount'] ?? 0.0;
                    final unit = ingredient['unit'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '• $amount $unit of $name',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 8),
                  Text(
                    'Instructions: ${details.sourceUrl}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}