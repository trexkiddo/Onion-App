import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';
import 'package:cop4331_lp_g30_redo/pages/userProfile.dart';

//Card to display recipes
class RecipeCard extends StatefulWidget{
  final int recipeID;
  final String recipeName;
  final String imageUrl;
  final VoidCallback onButtonPressed;

  const RecipeCard({
    Key? key,
    required this.recipeID,
    required this.recipeName,
    required this.imageUrl,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  

  bool isFavorite = false ;

  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>(); //Watches for changes in the appState
    User user = appState.getUser();

    isFavorite = user.favorites.contains(widget.recipeID); 

    return Card(
      color:Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Image.network(
              widget.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Image.asset(
                  'assets/onion.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.recipeName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // Button
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: widget.onButtonPressed,
                    child: const Text('View Recipe'),
                  ),
                  // Star Button
                IconButton(
                  onPressed: () async {
                    
                    if(isFavorite){
                      
                      try {
                        //Try to removeFavorite
                        var results = await deleteFavoriteAPI({
                          'Login': user.username,
                          'RecipeID': widget.recipeID,
                        });

                        if(results.containsKey('error')){
                          showAlert(context, results['error']);
                          if(results['error'] == 'Success'){
                            appState.removeFavorite(widget.recipeID);
                          }
                        }
                        else{
                          throw Exception('Something went wrong when trying to delete');
                        }
                      } catch (error) {
                        // Handle any unexpected errors that occur during the API call
                        showAlert(context, 'An unexpected error occurred. Please try later');
                      }
                    } else {
                      
                      try {
                        //Try to addFavorite
                        var results = await addFavoriteAPI({
                          'Login': user.username,
                          'RecipeID': widget.recipeID,
                        });

                        // Check if there was an error in the response
                        if (results.containsKey('ERROR')) {
                          showAlert(context, results['ERROR']);
                        }
                        //Check if adding was successful 
                        else if(results['error']!= 'Success'){
                          throw Exception('failed to add favorite');
                        }else {
                          appState.addFavorite(widget.recipeID);
                          showAlert(context, 'Succesfully added to favorites');
                          //appState.setCurrentPage(5); //Temp fix
                        }
                      } catch (error) {
                        // Handle any unexpected errors that occur during the API call
                        showAlert(context, 'An unexpected error occurred. Please try later');
                      }
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                  ), // Star icon
                  color: Colors.amber,
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}