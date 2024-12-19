import 'package:flutter/material.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipe.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipeCard.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipeDetails.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/pages/fullRecipeDetails.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';



//List of recipeCards
class RecipeList extends StatelessWidget{

  final List<Recipe> recipes;

  RecipeList({required this.recipes});

  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return ListTile(
          title: RecipeCard(
            recipeID: recipe.id,
            recipeName: recipe.title,
            imageUrl: recipe.image,
            onButtonPressed:() async {
              //TODO: Add view recipe logic
              try {
                var results = await getRecipeInfoAPI(recipe.id);
                if(results.containsKey('ERROR')){
                  showAlert(context, results['ERROR']);
                } else if(results.containsKey('error')){
                  showAlert(context, results['error']);
                } else {
                  RecipeDetails details = RecipeDetails.fromJson(results);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullRecipeDetailsPage(details: details),
                    ),
                  );
                }
              }catch (error) {
                // Handle any unexpected errors that occur during the API call
                showAlert(context, 'An unexpected error occurred. Please try later');
              }
              
            },
          ),
        );
      }
    );
  }

 
}