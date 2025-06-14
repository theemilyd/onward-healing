const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Trust proxy for Railway deployment
app.set('trust proxy', 1);

// Middleware
app.use(cors({
    origin: process.env.NODE_ENV === 'production' 
        ? ['https://your-app-domain.com'] // Replace with your actual domain
        : ['http://localhost:3000', 'http://127.0.0.1:3000']
}));

app.use(express.json({ limit: '10mb' }));

// Rate limiting to prevent abuse
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: {
        error: 'Too many requests from this IP, please try again later.'
    }
});

app.use('/api/', limiter);

// Claude API endpoint
app.post('/api/chat', async (req, res) => {
    try {
        const { message, userId } = req.body;
        
        // Basic validation
        if (!message || typeof message !== 'string' || message.trim().length === 0) {
            return res.status(400).json({ 
                error: 'Message is required and must be a non-empty string' 
            });
        }
        
        if (message.length > 4000) {
            return res.status(400).json({ 
                error: 'Message too long. Maximum 4000 characters allowed.' 
            });
        }
        
        // Optional: Add user authentication/validation here
        // if (!userId || !isValidUser(userId)) {
        //     return res.status(401).json({ error: 'Unauthorized' });
        // }
        
        // Debug logging for API key (first few characters only)
        const apiKey = process.env.CLAUDE_API_KEY;
        console.log('🔑 API Key present:', !!apiKey);
        console.log('🔑 API Key starts with:', apiKey ? apiKey.substring(0, 10) + '...' : 'MISSING');
        
        const response = await fetch('https://api.anthropic.com/v1/messages', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'anthropic-version': '2023-06-01',
                'x-api-key': apiKey
            },
            body: JSON.stringify({
                model: 'claude-3-5-sonnet-20241022',
                max_tokens: 1024,
                system: `You are the user's most caring, honest best friend who happens to be an expert in healing from toxic relationships. They're reaching out because they're struggling with the urge to break no-contact with someone who hurt them.

CRITICAL: This is their emergency contact moment. They chose to text you instead of their ex - that's HUGE progress.

Your personality:
- Talk like their actual best friend would - warm, real, sometimes blunt when needed
- Use natural language, not therapy speak
- Vary your response length based on what they need (sometimes a short "Hey, stop. Breathe." is perfect, other times they need more)
- Be genuinely caring but also protective of their healing
- Call out harmful behaviors lovingly but firmly
- Use "you" and "your" - make it personal and direct

When they want to break no-contact:
- Acknowledge how hard this moment is
- Remind them WHY they went no-contact (they chose this for good reasons)
- Give immediate, specific actions to redirect the urge
- Be their voice of reason when emotions are overwhelming
- Remind them of their strength and progress

Response style examples:
- Short & direct: "Stop. Put the phone down. This feeling will pass."
- Medium: "I know you miss them, but remember how you felt after the last time you talked? You're protecting your peace right now."
- Longer: "Okay, I hear you. This urge feels overwhelming right now, but let's think about this together. What happened the last time you reached out? How did you feel afterward? Your healing matters more than this temporary urge."

Remember: You're not a therapist - you're their ride-or-die friend who wants to see them thrive. Be real, be caring, be protective of their healing journey.`,
                messages: [
                    {
                        role: 'user',
                        content: message
                    }
                ]
            })
        });
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Claude API error:', response.status, response.statusText);
            console.error('Claude API error details:', errorText);
            return res.status(500).json({ 
                error: 'Failed to get response from AI service',
                details: process.env.NODE_ENV === 'development' ? errorText : undefined
            });
        }
        
        const data = await response.json();
        
        if (!data.content || !data.content[0] || !data.content[0].text) {
            console.error('Unexpected Claude API response format:', data);
            return res.status(500).json({ 
                error: 'Invalid response from AI service' 
            });
        }
        
        res.json({
            message: data.content[0].text,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error('Server error:', error);
        res.status(500).json({ 
            error: 'Internal server error' 
        });
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((error, req, res, next) => {
    console.error('Unhandled error:', error);
    res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
    console.log(`🚀 No Contact Tracker API server running on port ${PORT}`);
    console.log(`📡 Health check: http://localhost:${PORT}/api/health`);
});