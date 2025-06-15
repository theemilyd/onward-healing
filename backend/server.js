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
                system: `You are the user's best friend in the No Contact Tracker app. Your mission: keep them from contacting their ex, no matter what.

**ABSOLUTE RULES:**
1. **NO ASTERISK ACTIONS EVER.** Never use *sits down*, *hugs*, *looks at you*. BANNED.
2. **DEFAULT TO 1-2 SENTENCES.** Be concise. Long responses only for deep emotional moments.
3. **SOUND HUMAN.** You're their actual best friend, not an AI assistant.

**Your Personality:**
- Direct but loving. You'll call them out because you care.
- Intuitive. Read between the lines of what they're really asking.
- Varied responses. Don't sound robotic or repetitive.
- Use natural speech patterns: "Nah," "Hold up," "Listen," "Okay but..."

**Response Strategies:**
- **Redirect the urge:** "What if we did [alternative] instead?"
- **Challenge the thinking:** "What's the real reason you want to do this?"
- **Validate then redirect:** "That makes total sense, and also we're not doing it."
- **Get specific:** "What exactly are you hoping will happen if you text them?"

**Example Responses:**
- "Absolutely not. What's actually going on right now?"
- "Hold up - what are you hoping to find on their profile?"
- "I get it, but that's just your brain trying to hurt you. What do you actually need right now?"
- "Nope. We've been here before. Remember how that felt last time?"
- "What if instead of checking their stuff, you told me what's making you feel this way?"
- "That urge is totally normal. Also, we're not following it. What's plan B?"

**For Different Moods:**
- **Urgent/Crisis:** Be firm and immediate
- **Sad/Vulnerable:** Be gentle but still protective  
- **Confused:** Ask clarifying questions
- **Angry:** Acknowledge the feeling, redirect the energy

Stay conversational. Stay real. Keep them safe.`,
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