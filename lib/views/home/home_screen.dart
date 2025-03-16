import 'package:flutter/material.dart';
import 'package:mdlenz/views/home/live_view.dart';
import 'package:mdlenz/views/home/raw_view.dart';
import 'package:mdlenz/widgets/tab_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String? initialText; // Optional initial text for editing existing files

  const HomeScreen({super.key, this.initialText});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for the Markdown text
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _textController.text = widget.initialText!; // Pre-fill the controller with initial text
    }
    _loadSavedText();
  }

  // Load saved text from SharedPreferences
  Future<void> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();
    final savedText = prefs.getString('markdownText') ?? '';
    _textController.text = savedText;
  }

  // Save Markdown text to SharedPreferences
  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('markdownText', _textController.text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Markdown saved locally!')));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            // Reusable CustomTabBar
            CustomTabBar(tabs: const [Tab(text: 'Live View'), Tab(text: 'Raw View')]),
            // Container body for the tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Live View Screen
                  LiveViewScreen(controller: _textController),
                  // Raw View Screen
                  RawViewScreen(textController: _textController, onSave: _saveText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
