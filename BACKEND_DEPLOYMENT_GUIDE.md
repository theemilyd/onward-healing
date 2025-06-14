# Secure Backend Deployment Guide

## 🎯 **Mission: Deploy Secure Claude API Backend**

This guide will help you deploy your secure Express.js backend to protect your Claude API key and avoid App Store rejections.

---

## 🚀 **Step 1: Choose Your Deployment Platform**

### **Option A: Railway (Recommended - Easiest)**

**Why Railway?**
- ✅ Free tier available
- ✅ Automatic deployments from GitHub
- ✅ Built-in environment variable management
- ✅ Easy domain setup

**Steps:**
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your Onward repository
5. Choose the `backend` folder as root directory
6. Add environment variables:
   - `CLAUDE_API_KEY`: Your Claude API key
   - `NODE_ENV`: `production`
7. Deploy!

**Your backend URL will be:** `https://your-app-name.railway.app`

### **Option B: Heroku (Popular)**

**Steps:**
1. Install Heroku CLI
2. Login: `heroku login`
3. Create app: `heroku create onward-backend`
4. Set environment variables:
   ```bash
   heroku config:set CLAUDE_API_KEY=your_claude_api_key_here
   heroku config:set NODE_ENV=production
   ```
5. Deploy:
   ```bash
   cd backend
   git init
   git add .
   git commit -m "Initial backend deployment"
   heroku git:remote -a onward-backend
   git push heroku main
   ```

**Your backend URL will be:** `https://onward-backend.herokuapp.com`

### **Option C: DigitalOcean App Platform**

**Steps:**
1. Go to [DigitalOcean App Platform](https://cloud.digitalocean.com/apps)
2. Create new app from GitHub repo
3. Select `backend` folder
4. Add environment variables in settings
5. Deploy

---

## 🔧 **Step 2: Update iOS App for Production**

Once your backend is deployed, update your iOS app to use the production URL:

**File:** `onward/Onward/Core/NetworkClient/NetworkClient.swift`

```swift
// Replace this line:
private let apiEndpoint = URL(string: "http://localhost:3000/api/chat")

// With your production URL:
private let apiEndpoint = URL(string: "https://your-backend-domain.com/api/chat")
```

**Examples:**
- Railway: `https://onward-backend-production.railway.app/api/chat`
- Heroku: `https://onward-backend.herokuapp.com/api/chat`
- DigitalOcean: `https://your-app-name.ondigitalocean.app/api/chat`

---

## 🧪 **Step 3: Test Your Deployment**

### **Test 1: Health Check**
```bash
curl https://your-backend-domain.com/api/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0.0"
}
```

### **Test 2: Chat Endpoint**
```bash
curl -X POST https://your-backend-domain.com/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?"}'
```

**Expected Response:**
```json
{
  "message": "Hello! I'm here and ready to listen...",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### **Test 3: iOS App Integration**
1. Build and run your iOS app
2. Navigate to the AI Chat feature
3. Send a test message
4. Verify you get a response from Claude

---

## 🔒 **Step 4: Security Checklist**

### **✅ Environment Variables Secured**
- [ ] `CLAUDE_API_KEY` set in deployment platform (not in code)
- [ ] `NODE_ENV` set to `production`
- [ ] No sensitive data in GitHub repository

### **✅ CORS Configuration**
Update your backend's CORS settings for production:

**File:** `backend/server.js`
```javascript
app.use(cors({
    origin: process.env.NODE_ENV === 'production' 
        ? ['https://your-app-domain.com'] // Add your actual app domain if needed
        : ['http://localhost:3000', 'http://127.0.0.1:3000']
}));
```

### **✅ Rate Limiting Active**
- [ ] 100 requests per 15 minutes per IP
- [ ] Rate limiting headers included in responses

### **✅ Error Handling**
- [ ] No sensitive information leaked in error messages
- [ ] Proper HTTP status codes returned

---

## 📱 **Step 5: App Store Submission Preparation**

### **Update App Store Connect**
1. **App Privacy**: Update privacy policy to mention AI chat feature
2. **App Description**: Mention AI companion feature
3. **Keywords**: Add relevant keywords like "AI chat", "support"

### **Test on Physical Device**
1. Build app for physical iOS device
2. Test AI chat functionality
3. Verify backend connectivity over cellular/WiFi

### **Performance Testing**
1. Test with multiple rapid messages
2. Verify rate limiting works correctly
3. Test error scenarios (network offline, etc.)

---

## 🚨 **Avoiding App Store Rejections**

### **Common Issues & Solutions:**

**Issue:** "AI features not working after purchase"
**Solution:** ✅ Your AI chat is always free, so this won't be an issue

**Issue:** "Privacy policy missing AI data usage"
**Solution:** Update privacy policy to mention:
- AI chat messages are sent to secure backend
- Messages processed by Claude AI for responses
- No personal data stored permanently

**Issue:** "Network security concerns"
**Solution:** ✅ Your backend uses HTTPS and proper security headers

---

## 🔍 **Step 6: Monitoring & Maintenance**

### **Set Up Monitoring**
1. **Uptime Monitoring**: Use UptimeRobot or Pingdom
2. **Error Tracking**: Consider Sentry for error reporting
3. **Performance**: Monitor response times

### **Regular Maintenance**
- [ ] Monitor Claude API usage and costs
- [ ] Update dependencies monthly
- [ ] Review server logs for issues
- [ ] Monitor rate limiting effectiveness

---

## 🎉 **Success Checklist**

Before submitting to App Store:

- [ ] Backend deployed and accessible via HTTPS
- [ ] iOS app updated with production backend URL
- [ ] Health check endpoint returns 200 OK
- [ ] Chat endpoint returns proper Claude responses
- [ ] Rate limiting prevents abuse
- [ ] CORS configured for production
- [ ] Environment variables secured
- [ ] Privacy policy updated
- [ ] Physical device testing completed
- [ ] Error scenarios tested

---

## 🆘 **Troubleshooting**

### **Backend Not Responding**
1. Check deployment logs in your platform dashboard
2. Verify environment variables are set correctly
3. Test health endpoint directly

### **iOS App Can't Connect**
1. Verify backend URL is correct in NetworkClient.swift
2. Check iOS app's network permissions
3. Test on both WiFi and cellular

### **Claude API Errors**
1. Verify API key is valid and has credits
2. Check Claude API status page
3. Review backend server logs

### **Rate Limiting Issues**
1. Check if rate limits are too restrictive
2. Consider implementing user-specific rate limiting
3. Monitor rate limiting logs

---

## 📞 **Support**

If you encounter issues:
1. Check deployment platform documentation
2. Review backend server logs
3. Test each component individually
4. Verify all environment variables are set correctly

**Your secure backend is now ready for production! 🚀** 