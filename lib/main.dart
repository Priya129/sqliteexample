import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'databasehelper.dart';


void main() {
  runApp(MaterialApp(
    home: CrudApp(),
  ));
}

class CrudApp extends StatefulWidget {
  @override
  _CrudAppState createState() => _CrudAppState();
}

class _CrudAppState extends State<CrudApp> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  int? _editingItemId;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _addItem() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final imagePath = _image?.path ?? '';

    if (title.isNotEmpty && description.isNotEmpty && imagePath.isNotEmpty) {
      if (_editingItemId == null) {
        // If not editing, insert a new item
        await _dbHelper.insertItem(title, description, imagePath);
      } else {
        // If editing, update the existing item
        await _dbHelper.updateItems(_editingItemId!, title, description, imagePath);
        _editingItemId = null; // Reset after updating
      }
      _fetchItems();
      _clearFields();
    }
  }

  Future<void> _fetchItems() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _image = null;
    });
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    _fetchItems();
  }

  void _editItem(Map<String, dynamic> item) {
    _titleController.text = item['title'];
    _descriptionController.text = item['description'];
    setState(() {
      _image = File(item['imagePath']);
      _editingItemId = item['id']; // Track the item being edited
    });
  }

  List<Map<String, dynamic>> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingItemId == null ? 'Add Item' : 'Edit Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 100, width: 100)
                : Text('No Image Selected'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: Text(_editingItemId == null ? 'Add Item' : 'Update Item'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    leading: item['imagePath'] != null
                        ? Image.file(File(item['imagePath']), width: 50, height: 50)
                        : Icon(Icons.image),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editItem(item), // Edit item
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteItem(item['id']), // Delete item
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
