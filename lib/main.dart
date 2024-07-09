import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:not_book/add_note_page.dart';
import 'package:not_book/edit_note_page.dart';
import 'package:not_book/note.dart';
import 'package:not_book/notes_search.dart';
import 'package:not_book/trash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(NotBookApp());
}

class NotBookApp extends StatefulWidget {
  @override
  _NotBookAppState createState() => _NotBookAppState();
}

class _NotBookAppState extends State<NotBookApp> {
  bool _isDarkMode = false; // Başlangıçta varsayılan olarak açık tema

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode; // Temayı değiştir
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Book',
      theme: _isDarkMode ? _darkTheme : _lightTheme,
      home: NotesListPage(
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
    color: Colors.white,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.purple,
  ),
);

final ThemeData _darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
    color: Colors.grey[900],
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
  ),
);

class NotesListPage extends StatefulWidget {
  final Function toggleTheme;

  NotesListPage({required this.toggleTheme});

  @override
  _NotesListPageState createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  SharedPreferences? _prefs;
  String _selectedTag = 'Hepsi';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String>? notesJson = _prefs?.getStringList('notes');
      if (notesJson != null) {
        _notes =
            notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
        _notes.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
        _filteredNotes = _notes.where((note) => !note.isDeleted).toList();
      }
    });
  }

  _filterNotes(String tag) {
    setState(() {
      if (tag == 'Hepsi') {
        _filteredNotes = List.from(_notes);
      } else {
        _filteredNotes =
            _notes.where((note) => note.tags.contains(tag)).toList();
      }
      _selectedTag = tag;
    });
  }

  _navigateToAddNotePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage()),
    );

    if (result != null) {
      setState(() {
        _notes.insert(0, result);
        _saveNotes();
        _filterNotes(_selectedTag);
      });
    }
  }

  _saveNotes() {
    _notes.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
    List<String> notesJson =
        _notes.map((note) => jsonEncode(note.toJson())).toList();
    _prefs?.setStringList('notes', notesJson);
  }

  _deleteNoteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notu Sil'),
          content: Text('Bu notu silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                _deleteNote(_filteredNotes[index]);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteNote(Note note) {
    setState(() {
      note.isDeleted = true;
      _saveNotes();
      _filterNotes(_selectedTag);
    });
  }

  _showNoteDetail(Note note) async {
    final editedNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNotePage(note: note)),
    );

    if (editedNote != null) {
      setState(() {
        _notes[_notes.indexWhere((element) => element == note)] = editedNote;
        _saveNotes();
        _filterNotes(_selectedTag);
      });
    }
  }

  _openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tüm Notlar',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NotesSearch(_notes),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.palette),
            onPressed: () {
              widget.toggleTheme(); // Temayı değiştirmek için düğmeyi kullan
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menü'),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              title: Text('Tüm Notlar'),
              onTap: () {
                Navigator.pop(context); // Menüyü kapat
                // Tüm notları göster
                _filterNotes('Hepsi');
              },
            ),
            ListTile(
              title: Text('Etiketler'),
              onTap: () {
                Navigator.pop(context); // Menüyü kapat
                // Etiketleri göster
                // Örneğin: _filterNotes('etiket1');
              },
            ),
            ListTile(
              title: Text('Çöp Kutusu'),
              onTap: () {
                Navigator.pop(context); // Menüyü kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrashPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedTag,
              onChanged: (String? newTag) {
                if (newTag != null) {
                  _filterNotes(newTag);
                }
              },
              items: <String>[
                'Hepsi',
                ..._notes.expand((note) => note.tags).toSet()
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
              hint: Text("Etiketlere göre filtrele"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                return !_filteredNotes[index].isDeleted
                    ? Card(
                        margin: EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            _filteredNotes[index].title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_filteredNotes[index].content),
                              SizedBox(height: 4.0),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      _filteredNotes[index].tags.join(', '),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon:
                                        Icon(Icons.delete, color: Colors.grey),
                                    onPressed: () =>
                                        _deleteNoteConfirmation(index),
                                  ),
                                ],
                              ),
                              Text(
                                'Son düzenleme: ${_filteredNotes[index].lastEdited.toLocal()}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () => _showNoteDetail(_filteredNotes[index]),
                        ),
                      )
                    : Container();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNotePage,
        child: Icon(Icons.add),
      ),
    );
  }
}
