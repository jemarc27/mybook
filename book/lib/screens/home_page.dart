import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/book_card.dart';
import 'add_book_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> books = [];
  // Remove hasFetched and always fetch on init
  final String apiUrl = 'http://192.168.195.254:3000/api/books'; // <-- UPDATE THIS IP

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        books = data.map((b) => {'_id': b['_id'], 'title': b['title'], 'author': b['author']}).toList();
      });
    }
  }

  Future<void> addBook(String title, String author) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'author': author}),
    );
    if (response.statusCode == 201) {
      await fetchBooks();
    }
  }

  Future<void> deleteBook(String id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      await fetchBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
        );
      }
    }
  }

  Future<void> confirmAndDeleteBook(String id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await deleteBook(id);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks(); // Always fetch on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.science, color: Colors.white, size: 32),
        title: const Text('My Book App', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: fetchBooks,
          ),
        ],
      ),
      backgroundColor: Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.schedule, color: Colors.teal),
                SizedBox(width: 8),
                Text('Screens:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: books.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.menu_book, size: 64, color: Colors.teal),
                          SizedBox(height: 16),
                          Text('No books found', style: TextStyle(fontSize: 20, color: Colors.teal)),
                          SizedBox(height: 8),
                          Text('Tap the + button to add your first book!', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return BookCard(
                          id: book['_id'],
                          title: book['title'],
                          author: book['author'],
                          onDelete: () => confirmAndDeleteBook(book['_id']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookPage(),
            ),
          );
          if (result != null) {
            await fetchBooks();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Book', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
    );
  }
} 