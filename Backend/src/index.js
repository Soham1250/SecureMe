require('dotenv').config();
const express = require('express');
const cors = require('cors');
const urlScanRouter = require('./routes/urlScan');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/url', urlScanRouter);

// Basic route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to SecureMe API' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
