import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/pages/userProfile.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipe.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipeList.dart';

//Page 5
class PantrySearchPage extends StatefulWidget {
  const PantrySearchPage({
    super.key,
  });


  @override
  State<PantrySearchPage> createState() => _PantrySearchState();

  
}

class _PantrySearchState extends State<PantrySearchPage>{
  List<Recipe> recipes = [];

  Future<void> _initializeRecipes() async {
    try {
      var appState = Provider.of<MyAppState>(context, listen: false); //Avoids rebuilds on state changes. 
      User user = appState.getUser();


      var returnData = await searchPantryAPI(user.pantry,user.allergens);

      // TODO: Fix
      if(returnData.isEmpty){
        showAlert(context,'No results found for your pantry');
      }
      else{
        if(returnData[0]=='ERROR'){
          throw Exception('');
        } 
        else{
          List<dynamic> pantrySearchResults = returnData;
          setState(() {
            recipes = pantrySearchResults.map((json) => Recipe.fromJson(json as Map<String, dynamic>)).toList();
          });
        }
      }
      

    } catch(error) {
      // Handle any unexpected errors that occur during the API call
      showAlert(context, 'An unexpected error occurred when loading results. Please try later $error');
    }
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () {
    _initializeRecipes();
  });
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Search by Pantry'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/LandingPageBG.jpg'), // Set the background image
            fit: BoxFit.cover, // Cover the entire screen with the image
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient:LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white60,
                Colors.white60,
              ],
            ),
          ),
          child: Center(
            child: Column(
              
              children: <Widget>[
                //Search Header
                Text(
                  'Search by Pantry',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                //Recipe Cards
                Expanded(
                  child: RecipeList(
                    recipes: recipes
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}