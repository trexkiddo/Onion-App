import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cop4331_lp_g30_redo/main.dart';
import 'package:cop4331_lp_g30_redo/API/callAPI.dart';


//Page 3
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
  });


  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();

}

class _ResetPasswordPageState extends State<ResetPasswordPage>{
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context, listen: false);

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
                  //Reset Header
                  Text(
                    'Reset',
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
                  //Reset Password Button
                  ElevatedButton(
                    onPressed: () async {

                      try {
                        //requestPasswordReset
                        var requestResult = await requestPasswordResetAPI({
                          'Email': _emailController.text,
                        });

                        //Returns error if api doesnt work
                        if(requestResult.containsKey('error')){
                          showAlert(context, requestResult['error']);
                        }
                        else if(requestResult.containsKey('message')){
                          showAlert(context, requestResult['message']);
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Ensures the dialog adjusts to content
                                  children: [
                                    Text(
                                      'Reset Password',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 16.0),
                                    TextField(
                                      controller: _codeController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Reset Code',
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    TextField(
                                      controller: _newPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'New Password',
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          var validateResult = await validatePasswordResetAPI({
                                            'Email':_emailController.text,
                                            'Code':_codeController.text,
                                            'NewPassword':_newPasswordController.text,
                                          });

                                          //Returns error if api doesnt work
                                          if(validateResult.containsKey('error')){
                                            showAlert(context, validateResult['error']);
                                            _codeController.clear();
                                            _newPasswordController.clear();
                                          }
                                          else if(validateResult.containsKey('message')){
                                            showAlert(context, validateResult['message']);
                                            Navigator.pop(context); // Close the dialog
                                            appState.setCurrentPage(1);
                                          }
                                          else{
                                            throw Exception('');
                                          }
                                          
                                        }catch (error){
                                          // Handle any unexpected errors that occur during the API call
                                          showAlert(context, 'An unexpected error occurred. Please try later');
                                        }

                                        
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        else {
                          throw Exception('');
                        }
                      }catch (error) {
                        // Handle any unexpected errors that occur during the API call
                        showAlert(context, 'An unexpected error occurred. Please try later');
                      }

                      
                      //TODO: API Call to email reset API
                      //showAlert(context,'A reset link has been sent to your email');
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Background color
                      foregroundColor: Colors.black, // Text color
                      padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0), // Padding inside the button
                    ),
                    child: Text('Reset Password'),
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
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}