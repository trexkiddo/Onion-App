import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';

//Page 3
class SignupPage extends StatefulWidget {
  const SignupPage({
    super.key,
  });


  @override
  State<SignupPage> createState() => _SignupPageState();

}

class _SignupPageState extends State<SignupPage>{
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //Watches for changes in the appState

    return Center(
      child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
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
                  //Reset Header
                  Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  //Email Entry Field
                  Padding(
                    padding:  EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0, bottom: 8.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'example@example.com',
                        labelText: 'Email'
                      ),
                    ),
                  ),
                  //First Name Entry Field
                  Padding(
                    padding:  EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0, bottom: 8.0),
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'John',
                        labelText: 'First Name'
                      ),
                    ),
                  ),
                  //Last Name Entry Field
                  Padding(
                    padding:  EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0, bottom: 8.0),
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Smith',
                        labelText: 'Last Name'
                      ),
                    ),
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
                        hintText: 'username',
                        labelText: 'Username'
                      ),
                    ),
                  ),
                  //Password Entry Field
                  Padding(
                    padding:  EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0, bottom: 8.0),
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'password',
                        labelText: 'Password'
                      ),
                    ),
                  ),
                  //Signup Button
                  ElevatedButton(
                    onPressed: () async {
                      
                      try {
                        // Await the loginAPI call and get user data
                        var userData = await signupAPI({
                          'Login': _usernameController.text,
                          'Password': _passwordController.text,
                          'FirstName': _firstNameController.text,
                          'LastName': _lastNameController.text,
                          'Email': _emailController.text,
                        });

                        // Check if there was an error in the response
                        if (userData.containsKey('ERROR')) {
                          showAlert(context, userData['ERROR']);
                        } 
                        else {
                          //Account Successfully Created
                          appState.setCurrentPage(1);
                          showAlert(context, 'Account Successfully Created. Feel Free To Login');
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
                    child: Text('Sign Up'),
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
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}