import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:not_book/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashPage extends StatefulWidget {
  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  List<Note> _deletedNotes = [];
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadDeletedNotes();
  }

  _loadDeletedNotes() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String>? notesJson = _prefs?.getStringList('notes');
      if (notesJson != null) {
        _deletedNotes = notesJson
            .map((json) => Note.fromJson(jsonDecode(json)))
            .where((note) => note.isDeleted)
            .toList();
      }
    });
  }

  _restoreNote(Note note) {
    setState(() {
      note.isDeleted = false;
      _deletedNotes.remove(note);
      _saveNotes();
    });
  }

  _deleteNotePermanently(Note note) {
    setState(() {
      _deletedNotes.remove(note);
      _saveNotes();
    });
  }

  _saveNotes() {
    List<String> notesJson =
        _deletedNotes.map((note) => jsonEncode(note.toJson())).toList();
    _prefs?.setStringList('notes', notesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çöp Kutusu'),
      ),
      body: _deletedNotes.isEmpty
          ? Center(
              child: Text('Çöp kutusu boş.'),
            )
          : ListView.builder(
              itemCount: _deletedNotes.length,
              itemBuilder: (context, index) {
                final note = _deletedNotes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.restore),
                        onPressed: () => _restoreNote(note),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () => _deleteNotePermanently(note),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
