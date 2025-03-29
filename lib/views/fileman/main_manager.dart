import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/googleprovider.dart';
import '../home/home_screen.dart';

class MainManagerScreen extends StatefulWidget {
  const MainManagerScreen({super.key});

  @override
  State<MainManagerScreen> createState() => _MainManagerScreenState();
}

class _MainManagerScreenState extends State<MainManagerScreen> {
  Map<String, String> _savedMarkdowns = {};
  final List<String> _selectedFiles = [];
  bool _isSelectMode = false;
  late GoogleProvider _googleProvider;

  @override
  void initState() {
    super.initState();
    _googleProvider = Provider.of<GoogleProvider>(context, listen: false);
    _loadSavedMarkdowns();
  }

  Future<void> _loadSavedMarkdowns() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('markdown_'));
    final markdowns = {for (final key in keys) key: prefs.getString(key) ?? ''};
    setState(() => _savedMarkdowns = markdowns);
  }

  Future<void> _deleteMarkdown(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    _savedMarkdowns.remove(key);
    await _googleProvider.syncMarkdown(key, '');
    setState(() {});
  }

  Future<void> _deleteSelectedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _selectedFiles) {
      await prefs.remove(key);
    }
    setState(() {
      _selectedFiles.clear();
      _isSelectMode = false;
    });
    await _loadSavedMarkdowns();
  }

  Future<void> _uploadMarkdowns() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        int successCount = 0;

        for (final file in result.files) {
          try {
            final fileContent =
                file.bytes != null
                    ? String.fromCharCodes(file.bytes!)
                    : await File(file.path!).readAsString();

            final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
            final key = 'markdown_$timestamp';

            await prefs.setString(key, fileContent);
            if (_googleProvider.isSyncEnabled) {
              await _googleProvider.syncMarkdown(key, fileContent);
            }

            successCount++;
          } catch (e) {
            debugPrint('Error importing ${file.name}: $e');
          }
        }

        await _loadSavedMarkdowns();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported $successCount/${result.files.length} files')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import error: ${e.toString()}')));
      }
    }
  }

  Map<String, String> _filterFiles(String searchQuery) {
    if (searchQuery.isEmpty) return _savedMarkdowns;

    return Map.fromEntries(
      _savedMarkdowns.entries.where((entry) {
        final query = searchQuery.toLowerCase();
        return entry.value.toLowerCase().contains(query) || entry.key.toLowerCase().contains(query);
      }),
    );
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return timestamp;
    }
  }

  String _getPreviewText(String content) {
    return content
        .split('\n')
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => 'Empty document');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Manager'),
        actions: [
          if (_isSelectMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed:
                  () => setState(() {
                    _selectedFiles.clear();
                    _isSelectMode = false;
                  }),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed:
                  () => showSearch(
                    context: context,
                    delegate: _MarkdownSearchDelegate(_savedMarkdowns),
                  ),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSavedMarkdowns),
          IconButton(icon: const Icon(Icons.upload_file), onPressed: _uploadMarkdowns),
        ],
      ),
      body:
          _savedMarkdowns.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add, size: 64, color: theme.hintColor),
                    const SizedBox(height: 16),
                    Text('No markdown files found', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Tap the upload button to import files', style: theme.textTheme.bodySmall),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _savedMarkdowns.length,
                itemBuilder: (context, index) {
                  final key = _savedMarkdowns.keys.elementAt(index);
                  final content = _savedMarkdowns[key]!;
                  final isSelected = _selectedFiles.contains(key);
                  final timestamp = key.replaceAll('markdown_', '');

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color:
                        isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (_isSelectMode) {
                          setState(() {
                            isSelected ? _selectedFiles.remove(key) : _selectedFiles.add(key);
                            if (_selectedFiles.isEmpty) _isSelectMode = false;
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChangeNotifierProvider(
                                    create: (_) => GoogleProvider(),
                                    child: HomeScreen(initialText: content),
                                  ),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          _isSelectMode = true;
                          isSelected ? _selectedFiles.remove(key) : _selectedFiles.add(key);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_isSelectMode)
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? theme.colorScheme.primary : theme.hintColor,
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Document ${index + 1}',
                                    style: theme.textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(_formatDate(timestamp), style: theme.textTheme.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getPreviewText(content),
                              style: theme.textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _selectedFiles.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _deleteSelectedFiles,
                icon: const Icon(Icons.delete),
                label: Text('Delete (${_selectedFiles.length})'),
                backgroundColor: theme.colorScheme.error,
              )
              : null,
    );
  }
}

class _MarkdownSearchDelegate extends SearchDelegate {
  final Map<String, String> markdowns;

  _MarkdownSearchDelegate(this.markdowns);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final results =
        markdowns.entries.where((entry) {
          final lowerQuery = query.toLowerCase();
          return entry.value.toLowerCase().contains(lowerQuery) ||
              entry.key.toLowerCase().contains(lowerQuery);
        }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No matching markdown files found.'));
    }

    return ListView(
      children:
          results.map((entry) {
            final timestamp = entry.key.replaceAll('markdown_', '');
            final formattedDate = _formatDate(timestamp);
            final previewText = _getPreviewText(entry.value);

            return ListTile(
              title: Text('Document ($formattedDate)'),
              subtitle: Text(previewText, maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HomeScreen(
                          initialText: entry.value,
                          isViewOnly: true, // Open in view-only mode first
                        ),
                  ),
                );
              },
            );
          }).toList(),
    );
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown Date';
    }
  }

  String _getPreviewText(String content) {
    return content
        .split('\n')
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => 'Empty document');
  }
}
