import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';

//Page 1
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });


  @override
  State<LoginPage> createState() => _LoginPageState();

  
}

class _LoginPageState extends State<LoginPage>{

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //Watches for changes in the appState

    return Center(
      child: Column(
        
        mainAxisAlignment: MainAxisAlignment.center,
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
                children: [
                  //Login Header
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  //Username Entry Field
                  Padding(
                    padding:  EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0, bottom: 8.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Username',
                        labelText: 'Username'
                      ),
                    ),
                  ),
                  //Password Entry Field
                  Padding(
                    padding:  EdgeInsets.only(left: 25.0, top: 8.0, right: 25.0, bottom: 25.0),
                    child: TextField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  //Login Button
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Await the loginAPI call and get user data
                        var userData = await loginAPI({
                          'Login': _usernameController.text,
                          'Password': _passwordController.text,
                        },);

                        // Check if there was an error in the response
                        if (userData.containsKey('ERROR')) {
                          showAlert(context, userData['ERROR']); //CHANGE TO THROW ERROR AT END
                        }else if(userData['id']==-1){
                          showAlert(context, 'Incorrect username or password');
                        } 
                        else {
                          // Successfully received user data and loggedin, update app state
                          appState.setUser(userData);
                          appState.setCurrentPage(4);
                          appState.setLoggedIn(true);
                          
                          // Call showAlert after the login is successful
                          showAlert(context, 'Welcome, ${appState.getUserFirstName()}!');
                        }
                      } catch (error) {
                        // Handle any unexpected errors that occur during the API call
                        showAlert(context, 'An unexpected error occurred. Please try later');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Background color
                      foregroundColor: Colors.black, // Text color
                      padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0), // Padding inside the button
                    ),
                    child: const Text('Login'),
                  ),
                  //Reset Password Button
                  TextButton(
                    onPressed: () {
                      
                      appState.setCurrentPage(3);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent, // Text color
                      padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: const Text('Reset Password'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose(){
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

