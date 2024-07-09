import 'package:flutter/material.dart';
import 'package:not_book/note.dart';

class EditNotePage extends StatefulWidget {
  final Note note;

  EditNotePage({required this.note});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    _tagsController.text = widget.note.tags.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notu Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Başlık (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'Etiketler (virgülle ayırın)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Notunuzu buraya yazın...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text.trim();
                String content = _contentController.text.trim();
                List<String> tags = _tagsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList();
                if (content.isNotEmpty) {
                  Note editedNote = Note(
                    title: title,
                    content: content,
                    lastEdited: DateTime.now(),
                    tags: tags,
                  );
                  Navigator.pop(context, editedNote);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
              ),
              child: Text('Değişiklikleri Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
