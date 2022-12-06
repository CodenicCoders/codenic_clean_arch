import 'package:flutter/material.dart';
import 'package:presentation/note/pages/note_entry_form_page.dart';
import 'package:presentation/note/widgets/paginated_notes_list_view.dart';
import 'package:presentation/note/widgets/stream_notes_list_view.dart';

/// {@template HomePage}
/// The home page for the note feature.
/// {@endtemplate}
class HomePage extends StatefulWidget {
  /// {@macro HomePage}
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The views that displayed on the home page.
  final _homeViews = <Widget>[
    const StreamNotesListView(),
    const PaginatedNotesListView(),
  ];

  /// An index for the currently displayed view from the [_homeViews].
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _homeViews[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NoteEntryFormPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() => _selectedIndex = value);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.short_text),
            label: 'Recent (Stream)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'All (Paginated)',
          ),
        ],
      ),
    );
  }
}
