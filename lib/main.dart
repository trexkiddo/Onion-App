//import 'package:cop4331_lp_g30_redo/pages/favorites.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:cop4331_lp_g30_redo/pages/pages.dart';
import 'package:cop4331_lp_g30_redo/menus/customDrawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context) => MyAppState(),
      child: MaterialApp(
        title: 'Recipe App',
        theme: ThemeData(
          // This is the theme of your application.
         
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Onion'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var _currentPage = 0;
  bool _loggedIn = false;

  User currentUser = User(
    userId: '-1',
    username: '',
    userFirstName: '',
    userLastName: '',
    favorites: [],
    allergens: [],
    pantry: [],
    emailVerified: false,
  );
  
  int getCurrentPage() {
    return _currentPage;
  }
  void setCurrentPage(int page){
    _currentPage = page;
    notifyListeners();
  }

  bool getLoggedIn(){
    return _loggedIn;
  }
  void setLoggedIn(bool loggedIn){
    _loggedIn = loggedIn;
    notifyListeners();
  }

  void setUser(Map<String,dynamic> json) {
    currentUser = User.fromJson(json);
    notifyListeners();
  }

  void setEmailVerified(bool verified){
    currentUser.emailVerified = verified;
    notifyListeners();
  }

  User getUser(){
    return currentUser;
  }

  String getUserFirstName() {
    return currentUser.userFirstName;
  }

  String getUserLastName() {
    return currentUser.userLastName;
  }

  String getUsername() {
    return currentUser.username;
  }

  void addFavorite(int recipeAdded){
    currentUser.favorites.add(recipeAdded);
    notifyListeners();
  }

  void removeFavorite(int recipeRemoved){
    currentUser.favorites.remove(recipeRemoved);
    notifyListeners();
  }

  void addAllergen(String allergenAdded){
    currentUser.allergens.add(allergenAdded);
    notifyListeners();
  }

  void removeAllergen(String allergenRemoved){
    currentUser.allergens.remove(allergenRemoved);
    notifyListeners();
  }

  void updatePantry(List<String> item){
    currentUser.pantry = item;
    notifyListeners();
  }

  List<String> getPantry(){
    return currentUser.pantry;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called

    var appState = context.watch<MyAppState>();
    currentPage = appState.getCurrentPage();
    
    Widget page;
    switch(currentPage){
      case -1: //Leinecker
        page = const Leinecker();
        break;
      case 0://Landing
        page = const LandingPage();
        break;
      case 1: //Login
        page = const LoginPage();
        break;
      case 2: //Signup
        page = const SignupPage();
        break;
      case 3: //Reset Password
        page = const ResetPasswordPage();
        break;
      case 4: //Search recipes  
        page = const SearchPage();
        break;
      case 5: //Favorite Recipes 
        page = const FavoritesPage();
        break;
      case 6: //Pantry
        page = PantryPage();
        break;
      case 7: //User Profile
        page = const UserProfilePage();
        break;

      default:
        throw UnimplementedError('no widget for $currentPage');
    }    

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/LandingPageBG.jpg',
          ),
          fit: BoxFit.cover,
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
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // TRY THIS: Try changing the color here to a specific color (to
            // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
            // change color while the other colors stay the same.
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            centerTitle: true,
            title: Text(widget.title),
            leading: GestureDetector(
              onLongPress:() => appState.setCurrentPage(-1), //opens leinecker page on long press
              child: TextButton( //Adds onion button in the top left corner
                onPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                },
                child: const Text(
                  '🧅',
                  style: TextStyle(
                    fontSize: 30,
                  ), 
                ),
              ),
            ),
          ),
          drawer: CustomDrawer(),
          body: page,
          //Home Button
          floatingActionButton: FloatingActionButton( 
            onPressed: () {
              if(appState.getLoggedIn() == false){
                appState.setCurrentPage(0);
              }
              else{
                appState.setCurrentPage(4);
              }
            },
            tooltip: 'Home',
            child: const Icon(Icons.home),
          ),
        ),
      ),
    );
  }
}

void showAlert(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}

