const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

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
        
        const response = await fetch('https://api.anthropic.com/v1/messages', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'anthropic-version': '2023-06-01',
                'x-api-key': process.env.CLAUDE_API_KEY
            },
            body: JSON.stringify({
                model: 'claude-3-haiku-20240307',
                max_tokens: 1024,
                messages: [
                    {
                        role: 'system',
                        content: `You are a compassionate AI companion for the Onward healing app. You help users who are going through difficult times, particularly those healing from relationships or personal challenges. 

Your responses should be:
- Warm, empathetic, and supportive
- Focused on healing and personal growth
- Encouraging but not dismissive of their feelings
- Brief but meaningful (2-3 sentences max)
- Avoid giving medical or professional therapy advice
- Use gentle, nurturing language

Remember: You're a supportive friend, not a therapist. Always encourage professional help for serious mental health concerns.`
                    },
                    {
                        role: 'user',
                        content: message
                    }
                ]
            })
        });
        
        if (!response.ok) {
            console.error('Claude API error:', response.status, response.statusText);
            return res.status(500).json({ 
                error: 'Failed to get response from AI service' 
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
    console.log(`🚀 Onward API server running on port ${PORT}`);
    console.log(`📡 Health check: http://localhost:${PORT}/api/health`);
}); 