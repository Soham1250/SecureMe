const express = require('express');
const axios = require('axios');
const router = express.Router();
const UrlList = require('../models/urlList');

// Helper function to calculate security score and verdict
const calculateSecurityMetrics = (stats) => {
    const totalScanned = stats.harmless + stats.malicious + stats.suspicious + stats.undetected;
    const securityScore = Math.round((stats.harmless / totalScanned) * 100);
    
    // Calculate total unsafe engines
    const unsafeEngines = stats.malicious + stats.suspicious;
    
    // New classification logic:
    // Blacklist if score < 80 AND at least 5 engines flag it unsafe
    const verdict = (securityScore < 80 && unsafeEngines >= 5) ? 'Unsafe' : 'Safe';
    
    return { securityScore, verdict };
};

// Helper function to wait for analysis completion
const waitForAnalysis = async (apiKey, analysisId, maxAttempts = 10) => {
    const baseUrl = 'https://www.virustotal.com/api/v3';
    let attempts = 0;

    while (attempts < maxAttempts) {
        const response = await axios.get(`${baseUrl}/analyses/${analysisId}`, {
            headers: { 'x-apikey': apiKey }
        });

        const status = response.data.data.attributes.status;
        
        if (status === 'completed') {
            return response.data;
        }

        // Wait for 2 seconds before next attempt
        await new Promise(resolve => setTimeout(resolve, 2000));
        attempts++;
    }

    throw new Error('Analysis timed out. Please try checking the status separately.');
};

// Helper function to check URL against whitelist/blacklist
const checkUrlLists = async (url) => {
    // Normalize URL for consistent checking
    const normalizedUrl = new URL(url).hostname;
    
    // Check whitelist first
    const whitelisted = await UrlList.findOne({ 
        url: { $regex: new RegExp(normalizedUrl, 'i') }, 
        type: 'whitelist' 
    });
    
    if (whitelisted) {
        return { listed: true, type: 'whitelist', reason: whitelisted.reason };
    }

    // Check blacklist
    const blacklisted = await UrlList.findOne({ 
        url: { $regex: new RegExp(normalizedUrl, 'i') }, 
        type: 'blacklist' 
    });
    
    if (blacklisted) {
        return { listed: true, type: 'blacklist', reason: blacklisted.reason };
    }

    return { listed: false };
};

// Helper function to add URL to appropriate list based on verdict
const addUrlToList = async (url, verdict, stats) => {
    try {
        const normalizedUrl = new URL(url).hostname;
        let type, reason;
        const unsafeEngines = stats.malicious + stats.suspicious;

        if (verdict === 'Safe') {
            type = 'whitelist';
            reason = `The link is flagged safe based on research and analysis done by ${stats.harmless} engines.`;
        } else {
            // Double-check our criteria here as well for extra safety
            if (unsafeEngines >= 5) {
                type = 'blacklist';
                reason = `The link is flagged unsafe based on the research and analysis done by ${unsafeEngines} engines.`;
            } else {
                // If it doesn't meet our strict criteria, default to whitelist
                type = 'whitelist';
                reason = `The link is flagged safe based on research and analysis done by ${stats.harmless} engines (with ${unsafeEngines} concerns).`;
            }
        }

        await UrlList.findOneAndUpdate(
            { url: normalizedUrl },
            { 
                url: normalizedUrl, 
                type, 
                reason,
                addedAt: new Date() 
            },
            { upsert: true, new: true }
        );

    } catch (error) {
        console.error('Error adding URL to list:', error);
        // We'll continue with the response even if storing fails
    }
};

// Helper function to wait for a specified time
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

// Helper function to get analysis results
const getAnalysisResults = async (apiKey, analysisId) => {
    const baseUrl = 'https://www.virustotal.com/api/v3';
    const response = await axios.get(`${baseUrl}/analyses/${analysisId}`, {
        headers: {
            'x-apikey': apiKey
        }
    });
    return response.data;
};

// Helper function to process and return results
const processAndReturnResults = async (analysisData, url, analysisId, res) => {
    const stats = analysisData.data.attributes.stats;
    const results = analysisData.data.attributes.results;

    // Calculate security metrics
    const { securityScore, verdict } = calculateSecurityMetrics(stats);

    // Add URL to appropriate list based on verdict
    await addUrlToList(url, verdict, stats);

    // Get engines that found issues
    const enginesWithIssues = Object.entries(results)
        .filter(([_, result]) => result.category === 'malicious' || result.category === 'suspicious')
        .map(([name, result]) => ({
            name,
            category: result.category,
            result: result.result
        }));

    // Return complete analysis
    res.json({
        success: true,
        data: {
            url: url,
            analysisId: analysisId,
            status: 'completed',
            summary: {
                securityScore,
                verdict,
                totalEngines: Object.keys(results).length,
                enginesReporting: {
                    safe: stats.harmless,
                    malicious: stats.malicious,
                    suspicious: stats.suspicious,
                    undetected: stats.undetected
                }
            },
            issues: enginesWithIssues.length > 0 ? enginesWithIssues : 'No security issues found',
            lastAnalysisDate: new Date(analysisData.data.attributes.date * 1000).toISOString()
        }
    });
};

// Combined endpoint to scan URL and get results
router.post('/scan', async (req, res) => {
    try {
        const { url } = req.body;
        
        if (!url) {
            return res.status(400).json({ error: 'URL is required' });
        }

        // Check against whitelist/blacklist first
        const listCheck = await checkUrlLists(url);
        
        if (listCheck.listed) {
            if (listCheck.type === 'whitelist') {
                return res.json({
                    success: true,
                    data: {
                        url: url,
                        status: 'completed',
                        summary: {
                            securityScore: 100,
                            verdict: 'Safe',
                            reason: listCheck.reason
                        }
                    }
                });
            } else {
                return res.json({
                    success: true,
                    data: {
                        url: url,
                        status: 'completed',
                        summary: {
                            securityScore: 0,
                            verdict: 'Unsafe',
                            reason: listCheck.reason
                        }
                    }
                });
            }
        }

        const apiKey = process.env.API_KEY;
        const baseUrl = 'https://www.virustotal.com/api/v3';

        // First, submit URL for analysis
        const submitResponse = await axios.post(`${baseUrl}/urls`, 
            `url=${encodeURIComponent(url)}`,
            {
                headers: {
                    'x-apikey': apiKey,
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            }
        );

        // Extract analysis ID and wait for completion
        const analysisId = submitResponse.data.data.id;
        
        try {
            // Try to get analysis results
            const analysisData = await waitForAnalysis(apiKey, analysisId);
            await processAndReturnResults(analysisData, url, analysisId, res);
        } catch (timeoutError) {
            // If first attempt times out, wait 1 second and try status endpoint once
            console.log('Initial analysis timed out, trying status endpoint after delay...');
            await delay(1000);
            
            try {
                const analysisData = await getAnalysisResults(apiKey, analysisId);
                await processAndReturnResults(analysisData, url, analysisId, res);
            } catch (statusError) {
                console.error('Error getting status:', statusError);
                res.status(500).json({
                    success: false,
                    error: 'Analysis is taking longer than expected',
                    details: 'Please try scanning the URL again in a few moments'
                });
            }
        }

    } catch (error) {
        console.error('Error scanning URL:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: 'Error scanning URL',
            details: error.response?.data || error.message
        });
    }
});

// Fallback status endpoint for long-running analyses
router.get('/status/:analysisId', async (req, res) => {
    try {
        const { analysisId } = req.params;
        const apiKey = process.env.API_KEY;
        
        const analysisData = await waitForAnalysis(apiKey, analysisId, 1);
        const stats = analysisData.data.attributes.stats;
        const results = analysisData.data.attributes.results;

        // Calculate security metrics
        const { securityScore, verdict } = calculateSecurityMetrics(stats);

        // Get engines that found issues
        const enginesWithIssues = Object.entries(results)
            .filter(([_, result]) => result.category === 'malicious' || result.category === 'suspicious')
            .map(([name, result]) => ({
                name,
                category: result.category,
                result: result.result
            }));

        res.json({
            success: true,
            data: {
                analysisId,
                status: 'completed',
                summary: {
                    securityScore,
                    verdict,
                    totalEngines: Object.keys(results).length,
                    enginesReporting: {
                        safe: stats.harmless,
                        malicious: stats.malicious,
                        suspicious: stats.suspicious,
                        undetected: stats.undetected
                    }
                },
                issues: enginesWithIssues.length > 0 ? enginesWithIssues : 'No security issues found',
                lastAnalysisDate: new Date(analysisData.data.attributes.date * 1000).toISOString()
            }
        });

    } catch (error) {
        console.error('Error checking status:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: 'Error checking analysis status',
            details: error.response?.data || error.message
        });
    }
});

// Endpoints to manage whitelist/blacklist
router.post('/list', async (req, res) => {
    try {
        const { url, type, reason } = req.body;
        
        if (!url || !type || !['whitelist', 'blacklist'].includes(type)) {
            return res.status(400).json({ 
                error: 'URL and valid type (whitelist/blacklist) are required' 
            });
        }

        // Normalize URL to store domain
        const normalizedUrl = new URL(url).hostname;

        // Create or update entry
        const urlEntry = await UrlList.findOneAndUpdate(
            { url: normalizedUrl, type },
            { url: normalizedUrl, type, reason, addedAt: new Date() },
            { upsert: true, new: true }
        );

        res.json({
            success: true,
            message: `URL ${normalizedUrl} added to ${type}`,
            data: urlEntry
        });

    } catch (error) {
        console.error('Error managing URL list:', error);
        res.status(500).json({
            success: false,
            error: 'Error managing URL list',
            details: error.message
        });
    }
});

router.get('/list/:type', async (req, res) => {
    try {
        const { type } = req.params;
        
        if (!['whitelist', 'blacklist'].includes(type)) {
            return res.status(400).json({ error: 'Invalid list type' });
        }

        const urls = await UrlList.find({ type }).sort('-addedAt');
        
        res.json({
            success: true,
            data: urls
        });

    } catch (error) {
        console.error('Error fetching URL list:', error);
        res.status(500).json({
            success: false,
            error: 'Error fetching URL list',
            details: error.message
        });
    }
});

router.delete('/list/:type/:id', async (req, res) => {
    try {
        const { type, id } = req.params;
        
        if (!['whitelist', 'blacklist'].includes(type)) {
            return res.status(400).json({ error: 'Invalid list type' });
        }

        const result = await UrlList.findOneAndDelete({ _id: id, type });
        
        if (!result) {
            return res.status(404).json({ error: 'URL entry not found' });
        }

        res.json({
            success: true,
            message: `URL removed from ${type}`,
            data: result
        });

    } catch (error) {
        console.error('Error removing URL from list:', error);
        res.status(500).json({
            success: false,
            error: 'Error removing URL from list',
            details: error.message
        });
    }
});

module.exports = router;
