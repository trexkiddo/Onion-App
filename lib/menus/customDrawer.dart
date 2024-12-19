//Side pull out menu

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cop4331_lp_g30_redo/main.dart';

class CustomDrawer extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>(); //Watches for changes in the appState
    var currentPage = appState.getCurrentPage(); //Grabs current page from appState

    return Drawer(
      child: Container(
        color: Color.lerp(Theme.of(context).colorScheme.inversePrimary, Colors.white, 0.6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height:125,
              child: DrawerHeader(
                decoration:BoxDecoration(
                  color:Theme.of(context).colorScheme.inversePrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton( //Close Drawer Button
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '🧅',
                        style: TextStyle(
                          fontSize: 20,
                        ), 
                      ),
                    ),
                    IconButton( //Home Button
                    tooltip: 'Home',
                      icon: Icon(Icons.home),
                      onPressed:() {
                        if(appState.getLoggedIn() == false){
                          appState.setCurrentPage(0);
                        }
                        else{
                          appState.setCurrentPage(4);
                        }
                      },
                    ),
                    IconButton( //Login/Logout Button
                    tooltip: 'User Profile',
                      icon:Icon(Icons.account_circle),
                      onPressed:() {
                        if(appState.getLoggedIn() == false){
                          appState.setCurrentPage(1);
                        }
                        else{
                          appState.setCurrentPage(7);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ), 
        
          //Builds the custom drawer options based on the current page
          if(currentPage >= 4) ...[ //LoggedInHome
            
            ListTile(
              title: const Text("Search"),
              onTap:() => appState.setCurrentPage(4),
            ),
            const Divider(),
            ListTile(
              title: const Text("Favorites"),
              onTap:() => appState.setCurrentPage(5),
            ),
            const Divider(),
            ListTile(
              title: const Text("Pantry"),
              onTap:() => appState.setCurrentPage(6),
            ),
            const Divider(),
            ListTile(
              title: const Text("Logout"),
              onTap:() {
                appState.setLoggedIn(false);
                appState.setCurrentPage(0);
              } 
            ),
            const Divider(),
          ]
          else ... [ //Default drawer menu options
            const ListTile(
              title: Text("Login to Access Onion's Features")
            ),
          ],
            
        
          ],
        ),
      ),
    );
  }
}