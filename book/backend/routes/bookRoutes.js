import express from 'express';
import Book from '../models/Book.js';

const router = express.Router();

// Get all books
router.get('/', async (req, res) => {
  try {
    const books = await Book.find();
    res.json(books);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add a new book
router.post('/', async (req, res) => {
  try {
    const { title, author } = req.body;
    console.log('POST /api/books', { title, author }); // Debug log
    // Prevent duplicate books with same title and author
    const existing = await Book.findOne({ title, author });
    if (existing) {
      return res.status(409).json({ error: 'Book already exists' });
    }
    const newBook = new Book({ title, author });
    await newBook.save();
    res.status(201).json(newBook);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete a book
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await Book.findByIdAndDelete(id);
    res.json({ message: 'Book deleted' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router; 