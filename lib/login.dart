import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'home_page.dart'; // Import HomePage
import 'openai.dart'; // Import your OpenAI service or class

class LoginPage extends StatefulWidget {
  final Function(String, String?) onLoginSuccess;

  LoginPage({required this.onLoginSuccess});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? selectedRole;
  String? selectedCounselorLevel;
  final List<String> roles = ['Patient', 'Counselor'];
  final List<String> counselorLevels = ['Junior', 'Senior', 'Expert'];

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAuthenticated = false;

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _isAuthenticated = true;
      });
    } catch (e) {
      print('Failed to sign in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: $e')),
      );
    }
  }

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isAuthenticated = true;
      });
    } catch (e) {
      print('Failed to sign up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isAuthenticated ? _buildRoleSelection() : _buildAuthForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _signIn,
          child: Text('Sign In'),
        ),
        ElevatedButton(
          onPressed: _signUp,
          child: Text('Sign Up'),
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        DropdownButton<String>(
          hint: Text('Select Role'),
          value: selectedRole,
          onChanged: (String? newValue) {
            setState(() {
              selectedRole = newValue;
              selectedCounselorLevel = null;
            });
          },
          items: roles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        if (selectedRole == 'Counselor') ...[
          SizedBox(height: 16.0),
          DropdownButton<String>(
            hint: Text('Select Counselor Level'),
            value: selectedCounselorLevel,
            onChanged: (String? newValue) {
              setState(() {
                selectedCounselorLevel = newValue;
              });
            },
            items: counselorLevels.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
        SizedBox(height: 16.0),
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              if (selectedRole != null) {
                // Get the OpenAI API key from the .env file
                final openAIKey = dotenv.env['OPENAI_API_KEY']; // Fetch the API key
                
                if (openAIKey != null) {
                  final openAI = OpenAI(apiKey: openAIKey); // Initialize OpenAI

                  widget.onLoginSuccess(selectedRole!, selectedCounselorLevel);

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        selectedRole: selectedRole!,
                        openAI: openAI,
                      ),
                    ),
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('OpenAI API key is missing')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a role')),
                );
              }
            },
            child: Text('Login'),
          ),
        ),
      ],
    );
  }
}