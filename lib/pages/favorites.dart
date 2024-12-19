import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/pages/userProfile.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipe.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipeList.dart';

//Page 5
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
  });


  @override
  State<FavoritesPage> createState() => _FavoritesPageState();

  
}

class _FavoritesPageState extends State<FavoritesPage>{
  List<Recipe> recipes = [];

  Future<void> _initializeFavorites() async {
    try {
      var appState = Provider.of<MyAppState>(context, listen: false); //Avoids rebuilds on state changes. 
      User user = appState.getUser();


      var returnData = await fetchFavoritesAPI({
        'Login': user.username,
      });

      if (returnData.containsKey('ERROR')){
        throw Exception('');
      } else if(!returnData.containsKey('favoriteRecipes')){
        throw Exception('');
      }else{
        List<dynamic> favorites = returnData['favoriteRecipes'];
        setState(() {
          recipes = favorites.map((json) => Recipe.fromJson(json as Map<String, dynamic>)).toList();
        });
      }

    } catch(error) {
      // Handle any unexpected errors that occur during the API call
      showAlert(context, 'An unexpected error occurred when loading favorites. Please try later $error');
    }
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () {
    _initializeFavorites();
  });
  }

  @override
  Widget build(BuildContext context){

    return Center(
      child: Column(
        
        children: <Widget>[
          //Search Header
          Text(
            'Favorites',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          //Favorite Recipe Cards
          Expanded(
            child: RecipeList(
              recipes: recipes
            ),
          ),
        ]
      ),
    );
  }
}