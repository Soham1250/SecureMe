const mongoose = require('mongoose');

const urlListSchema = new mongoose.Schema({
    url: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    type: {
        type: String,
        enum: ['whitelist', 'blacklist'],
        required: true
    },
    addedAt: {
        type: Date,
        default: Date.now
    },
    reason: {
        type: String,
        trim: true
    }
});

// Create indexes for faster lookups
urlListSchema.index({ url: 1, type: 1 });

const UrlList = mongoose.model('UrlList', urlListSchema);

module.exports = UrlList;
