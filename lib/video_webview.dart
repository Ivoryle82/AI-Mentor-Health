// might not need this but keep just in case
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class VideoWebView extends StatelessWidget {
//   final String url;

//   const VideoWebView({required this.url});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Watch Video'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(
//             controller: WebViewController()
//               ..setJavaScriptMode(JavaScriptMode.unrestricted)
//               ..loadRequest(Uri.parse(url)),
//           ),
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context); // Navigate back to the previous screen
//               },
//               child: Text('Return to Survey'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
