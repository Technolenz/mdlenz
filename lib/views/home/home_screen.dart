import 'package:flutter/material.dart';
import 'package:mdlenz/views/home/live_view.dart';
import 'package:mdlenz/views/home/raw_view.dart';
import 'package:mdlenz/widgets/tab_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String? initialText;
  final bool isViewOnly; // New parameter to control editability

  const HomeScreen({
    super.key,
    this.initialText,
    this.isViewOnly = false, // Default to editable
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
    _loadSavedText();
  }

  Future<void> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();
    final savedText = prefs.getString('markdownText') ?? '';
    if (_textController.text.isEmpty) {
      _textController.text = savedText;
    }
  }

  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('markdownText', _textController.text);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Markdown saved locally!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.isViewOnly ? 1 : 2, // Only show Live View if view only
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (widget.isViewOnly) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                HomeScreen(initialText: _textController.text, isViewOnly: false),
                      ),
                    ),
                tooltip: 'Edit Document',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareDocument(context),
                tooltip: 'Share Document',
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            if (!widget.isViewOnly)
              CustomTabBar(tabs: const [Tab(text: 'Live View'), Tab(text: 'Raw View')]),
            Expanded(
              child: TabBarView(
                children: [
                  LiveViewScreen(controller: _textController),
                  if (!widget.isViewOnly)
                    RawViewScreen(textController: _textController, onSave: _saveText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareDocument(BuildContext context) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        _textController.text,
        subject: 'Markdown Document',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }
}
