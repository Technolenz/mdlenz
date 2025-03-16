import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart'; // For file picking
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_screen.dart'; // Import HomeScreen instead of RawViewScreen

class MainManagerScreen extends StatefulWidget {
  const MainManagerScreen({super.key});

  @override
  State<MainManagerScreen> createState() => _MainManagerScreenState();
}

class _MainManagerScreenState extends State<MainManagerScreen> {
  Map<String, String> _savedMarkdowns = {};
  bool _isDarkMode = false; // Dark mode toggle
  String _searchQuery = ''; // Search query
  final List<String> _selectedFiles = []; // Selected files for batch actions

  // Load all saved Markdown files from SharedPreferences
  Future<void> _loadSavedMarkdowns() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('markdown_')).toList();
    final markdowns = <String, String>{};
    for (final key in keys) {
      markdowns[key] = prefs.getString(key) ?? '';
    }
    setState(() {
      _savedMarkdowns = markdowns;
    });
  }

  // Delete a specific Markdown file
  Future<void> _deleteMarkdown(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _loadSavedMarkdowns(); // Refresh the list
  }

  // Delete selected files
  Future<void> _deleteSelectedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _selectedFiles) {
      await prefs.remove(key);
    }
    setState(() {
      _selectedFiles.clear();
    });
    await _loadSavedMarkdowns(); // Refresh the list
  }

  // Import Markdown files from the OS
  Future<void> _uploadMarkdowns() async {
    try {
      // Allow the user to pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        // Check if the file bytes are available
        Uint8List? fileBytes = file.bytes;

        String fileContent;
        if (fileBytes != null) {
          // Read the file content from bytes
          fileContent = String.fromCharCodes(fileBytes);
        } else if (file.path != null) {
          // Read the file content from the file path
          final filePath = file.path!;
          final fileData = File(filePath);
          fileContent = await fileData.readAsString();
        } else {
          // Handle case where neither bytes nor path is available
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Failed to read file content.')));
          }
          return;
        }

        // Save the file content to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final key = 'markdown_$timestamp';
        await prefs.setString(key, fileContent);

        // Refresh the list of saved Markdowns
        await _loadSavedMarkdowns();

        // Show a success message
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Markdown file imported successfully!')));
        }
      } else {
        // User canceled the file picker or no file was selected
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File import canceled or no file selected.')),
          );
        }
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to import file: $e')));
      }
    }
  }

  // Toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Filter files based on search query
  Map<String, String> _filterFiles() {
    if (_searchQuery.isEmpty) {
      return _savedMarkdowns;
    }
    return _savedMarkdowns.entries
        .where(
          (entry) =>
              entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              entry.value.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .fold(<String, String>{}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedMarkdowns(); // Load saved Markdowns when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    final filteredFiles = _filterFiles();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Markdowns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedMarkdowns,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _uploadMarkdowns,
            tooltip: 'Upload markdowns',
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Markdowns...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Batch actions bar
          if (_selectedFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('${_selectedFiles.length} selected'),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedFiles,
                    tooltip: 'Delete Selected',
                  ),
                ],
              ),
            ),
          // List of saved Markdowns
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children:
                  filteredFiles.entries.map((entry) {
                    final key = entry.key;
                    final markdown = entry.value;
                    final isSelected = _selectedFiles.contains(key);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color:
                          isSelected ? (_isDarkMode ? Colors.blue[800] : Colors.blue[100]) : null,
                      child: ListTile(
                        title: Text('Draft: ${key.replaceAll('markdown_', '')}'),
                        subtitle: MarkdownBody(data: markdown),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteMarkdown(key),
                          tooltip: 'Delete',
                        ),
                        onTap: () {
                          if (_selectedFiles.isNotEmpty) {
                            setState(() {
                              if (isSelected) {
                                _selectedFiles.remove(key);
                              } else {
                                _selectedFiles.add(key);
                              }
                            });
                          } else {
                            // Open the Markdown in HomeScreen for editing
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => HomeScreen(
                                      initialText:
                                          markdown, // Pass the Markdown content to HomeScreen
                                    ),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              _selectedFiles.remove(key);
                            } else {
                              _selectedFiles.add(key);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
