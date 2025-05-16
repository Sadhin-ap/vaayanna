import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dummyproject/components/bookmetadata.dart';
import 'package:dummyproject/screens/pdf_book_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileScreen extends StatefulWidget {
  final String categoryName;
  const FileScreen(
      {Key? key, required this.categoryName, required List categories})
      : super(key: key);

  @override
  _FileScreenState createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  late Box<String> _filesBox;
  bool _initialized = false;
  bool _error = false;

  // Theme-aware color getters
  Color getPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3F51)
          : Colors.white;

  Color getSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3B5166)
          : Colors.blueGrey;

  Color getTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  @override
  void initState() {
    super.initState();
    _initBox();
  }

  Future<void> _initBox() async {
    try {
      _filesBox = Hive.box<String>('selectedFiles');
      if (!_filesBox.isOpen) throw 'Box not initialized';
      setState(() => _initialized = true);
    } catch (e) {
      setState(() => _error = true);
      _showSnackBar('Storage error: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = getPrimaryColor(context);
    final secondaryColor = getSecondaryColor(context);
    final textColor = getTextColor(context);

    if (!_initialized) {
      return Scaffold(
        backgroundColor: primaryColor,
        body: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(textColor),
        )),
      );
    }
    if (_error) {
      return Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: _initBox,
            child: Text('Retry', style: TextStyle(color: textColor)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName, style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      backgroundColor: primaryColor,
      body: ValueListenableBuilder(
        valueListenable: _filesBox.listenable(),
        builder: (_, Box<String> box, __) {
          if (box.isEmpty) return _emptyState(context);
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: box.length,
            itemBuilder: (_, i) {
              final data = jsonDecode(box.getAt(i)!);
              final meta = BookMetadata.fromJson(data);
              return ListTile(
                title: Text(meta.title, style: TextStyle(color: textColor)),
                subtitle: Text(meta.author,
                    style: TextStyle(color: textColor.withOpacity(0.7))),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: textColor.withOpacity(0.6)),
                      onPressed: () => _showMetadataForm(meta, i),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(i, meta.title),
                    ),
                  ],
                ),
                onTap: () => _openPdf(meta.filePath),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: _pickPdf,
        child: Icon(Icons.add, color: textColor),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: getSecondaryColor(context)),
          icon: Icon(Icons.add_circle_outline, color: getTextColor(context)),
          label:
              Text('Add File', style: TextStyle(color: getTextColor(context))),
          onPressed: _pickPdf,
        ),
      );

  Future<void> _pickPdf() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (res?.files.first.path == null) return;

    final file = File(res!.files.first.path!);
    if (await _isDuplicate(file)) {
      _showSnackBar('File already exists');
      return;
    }
    final newPath = await _saveFile(file);
    final fileNameWithoutExtension = p.basenameWithoutExtension(file.path);
    _showMetadataForm(
        BookMetadata(
            filePath: newPath,
            title: fileNameWithoutExtension,
            author: '',
            category: widget.categoryName),
        -1);
  }

  Future<bool> _isDuplicate(File file) async {
    final hash = md5.convert(await file.readAsBytes()).toString();
    for (var json in _filesBox.values) {
      final path = jsonDecode(json)['filePath'];
      if (path != null && File(path).existsSync()) {
        final h = md5.convert(await File(path).readAsBytes()).toString();
        if (h == hash) return true;
      }
    }
    return false;
  }

  Future<String> _saveFile(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final target = p.join(dir.path, 'pdfs');
    await Directory(target).create(recursive: true);
    final name =
        '\${DateTime.now().millisecondsSinceEpoch}_\${p.basename(file.path)}';
    return (await file.copy(p.join(target, name))).path;
  }

  void _showMetadataForm(BookMetadata meta, int index) {
    final titleCtrl = TextEditingController(text: meta.title);
    final authCtrl = TextEditingController(text: meta.author);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index < 0 ? 'Add Book' : 'Edit Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: authCtrl,
                decoration: const InputDecoration(labelText: 'Author')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: getSecondaryColor(context)),
            onPressed: () async {
              final updated = BookMetadata(
                filePath: meta.filePath,
                title: titleCtrl.text.isEmpty ? meta.title : titleCtrl.text,
                author: authCtrl.text.isEmpty ? meta.author : authCtrl.text,
                category: widget.categoryName,
              );
              final jsonStr = jsonEncode(updated.toJson());
              if (index < 0)
                await _filesBox.add(jsonStr);
              else {
                await _filesBox.putAt(index, jsonStr);
              }
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: getTextColor(context))),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete "\$title" permanently?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteFile(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(int index) async {
    final data = jsonDecode(_filesBox.getAt(index)!);
    final path = data['filePath'];
    await _filesBox.deleteAt(index);
    if (path != null && await File(path).exists()) await File(path).delete();
  }

  void _openPdf(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfBookPage(pdfPath: filePath)),
    );
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg), backgroundColor: getSecondaryColor(context)),
      );
}
