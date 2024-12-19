import 'package:flutter/material.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipe.dart';
import 'package:cop4331_lp_g30_redo/reusableWidgets/recipeList.dart';

//Page 4
class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });


  @override
  State<SearchPage> createState() => _SearchPageState();

  
}

class _SearchPageState extends State<SearchPage>{

  List<Recipe> recipes = [];

  @override
  Widget build(BuildContext context){
    //var appState = context.watch<MyAppState>(); //Watches for changes in the appState //Dont think i need this but will chuck it here in case
    

    return Center(
      child: Column(

        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Search White Box Background
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                //Search Header
                Text(
                  'Search',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                //Search Field
                Padding(
                  padding:  EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0, bottom: 8.0),
                  child: TextField(
                    onSubmitted:(value) async {
                      try{
                        
                        var searchData = await searchAPI(value); //Add allergens and other params
                        
                        if (searchData.containsKey('ERROR')){
                          showAlert(context, searchData['ERROR']); //CHANGE TO THROW ERROR AT END
                        } else if(!searchData.containsKey('results')) {
                          throw Exception('Missing Results');
                        } else {
                          //Grabs the search results and converts them into a list of recipe objects
                          List<dynamic> searchResults = searchData['results'];
                          setState(() {
                            recipes = searchResults.map((json) => Recipe.fromJson(json as Map<String, dynamic>)).toList();
                            
                          },);
                        }
                      } catch (error) {
                        // Handle any unexpected errors that occur during the API call
                        showAlert(context, 'An unexpected error occurred. Please try later');
                      }
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      hintText: 'Search',
                      labelText: 'Search'
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          //Recipe Search Results
          Expanded(
            child: RecipeList(
              recipes: recipes
            ),
          ),
        ],
      ),
    );
  }
}

/*
Example recipelist
[
                Recipe(
                  id: 645354,
                  title: 'Greek Shrimp Orzo',
                  image: 'https://img.spoonacular.com/recipes/645354-312x231.jpg'
                ),
                Recipe(
                  id: 663151,
                  title: 'Thai Shrimp',
                  image: 'https://img.spoonacular.com/recipes/663151-312x231.jpg',
                ),
                Recipe(
                  id: 663151,
                  title: 'Thai Shrimp',
                  image: 'https://img.spoonacular.com/recipes/663151-312x231.jpg',
                ),
              ],
*/ 