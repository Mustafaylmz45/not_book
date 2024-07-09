import 'package:flutter/material.dart';
import 'package:not_book/note.dart';

class AddNotePage extends StatefulWidget {
  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Not Oluştur'),
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
                  Note newNote = Note(
                    title: title,
                    content: content,
                    lastEdited: DateTime.now(),
                    tags: tags,
                  );
                  Navigator.pop(context, newNote);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
              ),
              child: Text('Notu Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
