//works
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GuidedMeditationVideosPage extends StatelessWidget {
  final String selectedEthnicity;

  GuidedMeditationVideosPage({required this.selectedEthnicity});

  final List<Map<String, String>> videos = [
    {
      'title':
          'Breathing Practice -10 minute guided meditation (American voice)',
      'url': 'https://www.youtube.com/embed/iuv5EomIA9s',
      'ethnicity': 'American'
    },
    {
      'title':
          '10 minute breath work & light meditation - African American voice',
      'url': 'https://www.youtube.com/embed/a1oLLA1aDRU',
      'ethnicity': 'African American'
    },
    {
      'title': 'Mindful Meditation in Mandarin',
      'url': 'https://www.youtube.com/embed/rrZV55JjIcg',
      'ethnicity': 'Asian'
    },
    {
      'title': '10 minute guided mindfulness meditation - Indian voice',
      'url': 'https://www.youtube.com/embed/PttMV1xRJv4',
      'ethnicity': 'Asian'
    },
    {
      'title': '10 minute mindfulness meditation - American Female voice',
      'url': 'https://www.youtube.com/embed/ZToicYcHIOU',
      'ethnicity': 'American'
    },
    {
      'title':
          'Mindfulness Meditation - Guided 10 minutes (American Male Voice)',
      'url': 'https://www.youtube.com/embed/6p_yaNFSYao',
      'ethnicity': 'American'
    },
    {
      'title':
          '10 minute daily meditation for stress relief (American Male Voice)',
      'url': 'https://www.youtube.com/embed/I9Z4t9ZiUzM',
      'ethnicity': 'American'
    },
    {
      'title':
          'Mindfulness for Overthinking Guided Meditation (American female voice)',
      'url': 'https://www.youtube.com/embed/MH6uK2-ieb0',
      'ethnicity': 'American'
    },
    {
      'title': 'Relaxing Meditation - Hispanic voice',
      'url': 'https://www.youtube.com/embed/example',
      'ethnicity': 'Hispanic'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter videos based on selected ethnicity
    List<Map<String, String>> filteredVideos = videos.where((video) {
      return video['ethnicity'] == selectedEthnicity;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Guided Meditation Videos')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: filteredVideos.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredVideos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredVideos[index]['title']!,
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(Icons.play_arrow, color: Colors.white),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewPage(
                                url: filteredVideos[index]['url']!,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No videos available for $selectedEthnicity',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please answer this survey after watching the mindfulness videos:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  SurveyForm(videos: filteredVideos),
                ],
              ),
            ),
          ],
        ),
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
      appBar: AppBar(title: Text('Video WebView')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}

class SurveyForm extends StatefulWidget {
  final List<Map<String, String>> videos;

  SurveyForm({required this.videos});

  @override
  _SurveyFormState createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  String? selectedVideo;
  String? problem;
  double feelingBetter = 0.0;

  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('Video: $selectedVideo');
      print('Problem: $problem');
      print('Feeling Better: $feelingBetter');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for your feedback!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Which video did you watch?',
              border: OutlineInputBorder(),
            ),
            value: selectedVideo,
            onChanged: (String? newValue) {
              setState(() {
                selectedVideo = newValue;
              });
            },
            items: widget.videos.map<DropdownMenuItem<String>>((video) {
              return DropdownMenuItem<String>(
                value: video['title'],
                child: Text(video['title']!),
              );
            }).toList(),
            validator: (value) =>
                value == null ? 'Please select a video' : null,
          ),
          SizedBox(height: 16.0),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'What was your problem?',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                problem = value;
              });
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please describe your problem'
                : null,
          ),
          SizedBox(height: 16.0),
          Text(
            'How much better do you feel after watching the video?',
            style: TextStyle(fontSize: 16.0),
          ),
          Slider(
            value: feelingBetter,
            onChanged: (value) {
              setState(() {
                feelingBetter = value;
              });
            },
            min: 0,
            max: 10,
            divisions: 10,
            label: feelingBetter.round().toString(),
          ),
          SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
