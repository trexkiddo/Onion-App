import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  final TextEditingController _addAllergenController = TextEditingController();
    final TextEditingController _codeController = TextEditingController();

  @override
  void dispose(){
    _addAllergenController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //Watches for changes in the appState

    User user = appState.getUser();

    
    

    void _showInputDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Allergen'),
            content: TextField(
              controller: _addAllergenController,
              decoration: InputDecoration(hintText: 'Enter Allergen'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  //Add allergen api
                  try{
                    var results = await addAllergenAPI({
                      'Login': user.username,
                      'Allergen': _addAllergenController.text,
                    });

                    // Check if there was an error in the response
                    if (results.containsKey('ERROR')) {
                      showAlert(context, results['ERROR']);
                    }
                    //Check if adding was successful 
                    else if(results['error']!= 'Success'){
                      throw Exception('failed to add allergen');
                    }else {
                      setState(() {
                        user.allergens.add(_addAllergenController.text);
                        _addAllergenController.clear();
                      });
                    }

                  }catch (error) {
                    // Handle any unexpected errors that occur during the API call
                    showAlert(context, 'An unexpected error occurred. Please try later');
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    }

    void _showCodeDialog(){
      showDialog(
        context: context,
        builder:(context) {
          return AlertDialog(
            content: TextField(
              controller: _codeController,
              decoration: InputDecoration(hintText: 'Enter Code'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  //verify email code api
                  try{
                    var results = await validateEmailVerificationAPI({
                      'username': user.username,
                      'Code': _codeController.text,
                    });
                    
                    if(results.containsKey('error')){
                      showAlert(context, results['error']);
                    } else if(results.containsKey('message')){
                      showAlert(context,results['message']);
                      appState.setEmailVerified(true);
                    }else{
                      showAlert(context,'An error has occured with email verification. Please try again later');
                    }
                  }catch (error) {
                    // Handle any unexpected errors that occur during the API call
                    showAlert(context, 'An unexpected error occurred. Please try later');
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Verify'),
              ),
            ],
          );
        },
      );
    }
    
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //Login Box
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'User Profile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      'assets/onion.jpg'
                    ),
                  ),
                  
                  Text(
                    'Username: ${user.username}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Name: ${user.userFirstName} ${user.userLastName}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Verified Email: ',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        user.emailVerified ? Icons.check_circle : Icons.cancel,
                        color: user.emailVerified ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      //Verify Button
                      if(!user.emailVerified) ...[
                        const SizedBox(width:8),
                        ElevatedButton(
                          onPressed: () async {
                            // Handle verification logic
                            try{
                              var results = await requestEmailVerificationAPI({
                                'username': user.username,
                              });
                              
                              if(results.containsKey('error')){
                                showAlert(context, results['error']);
                              } else if(results.containsKey('message')){
                                showAlert(context,'Code has been sent to your email');
                                _showCodeDialog();
                              }else{
                                showAlert(context,'An error has occured with email verification. Please try again later');
                              }
                            }catch (error) {
                              // Handle any unexpected errors that occur during the API call
                              showAlert(context, 'An unexpected error occurred. Please try later');
                            }
                          },
                          child: Text("Verify"),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Allergens:',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  //List of allergens
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: ListView.builder(
                      itemCount: user.allergens.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4,),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 2), // Shadow position
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(user.allergens[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                //TODO: Add removeAllergenAPI
                                try {
                                  var results = await deleteAllergenAPI({
                                    'Login': user.username,
                                    'Allergen' : user.allergens[index],
                                  });

                                  if(results.containsKey('error')){
                                    //showAlert(context, results['error']);
                                    if(results['error'] == 'Success'){
                                      setState(() {
                                        user.allergens.removeAt(index); // Remove the item at the given index
                                      });
                                    } else {
                                      throw Exception('failed to delete allergen');
                                    }
                                  }
                                  else{
                                    throw Exception('Something went wrong when trying to delete');
                                  }
                                }catch (error) {
                                  // Handle any unexpected errors that occur during the API call
                                  showAlert(context, 'An unexpected error occurred. Please try later');
                                } 
                                
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showInputDialog,
                    child: Text('Add Allergen'),
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

class User {
  String userId;
  String username;
  String userFirstName;
  String userLastName;
  List<int> favorites;
  List<String> allergens;
  List<String> pantry;
  bool emailVerified;

  User({
    required this.userId,
    required this.username,
    required this.userFirstName,
    required this.userLastName,
    required this.favorites,
    required this.allergens,
    required this.pantry,
    required this.emailVerified,
  });

  // Factory constructor to create a UserProfile from a Map (decoded JSON object)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      username: json['username'],
      userFirstName: json['first_name'],
      userLastName: json['last_name'],
      favorites: List<int>.from(json['favorites'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      pantry: List<String>.from(json['pantry'] ?? []),
      emailVerified: json['verifiedEmail'] ?? false,
    );
  }

  @override
  String toString() {
    return 'User(userFirstName: $userFirstName, userLastName: $userLastName, favorites: $favorites, allergens: $allergens)';
  }
}