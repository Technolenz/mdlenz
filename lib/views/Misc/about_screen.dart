import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MD-Lenz', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'This app is an open-source Markdown editor designed to help you write, edit, and preview Markdown content seamlessly. It is licensed under the GNU General Public License (GPL).',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('Features:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                '- Live Markdown preview\n'
                '- Save and load Markdown files\n'
                '- Export Markdown to .md files\n'
                '- Dark mode support\n'
                '- Open-source and free to use',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('Developer:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Michael Tunwashe (Technolenz)\n'
                'Actuary Aspirant & Tech Enthusiast',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('License:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'This app is open-source and distributed under the GNU General Public License (GPL). You are free to use, modify, and distribute it as per the terms of the license.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'GitHub Repository:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse('https://github.com/Technolenz/mdlenz');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                style: ButtonStyle(),
                child: Text('https://github.com/Technolenz/mdlenz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
