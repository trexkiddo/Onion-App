import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';
import 'package:cop4331_lp_g30_redo/pages/searchByPantry.dart';



class PantryPage extends StatefulWidget {
  @override
  _PantryPageState createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  List<String> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter item'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _items.add(_controller.text);
                  _controller.clear();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context, listen: false);
    _items = appState.getPantry();
    //print('Items ${appState.getPantry()}');
    return Column(
      children: [
        //Pantry Header
        Container(
          margin: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'My Pantry',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        //const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                  title: Text(_items[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _items.removeAt(index); // Remove the item at the given index
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Search by pantry
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantrySearchPage(),
                    ),
                  );
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(), 
                padding: const EdgeInsets.symmetric(vertical:8, horizontal:0,), 
              ),
              child: const Icon(
                Icons.search,
              ),
            ),
            const SizedBox(width: 16.0), //for spacing
            ElevatedButton(
              onPressed: _showInputDialog,
              child: Text('Add Item'),
            ),
            const SizedBox(width: 16.0), //for spacing
            //Save button
            ElevatedButton(
              onPressed: () async {
                //update pantry api
                try{

                  var results = await updatePantryAPI({
                    'Login': appState.getUsername(),
                    'Pantry': _items,
                  });

                  if(!results.containsKey('error')){
                    throw Exception('Something went wrong when updating pantry');
                  } else if(results['error']!= 'Success'){
                    throw Exception(results['error']);
                  } else{
                    appState.updatePantry(_items);
                    showAlert(context, 'Pantry was successfully updated');
                  }

                }catch (error){
                  // Handle any unexpected errors that occur during the API call
                  showAlert(context, 'An unexpected error occurred. Please try later');
                }
                
                
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(), 
                padding: const EdgeInsets.symmetric(vertical:8, horizontal:0,),
              ),
              child: const Icon(
                Icons.save_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}