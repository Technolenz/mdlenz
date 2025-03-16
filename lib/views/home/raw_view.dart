import 'dart:io';

import 'package:file_picker/file_picker.dart'; // For file export
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RawViewScreen extends StatefulWidget {
  final TextEditingController textController;
  final Function onSave;
  final String? initialText; // Optional initial text for editing existing files

  const RawViewScreen({
    super.key,
    required this.textController,
    required this.onSave,
    this.initialText,
  });

  @override
  State<RawViewScreen> createState() => _RawViewScreenState();
}

class _RawViewScreenState extends State<RawViewScreen> {
  final List<String> _textHistory = []; // For undo functionality
  int _historyIndex = -1; // Current position in history
  bool _isDarkMode = false; // Dark mode toggle

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      widget.textController.text = widget.initialText!;
      _textHistory.add(widget.initialText!);
      _historyIndex = 0;
    }
  }

  // Add Markdown syntax to the text
  void _addMarkdownSyntax(String syntax) {
    final text = widget.textController.text;
    final selection = widget.textController.selection;

    final newText = text.replaceRange(selection.start, selection.end, syntax);
    widget.textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + syntax.length),
    );

    // Add to history
    _addToHistory(newText);
  }

  // Add text to history for undo/redo
  void _addToHistory(String text) {
    if (_historyIndex < _textHistory.length - 1) {
      _textHistory.removeRange(_historyIndex + 1, _textHistory.length);
    }
    _textHistory.add(text);
    _historyIndex = _textHistory.length - 1;
  }

  // Undo the last change
  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        widget.textController.text = _textHistory[_historyIndex];
      });
    }
  }

  // Redo the last undone change
  void _redo() {
    if (_historyIndex < _textHistory.length - 1) {
      setState(() {
        _historyIndex++;
        widget.textController.text = _textHistory[_historyIndex];
      });
    }
  }

  // Save Markdown with a unique key
  Future<void> _saveMarkdown() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final key = 'markdown_$timestamp';
    await prefs.setString(key, widget.textController.text);
    widget.onSave();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Markdown saved successfully!')));
  }

  // Export Markdown to a file
  Future<void> _exportMarkdown() async {
    try {
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Markdown File',
        fileName: 'markdown_export.md',
        allowedExtensions: ['md'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(widget.textController.text);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Markdown exported to ${file.path}')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export canceled.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export file: $e')));
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
    final text = widget.textController.text;
    final wordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final charCount = text.length;
    return 'Words: $wordCount | Characters: $charCount';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raw View'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo, tooltip: 'Undo'),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo, tooltip: 'Redo'),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMarkdown,
            tooltip: 'Save Markdown',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportMarkdown,
            tooltip: 'Export Markdown',
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
          // TextField for Markdown input
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
              child: TextField(
                controller: widget.textController,
                maxLines: null,
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your Markdown here...',
                  hintStyle: TextStyle(color: _isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ),
          ),
          // Options menu for Markdown syntax
          Container(
            padding: const EdgeInsets.all(10),
            color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.title),
                  onPressed: () => _addMarkdownSyntax('# '),
                  tooltip: 'Add Title',
                ),
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  onPressed: () => _addMarkdownSyntax('**bold text**'),
                  tooltip: 'Add Bold Text',
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _addMarkdownSyntax('![alt text](image_url)'),
                  tooltip: 'Add Image',
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => _addMarkdownSyntax('[link text](url)'),
                  tooltip: 'Add Link',
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted),
                  onPressed: () => _addMarkdownSyntax('- '),
                  tooltip: 'Add Bullet List',
                ),
                IconButton(
                  icon: const Icon(Icons.format_quote),
                  onPressed: () => _addMarkdownSyntax('> '),
                  tooltip: 'Add Blockquote',
                ),
                IconButton(
                  icon: const Icon(Icons.code),
                  onPressed: () => _addMarkdownSyntax('```\n\n```'),
                  tooltip: 'Add Code Block',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
//  In the code snippet above, we have created a new screen called  RawViewScreen  that allows users to edit Markdown text in a raw format. The screen includes the following features: 
 
//  Undo and redo functionality for text editing 
//  Save and export Markdown text to a file 
//  Toggle between light and dark modes 
//  Display word count and character count statistics 
//  Add Markdown syntax using buttons 
 
//  The  RawViewScreen  class extends  StatefulWidget  and contains a  TextEditingController  for the Markdown text, a function to save the text, and an optional initial text parameter for editing existing files. 
//  The  _RawViewScreenState  class manages the state of the screen and includes methods for adding Markdown syntax, managing text history, saving and exporting Markdown text, toggling dark mode, and displaying text statistics. 
//  The  build  method of the  RawViewScreen  class constructs the screen layout with an app bar, text statistics, a text field for Markdown input, and an options menu for adding Markdown syntax. 
//  Conclusion 
//  In this tutorial, we covered how to create a Markdown editor app in Flutter. We built a simple Markdown editor with live and raw views, text editing functionality, and file import/export features. 
//  You can further enhance the app by adding more Markdown syntax options, implementing additional text editing features, and improving the user interface. 
//  To learn more about Flutter app development, check out our  Flutter topic page. 
//  Are you looking for a Flutter app development company to build your app?  Contact us to discuss your project requirements with our team of expert developers! 