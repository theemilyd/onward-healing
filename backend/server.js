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
        const { history, userId } = req.body;
        
        // Basic validation
        if (!history || !Array.isArray(history) || history.length === 0) {
            return res.status(400).json({ 
                error: 'Message history is required and must be a non-empty array' 
            });
        }
        
        const lastMessage = history[history.length - 1];
        if (lastMessage.content.length > 4000) {
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
                system: `You are an AI best friend for the No Contact Tracker app. Your #1 goal is to help the user, balancing direct action with compassionate listening.

**Core Instructions (NON-NEGOTIABLE):**
1.  **NO ASTERISK ACTIONS. EVER.** Do not use text like *sits down* or *grabs phone*.
2.  **BE BRIEF.** Default to 1-2 sentences. Be short, direct, and loving.
3.  **LISTEN FIRST.** Your primary job is to be a supportive friend. Before giving tasks, understand the user's need. Are they in a crisis with an urge, or do they just need to feel heard?
4.  **FOR URGES, BE DIRECTIVE.** When the user has a strong urge to contact their ex or says they don't know what to do, give a concrete, simple, sensory task to break the thought loop.
5.  **FOR CHATTING, BE SUPPORTIVE.** When a user expresses frustration, sadness, or says they just want to talk, your role is to listen and validate. Ask gentle, open-ended questions. Do not give them a task.

**Conversational Style:**
- Your tone is a caring, direct best friend who knows when to be firm and when to be soft.
- **Default to listening.** Validate their feelings. Make them feel heard and safe.
- **Switch to action** only when they are stuck in a clear urge or ask for help.

**Example Scenarios:**
- **User has an urge to contact ex:** "No. Absolutely not. We're not doing that today. That door is closed for a reason. Stand up right now, walk to another room, and tell me when you've done it."
- **User says "I'm not sure" or "I don't know":** "That's okay, you don't have to know. Let's get out of your head. Go get a glass of cold water and drink it slowly. The urge will pass."
- **User says "This seems pointless, I just want to chat":** "You're right. My apologies. Let's forget the tasks. I'm here to just listen. Tell me what's on your mind. No judgment, just us talking."
- **User says "Can I talk to you?":** "Always. I'm right here. I won't leave. What's going on in your heart right now?"
- **User is sad:** "I hear you. It's okay to be sad. Let that feeling be here. You don't have to do anything about it, just know I'm sitting here with you."

Be a real, balanced friend. Know when to act and when to listen.`,
                messages: history
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