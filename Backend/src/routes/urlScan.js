const express = require('express');
const axios = require('axios');
const router = express.Router();
const UrlList = require('../models/urlList');

// Helper function to calculate security metrics
const calculateSecurityMetrics = (stats) => {
    const totalEngines = stats.harmless + stats.malicious + stats.suspicious + stats.undetected;
    const unsafeEngines = stats.malicious + stats.suspicious;
    
    // Calculate base score (100 - percentage of unsafe engines)
    const baseScore = 100 - ((unsafeEngines / totalEngines) * 100);
    
    // Determine verdict and adjust score based on number of unsafe engines
    let verdict, securityScore;
    
    if (unsafeEngines === 0) {
        verdict = 'safe';
        securityScore = Math.max(90, baseScore); // Minimum 90 for safe URLs
    } else if (unsafeEngines <= 5) {
        verdict = 'mildly_unsafe';
        securityScore = Math.min(89, Math.max(80, baseScore)); // Between 80-89
    } else {
        verdict = 'unsafe';
        securityScore = Math.min(69, baseScore); // Maximum 69 for unsafe URLs
    }

    return { 
        securityScore: Math.round(securityScore), 
        verdict,
        unsafeEngineCount: unsafeEngines
    };
};

// Helper function to format stored engine reports
const formatEngineReports = (reports) => {
    if (!reports || !Array.isArray(reports) || reports.length === 0) {
        return 'No security issues found';
    }
    return reports;
};

// Helper function to wait for analysis completion
const waitForAnalysis = async (apiKey, analysisId) => {
    const baseUrl = 'https://www.virustotal.com/api/v3';
    const maxAttempts = 10;
    let attempts = 0;

    while (attempts < maxAttempts) {
        try {
            // First get the analysis status
            const analysisResponse = await axios.get(`${baseUrl}/analyses/${analysisId}`, {
                headers: {
                    'x-apikey': apiKey
                }
            });

            console.log('Analysis Response:', JSON.stringify(analysisResponse.data, null, 2));

            const status = analysisResponse.data.data.attributes.status;
            
            if (status === 'completed') {
                // Get the URL ID from the analysis
                const urlId = analysisResponse.data.meta?.url_info?.id;
                
                if (!urlId) {
                    console.log('No URL ID found in analysis response, using analysis results');
                    return analysisResponse.data;
                }

                // Get detailed URL report
                const urlReport = await axios.get(`${baseUrl}/urls/${urlId}`, {
                    headers: {
                        'x-apikey': apiKey
                    }
                });
                
                console.log('URL Report:', JSON.stringify(urlReport.data, null, 2));
                return urlReport.data;
            }

            attempts++;
            await new Promise(resolve => setTimeout(resolve, 2000));
        } catch (error) {
            console.error('Error in waitForAnalysis:', error.response?.data || error);
            attempts++;
            await new Promise(resolve => setTimeout(resolve, 2000));
        }
    }

    throw new Error('Analysis timed out or failed');
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

        if (verdict === 'safe') {
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
    try {
        // Log the raw data we're working with
        console.log('Processing Analysis Data:', JSON.stringify(analysisData, null, 2));

        // Get the last analysis results
        const lastAnalysisResults = analysisData.data.attributes.last_analysis_results;
        const lastAnalysisStats = analysisData.data.attributes.last_analysis_stats;

        if (!lastAnalysisResults) {
            console.error('No analysis results found in response');
            throw new Error('Invalid analysis data received');
        }

        // Calculate security metrics
        const { securityScore, verdict, unsafeEngineCount } = calculateSecurityMetrics(lastAnalysisStats);

        // Get engines that found issues
        const enginesWithIssues = [];
        
        // Process each result
        for (const [engineName, engineResult] of Object.entries(lastAnalysisResults)) {
            // Log each engine result for debugging
            console.log('Processing engine result:', { engineName, engineResult });

            if (engineResult.category === 'malicious' || engineResult.category === 'suspicious') {
                const finding = {
                    engine: engineName,
                    category: engineResult.category,
                    finding: engineResult.result || engineResult.method || 'suspicious activity'
                };
                console.log('Adding engine finding:', finding);
                enginesWithIssues.push(finding);
            }
        }

        // Generate reason based on verdict
        let reason;
        if (verdict === 'safe') {
            reason = 'The URL is safe based on analysis from all security engines.';
        } else if (verdict === 'mildly_unsafe') {
            reason = `The URL has been flagged by ${unsafeEngineCount} security engines as potentially unsafe.`;
        } else {
            reason = `The URL has been flagged by ${unsafeEngineCount} security engines as unsafe.`;
        }

        // Store URL with new classification
        const storedUrl = await UrlList.findOneAndUpdate(
            { url: url },
            {
                $set: {
                    url,
                    type: verdict,
                    securityScore,
                    reason,
                    engineReports: enginesWithIssues,
                    addedAt: new Date()
                }
            },
            { upsert: true, new: true }
        );

        // Return complete analysis
        const response = {
            success: true,
            data: {
                url: url,
                analysisId: analysisId,
                status: 'completed',
                summary: {
                    securityScore,
                    verdict,
                    totalEngines: Object.keys(lastAnalysisResults).length,
                    unsafeEngineCount,
                    enginesReporting: {
                        safe: lastAnalysisStats.harmless,
                        malicious: lastAnalysisStats.malicious,
                        suspicious: lastAnalysisStats.suspicious,
                        undetected: lastAnalysisStats.undetected
                    },
                    reason
                },
                issues: enginesWithIssues
            }
        };

        console.log('Final Response:', JSON.stringify(response, null, 2));
        res.json(response);
    } catch (error) {
        console.error('Error processing results:', error);
        res.status(500).json({
            success: false,
            error: 'Error processing scan results',
            details: error.message
        });
    }
};

// Combined endpoint to scan URL and get results
router.post('/scan', async (req, res) => {
    try {
        const { url } = req.body;
        const apiKey = process.env.VIRUSTOTAL_API_KEY;

        if (!url) {
            return res.status(400).json({ success: false, error: 'URL is required' });
        }

        // First, submit URL for scanning
        const scanResponse = await axios.post('https://www.virustotal.com/api/v3/urls', 
            new URLSearchParams({ url }).toString(),
            { 
                headers: { 
                    'x-apikey': apiKey,
                    'Content-Type': 'application/x-www-form-urlencoded'
                } 
            }
        );

        console.log('Scan Response:', JSON.stringify(scanResponse.data, null, 2));

        // Get analysis ID from the response
        const analysisId = scanResponse.data.data.id;

        // Wait for analysis to complete and get results
        const analysisData = await waitForAnalysis(apiKey, analysisId);
        console.log('Analysis data:', JSON.stringify(analysisData, null, 2));

        // Process and return results
        await processAndReturnResults(analysisData, url, analysisId, res);

    } catch (error) {
        console.error('Error scanning URL:', error.response?.data || error);
        res.status(500).json({
            success: false,
            error: 'Error scanning URL',
            details: error.response?.data?.error?.message || error.message
        });
    }
});

// Fallback status endpoint for long-running analyses
router.get('/status/:analysisId', async (req, res) => {
    try {
        const { analysisId } = req.params;
        const apiKey = process.env.VIRUSTOTAL_API_KEY;
        
        const analysisData = await waitForAnalysis(apiKey, analysisId, 1);
        const stats = analysisData.data.attributes.stats;
        const results = analysisData.data.attributes.results;

        // Calculate security metrics
        const { securityScore, verdict, unsafeEngineCount } = calculateSecurityMetrics(stats);

        // Get engines that found issues
        const enginesWithIssues = [];
        
        // Process each result
        for (const [engineName, engineResult] of Object.entries(results)) {
            if (engineResult.category === 'malicious' || engineResult.category === 'suspicious') {
                enginesWithIssues.push({
                    engine: engineName,
                    category: engineResult.category,
                    finding: engineResult.result || 'suspicious activity'
                });
            }
        }

        // Generate reason based on verdict
        let reason;
        if (verdict === 'safe') {
            reason = 'The URL is safe based on analysis from all security engines.';
        } else if (verdict === 'mildly_unsafe') {
            reason = `The URL has been flagged by ${unsafeEngineCount} security engines as potentially unsafe.`;
        } else {
            reason = `The URL has been flagged by ${unsafeEngineCount} security engines as unsafe.`;
        }

        res.json({
            success: true,
            data: {
                analysisId,
                status: 'completed',
                summary: {
                    securityScore,
                    verdict,
                    totalEngines: Object.keys(results).length,
                    unsafeEngineCount,
                    enginesReporting: {
                        safe: stats.harmless,
                        malicious: stats.malicious,
                        suspicious: stats.suspicious,
                        undetected: stats.undetected
                    },
                    reason
                },
                issues: enginesWithIssues.length > 0 ? enginesWithIssues : 'No security issues found'
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
