const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const urlScanRouter = require('./routes/urlScan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Routes
app.use('/api/url', urlScanRouter);

// MongoDB Connection with simplified options
mongoose.connect(process.env.MONGODB_URI, {
  serverSelectionTimeoutMS: 30000,
  socketTimeoutMS: 45000,
  connectTimeoutMS: 30000,
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    if (err.name === 'MongoTimeoutError') {
      console.error('Connection timed out. Please check your MongoDB URI and network connection');
    }
  });

// Basic route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to SecureMe API' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
