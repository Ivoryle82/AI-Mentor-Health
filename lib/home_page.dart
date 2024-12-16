import 'package:flutter/material.dart';
import 'guided_meditation_videos.dart';
import 'chat_page.dart';
import 'openai.dart';

class HomePage extends StatefulWidget {
  final String selectedRole;
  final OpenAI openAI;

  HomePage({required this.selectedRole, required this.openAI});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedEthnicity; // Store the selected ethnicity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/background_image.jpg"), // Correct the image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.selectedRole == 'Patient') ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EthnicityDropdown(
                        selectedEthnicity: selectedEthnicity,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedEthnicity = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      MindfulnessButton(
                        selectedEthnicity: selectedEthnicity,
                      ),
                      SizedBox(height: 12),
                      CounselorButton(
                        openAI: widget.openAI,
                        selectedEthnicity: selectedEthnicity,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EthnicityDropdown extends StatelessWidget {
  final String? selectedEthnicity;
  final ValueChanged<String?> onChanged;

  EthnicityDropdown({required this.selectedEthnicity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    List<String> ethnicities = [
      'Asian',
      'Black or African American',
      'Hispanic or Latino',
      'White',
      'Native American',
      'Pacific Islander',
      'Other'
    ];

    return Column(
      children: [
        Text('Please select your ethnicity:', style: TextStyle(fontSize: 18)),
        DropdownButton<String>(
          value: selectedEthnicity,
          hint: Text('Select Ethnicity'),
          onChanged: onChanged,
          items: ethnicities.map<DropdownMenuItem<String>>((String ethnicity) {
            return DropdownMenuItem<String>(
              value: ethnicity,
              child: Text(ethnicity),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MindfulnessButton extends StatelessWidget {
  final String? selectedEthnicity;

  MindfulnessButton({required this.selectedEthnicity});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (selectedEthnicity != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuidedMeditationVideosPage(
                selectedEthnicity: selectedEthnicity!,
              ),
            ),
          );
        } else {
          // Optionally show a message if no ethnicity is selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select an ethnicity first')),
          );
        }
      },
      child: Text('Mindfulness Practice'),
    );
  }
}

class CounselorButton extends StatelessWidget {
  final OpenAI openAI;
  final String? selectedEthnicity;

  CounselorButton({required this.openAI, required this.selectedEthnicity});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (selectedEthnicity != null) {
          //direct to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                openAI: openAI,
              ),
            ),
          ); 
        } else {
          // Optionally show a message if no ethnicity is selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select an ethnicity first')),
          );
        }
      },
      child: Text('Talk to a Counselor'),
    );
  }
}
