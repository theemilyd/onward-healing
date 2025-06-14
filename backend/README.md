# Onward Backend API

Secure Express.js backend for the Onward healing app that handles Claude AI chat requests while keeping API keys safe.

## 🔐 Security Features

- **API Key Protection**: Claude API key stored securely on server, never exposed to client
- **Rate Limiting**: Prevents abuse with 100 requests per 15 minutes per IP
- **CORS Protection**: Configurable allowed origins
- **Input Validation**: Message length and type validation
- **Error Handling**: Comprehensive error responses without exposing internals

## 🚀 Quick Setup

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Environment Setup
```bash
# Copy the example environment file
cp env.example .env

# Edit .env and add your Claude API key
nano .env
```

Add your Claude API key to `.env`:
```
CLAUDE_API_KEY=your_actual_claude_api_key_here
PORT=3000
NODE_ENV=development
```

### 3. Get Your Claude API Key
1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Sign up/login to your account
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key to your `.env` file

### 4. Start the Server
```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3000`

## 📡 API Endpoints

### POST `/api/chat`
Send a message to Claude AI through the secure backend.

**Request Body:**
```json
{
  "message": "I'm feeling anxious today",
  "userId": "optional-user-id"
}
```

**Response:**
```json
{
  "message": "I hear that anxiety in your words, and I want you to know it's completely valid...",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Error Response:**
```json
{
  "error": "Message is required and must be a non-empty string"
}
```

### GET `/api/health`
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0.0"
}
```

## 🛡️ Rate Limiting

- **Limit**: 100 requests per 15 minutes per IP address
- **Response**: 429 status code when limit exceeded
- **Headers**: Rate limit info included in response headers

## 🌐 CORS Configuration

**Development**: Allows `localhost:3000` and `127.0.0.1:3000`
**Production**: Configure `ALLOWED_ORIGINS` in environment variables

## 📱 iOS App Integration

The iOS app's `NetworkClient.swift` has been updated to call this secure backend instead of Claude directly:

```swift
// Before (INSECURE)
private let apiEndpoint = URL(string: "https://api.anthropic.com/v1/messages")
private let apiKey = "YOUR_CLAUDE_API_KEY" // ❌ Exposed in app

// After (SECURE)
private let apiEndpoint = URL(string: "http://localhost:3000/api/chat")
// ✅ No API key in iOS app - handled securely by backend
```

## 🚀 Deployment Options

### Option 1: Railway (Recommended)
1. Connect your GitHub repo to Railway
2. Add environment variables in Railway dashboard
3. Deploy automatically

### Option 2: Heroku
1. Create Heroku app
2. Set environment variables: `heroku config:set CLAUDE_API_KEY=your_key`
3. Deploy: `git push heroku main`

### Option 3: DigitalOcean App Platform
1. Create new app from GitHub repo
2. Configure environment variables
3. Deploy

### Option 4: AWS/Google Cloud
1. Use container services (ECS, Cloud Run)
2. Configure environment variables
3. Deploy with CI/CD

## 🔧 Production Configuration

Update your iOS app's `NetworkClient.swift` for production:

```swift
// Change this line for production deployment
private let apiEndpoint = URL(string: "https://your-backend-domain.com/api/chat")
```

## 📊 Monitoring

Add these optional monitoring services:
- **Error Tracking**: Sentry, Bugsnag
- **Performance**: New Relic, DataDog
- **Uptime**: Pingdom, UptimeRobot

## 🔒 Security Best Practices

✅ **Implemented:**
- API key stored server-side only
- Rate limiting to prevent abuse
- Input validation and sanitization
- CORS protection
- Error handling without information leakage

🔄 **Future Enhancements:**
- User authentication with JWT tokens
- Request logging and analytics
- Database integration for chat history
- WebSocket support for real-time chat

## 🐛 Troubleshooting

**Server won't start:**
- Check if port 3000 is available: `lsof -i :3000`
- Verify `.env` file exists and has correct format

**iOS app can't connect:**
- Ensure backend server is running
- Check iOS simulator can reach `localhost:3000`
- Verify CORS settings allow your app's origin

**Claude API errors:**
- Verify API key is correct in `.env`
- Check Claude API quota and billing
- Review server logs for detailed error messages

## 📝 Logs

Server logs include:
- Request/response details
- Error messages
- Rate limiting events
- Claude API response status

Monitor logs with:
```bash
# Development
npm run dev

# Production (with PM2)
pm2 logs onward-backend
``` 