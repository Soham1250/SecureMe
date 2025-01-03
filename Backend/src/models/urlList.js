const mongoose = require('mongoose');

const urlListSchema = new mongoose.Schema({
    url: {
        type: String,
        required: true,
        unique: true
    },
    type: {
        type: String,
        required: true,
        enum: ['safe', 'mildly_unsafe', 'unsafe'],
        default: 'safe'
    },
    securityScore: {
        type: Number,
        required: true,
        min: 0,
        max: 100
    },
    reason: {
        type: String,
        required: true
    },
    engineReports: [{
        engine: String,
        category: String,
        finding: String
    }],
    addedAt: {
        type: Date,
        default: Date.now
    }
});

// Create indexes for faster lookups
urlListSchema.index({ url: 1, type: 1 });

// Explicitly set the collection name
const UrlList = mongoose.model('UrlList', urlListSchema, 'urllists');

module.exports = UrlList;
