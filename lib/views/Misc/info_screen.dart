import 'package:flutter/material.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use the App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Welcome to MD-Lenz: \nThe only Markdown Editor App you Need!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app allows you to write and preview Markdown content in real-time. Below are some visualizations to help you get started:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Visualization 1: Writing Markdown
            const Text(
              '1. Writing Markdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the Raw View to write your Markdown content. You can use the toolbar to quickly add Markdown syntax like headers, bold text, links, and more.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '# Heading 1\n'
                    '## Heading 2\n'
                    '**Bold Text**\n'
                    '*Italic Text*\n'
                    '[Link](https://example.com)',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'This is how your Markdown will look in the Live View.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visualization 2: Live Preview
            const Text(
              '2. Live Preview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Switch to the Live View to see a real-time preview of your Markdown content. The preview updates automatically as you type.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Heading 1\n'
                    'Heading 2\n'
                    'Bold Text\n'
                    'Italic Text\n'
                    'Link',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'This is how your Markdown will look in the Live View.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visualization 3: Saving and Exporting
            const Text(
              '3. Saving and Exporting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can save your Markdown files locally or export them as .md files. Use the save and export buttons in the app bar to manage your files.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.save, size: 40, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Text(
                    'Save your work locally or export it to your device.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visualization 4: Dark Mode
            const Text('4. Dark Mode', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Toggle between light and dark mode for a comfortable writing experience. Use the dark mode button in the app bar to switch themes.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.light_mode, size: 40, color: Colors.orange),
                  const SizedBox(width: 16),
                  const Icon(Icons.dark_mode, size: 40, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
