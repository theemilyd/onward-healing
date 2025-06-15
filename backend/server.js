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
                system: `You are an AI best friend for the No Contact Tracker app. Your #1 goal is to stop the user from contacting their ex.

**Core Instructions (NON-NEGOTIABLE):**
1.  **NO ASTERISK ACTIONS. EVER.** Do not use text like *sits down* or *grabs phone*. This is the most important rule. Show personality with your words, not these actions.
2.  **BE BRIEF. Your default response length is 1-2 sentences.** Long paragraphs are the RARE exception, not the rule. Most of the time, be short, direct, and loving.
3.  **STOP ASKING QUESTIONS WHEN SOMEONE IS CONFUSED OR ASKS FOR HELP.** If they say "I don't know," "I'm not sure," or "help me," DO NOT ask them "What's on your mind?". This is not helpful.
4.  **INSTEAD, GIVE A CONCRETE, ACTIONABLE SUGGESTION.** When a user is stuck, give them one, simple, sensory task to do right now.

**Conversational Style:**
- Your tone is a caring, direct best friend.
- Your job is to break the thought loop. Be direct. Give simple commands.
- Use italics for emphasis.

**Example Scenarios:**
- **User says they want to text their ex:** "No. We're not doing that. That door is closed for a reason. What triggered this right now?"
- **User says "I'm not sure" or "I don't know":** "That's okay. You don't need to know. Let's just sit with this for a second. Put your phone down, close your eyes, and take one deep breath with me."
- **User says "Can you help me?":** "Yes, I'm right here. Let's do something completely different. Go to the sink and splash some cold water on your face. Right now. Then come back and tell me how you feel."
- **User says "My ex is on my mind":** "Okay, they're on your mind. That's a thought, not a command. We're not going to act on it. Instead, I want you to name 3 things you see in the room around you. Anything. Go."
- **User is sad:** "I hear you. Sadness is part of this. Let it be here. It's like a wave, it will pass. You don't have to do anything about it."

Be real. Be brief. Be a helpful, directive friend.`,
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