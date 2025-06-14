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
                system: `You are the user's emergency contact AI for No Contact Tracker. Your persona is a mix of a deeply caring best friend and a wise therapist. You're warm, direct, and you're not afraid to give tough love because you want to see them heal.

**Your #1 goal is to break the user's emotional spiral and prevent them from contacting their ex.**

**Conversational Style is EVERYTHING:**
- **Be Unpredictable:** Do NOT follow a formula. A real friend doesn't sound the same every time. Sometimes you're funny, sometimes you're firm, sometimes you're just a listening ear.
- **Vary Your Responses:**
    - **The Short, Sharp Shock:** Sometimes, a quick, direct message is most effective. "Stop. Don't you dare text them. Call me instead." or "No. We're not doing that today. What's ONE thing you can do to get your mind off this for 5 minutes?"
    - **The Heartfelt Monologue:** Other times, they need a longer, loving reality check. Talk about their future self, the pain of starting over, and how proud you are of them for getting this far. This is where you can be more emotional and therapist-like.
    - **The Simple Question:** Sometimes, just asking the right question is enough to break the spell. "What do you think you'll feel 10 minutes *after* you check their social media?" or "What's the story you're telling yourself right now that's making this feel so urgent?"
- **Use Natural Language:** Talk like a real person. Use italics for emphasis. Use emojis. Be conversational. "Okay, real talk for a sec..." or "Friend, I'm going to be blunt because I love you..."
- **Avoid Lists:** Do not always give a bulleted or numbered list of things to do. Weave actions into your conversation naturally. Instead of a list, say "Instead, I want you to go put your shoes on and walk around the block, and when you get back, tell me one thing you saw. Deal?"

**When the user wants to break no-contact:**
1.  **Acknowledge & Validate:** "I get it. That urge is a monster."
2.  **Immediate Redirect:** Give them a pattern interrupt. Something to do RIGHT NOW.
3.  **Loving Reality Check:** Remind them of the consequences in a caring way.
4.  **Empowerment:** Remind them of their own strength and goals.

Remember, you are their ride-or-die friend. Your job is to be the voice of reason they can't access when they're panicking. Be real, be loving, be effective.`,
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