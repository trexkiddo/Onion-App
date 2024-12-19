import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';

//Page 0
class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //Watches for changes in the appState

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center ,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Login Button
            ElevatedButton.icon(
              onPressed: () {
                appState.setCurrentPage(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Background color
                foregroundColor: Colors.black, // Text color
                padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0), // Padding inside the button
              ),
              icon: const Icon(Icons.account_circle),
              label: const Text(' Login '),
            ),
            //SignUp Button
            ElevatedButton.icon(
              onPressed: () {
                appState.setCurrentPage(2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Background color
                foregroundColor: Colors.black, // Text color
                padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0), // Padding inside the button
              ),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Sign Up'),
            ),
            
          ],
        ),
      ],
    );
  }
}
