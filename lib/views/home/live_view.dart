import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart'; // For accessing directories
import 'package:shared_preferences/shared_preferences.dart';

class LiveViewScreen extends StatefulWidget {
  final TextEditingController controller;

  const LiveViewScreen({super.key, required this.controller});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  bool _isDarkMode = false; // Dark mode toggle

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateView);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateView);
    super.dispose();
  }

  void _updateView() {
    setState(() {});
  }

  // Save Markdown to a specific directory
  Future<void> _downloadMarkdown(BuildContext context) async {
    try {
      // Get the appropriate directory for saving the file
      final Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download'); // Android Downloads folder
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory(); // iOS Documents folder
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      // Ensure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create a unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File('${directory.path}/markdown_$timestamp.md');

      // Write the Markdown content to the file
      await file.writeAsString(widget.controller.text);

      // Save the file path to SharedPreferences for the file manager
      final prefs = await SharedPreferences.getInstance();
      final key = 'markdown_$timestamp';
      await prefs.setString(key, widget.controller.text);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Markdown saved to ${file.path}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
      }
    }
  }

  // Toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Get word count and character count
  String _getTextStats() {
    final text = widget.controller.text;
    final wordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final charCount = text.length;
    return 'Words: $wordCount | Characters: $charCount';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadMarkdown(context),
            tooltip: 'Download Markdown',
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
            tooltip: 'Toggle Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Text stats (word count and character count)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _getTextStats(),
              style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: 14),
            ),
          ),
          // Markdown view
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
              child: Markdown(
                data: widget.controller.text,
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                  h2: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                  h3: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                  p: TextStyle(fontSize: 16, color: _isDarkMode ? Colors.white : Colors.black),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                  em: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                  a: TextStyle(color: _isDarkMode ? Colors.blue : Colors.blue),
                  blockquote: TextStyle(color: _isDarkMode ? Colors.grey : Colors.grey[700]),
                  code: TextStyle(
                    backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
