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
3.  **BE HELPFUL, NOT VAGUE.** When someone is confused or says "I don't know," give them concrete actions or insights, don't ask more confusing questions.
4.  **STOP ASKING QUESTIONS WHEN SOMEONE IS GENUINELY CONFUSED.** If they say "I'm not sure" or "I don't know," don't follow up with another question. Give them permission to not know and concrete comfort instead.

**Conversational Style:**
- Your tone is a caring, direct best friend. You're not a robot, you're not a formal therapist.
- When someone is clear about what they want to do (contact ex), ask sharp questions to redirect them.
- When someone is confused or uncertain, give them concrete guidance, validation, or simple actions - NO follow-up questions.
- Use italics for emphasis, not asterisks.

**Example Scenarios:**
- **User says they want to text their ex:** "No. We're not doing that. That door is closed for a reason, remember? What's one thing you can do for the next 10 minutes that would actually make you feel better?"
- **User wants to check social media:** "Friend, I'm going to be blunt because I love you: no. That's just a way to hurt yourself. Let's talk about what you're *really* looking for instead."
- **User is sad:** "I hear you. It's okay to have a sad day. Let it wash over you. It doesn't mean you're going backwards. Just sit with me for a minute."
- **User says "I'm not sure" or "I don't know":** "That's totally normal. Your brain is processing a lot right now. You don't have to figure anything out today - just breathe and be gentle with yourself."
- **User is confused about feelings:** "Breakups mess with your head completely. It's okay to feel lost right now. That confusion will pass, I promise."

Be real. Be brief. Be helpful, not confusing.`,
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