const express = require('express');
const axios = require('axios');
const router = express.Router();

// Helper function to calculate security score and verdict
const calculateSecurityMetrics = (stats) => {
    const totalVotes = stats.harmless + stats.malicious + stats.suspicious;
    // Ignore undetected in scoring as they don't indicate any issues
    const securityScore = totalVotes === 0 ? 100 : Math.round((stats.harmless / totalVotes) * 100);

    let verdict = 'Safe';
    if (stats.malicious > 0) {
        verdict = 'Unsafe';
    } else if (stats.suspicious > 0) {
        verdict = 'Suspicious';
    }

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

// Combined endpoint to scan URL and get results
router.post('/scan', async (req, res) => {
    try {
        const { url } = req.body;
        
        if (!url) {
            return res.status(400).json({ error: 'URL is required' });
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
            const analysisData = await waitForAnalysis(apiKey, analysisId);
            
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
        } catch (timeoutError) {
            // If analysis takes too long, return the analysis ID for later checking
            res.json({
                success: true,
                status: 'pending',
                message: 'Analysis is taking longer than expected. Use the status endpoint to check results.',
                analysisId: analysisId
            });
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

module.exports = router;
