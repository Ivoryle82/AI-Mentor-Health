import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login.dart';
import 'openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated firebase_options.dart
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  final String? apiKey = dotenv.env['OPENAI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('OPENAI_API_KEY not found in .env file');
  }

  runApp(MyApp(OpenAI(apiKey: apiKey))); // Initialize the app with the OpenAI API key
}

class MyApp extends StatelessWidget {
  final OpenAI openAI;

  MyApp(this.openAI); // Constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentalCounselor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoginPage(
        onLoginSuccess: (String selectedRole, String? selectedCounselorLevel) {
          // Defer navigation until the current frame is rendered
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  selectedRole: selectedRole,
                  openAI: openAI,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Example'),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
