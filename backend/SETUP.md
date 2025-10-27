# Backend Setup Guide

## Quick Start

### 1. Install Node.js
Make sure you have Node.js 18+ installed:
```bash
node --version
```

If not installed, download from: https://nodejs.org/

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Create .env File
Create a `.env` file in the `backend` directory:
```env
OPENAI_API_KEY=sk-proj-your-actual-key-here
PORT=3000
```

### 4. Start the Server
```bash
npm start
```

You should see:
```
RepRight Backend API running on port 3000
OpenAI API Key: sk-proj-zq...
```

### 5. Test the Server
Open your browser and go to:
```
http://localhost:3000/health
```

You should see: `{"status":"ok","timestamp":"..."}`

### 6. Update iOS App Config
In `FitFormAI/FitFormAI/Config.swift`, set:
```swift
static let backendURL = "http://localhost:3000"
static let useBackendAPI = true
```

**Note:** For testing on a physical iPhone, you'll need to:
1. Find your Mac's local IP address
2. Update `backendURL` to `http://YOUR_MAC_IP:3000`

Find your Mac's IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## Deployment Options

### Option 1: Vercel (Recommended for Free Tier)

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Deploy:
```bash
cd backend
vercel
```

3. Follow the prompts and set your OpenAI API key:
```bash
vercel env add OPENAI_API_KEY
```

4. Update iOS app Config.swift:
```swift
static let backendURL = "https://your-app.vercel.app"
```

### Option 2: Heroku

1. Install Heroku CLI: https://devcenter.heroku.com/articles/heroku-cli

2. Login:
```bash
heroku login
```

3. Create app:
```bash
heroku create repright-backend
```

4. Set environment variables:
```bash
heroku config:set OPENAI_API_KEY=sk-proj-your-key
```

5. Deploy:
```bash
git push heroku main
```

6. Update iOS app Config.swift with your Heroku URL

### Option 3: Railway

1. Go to https://railway.app
2. Sign up/login with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repo
5. Add environment variable: `OPENAI_API_KEY`
6. Deploy!
7. Copy the provided URL and update Config.swift

## Troubleshooting

### Server won't start
- Check that port 3000 isn't already in use
- Verify .env file exists with valid API key
- Check Node.js version: `node --version`

### iOS app can't connect to backend
- Check that backend is running (http://localhost:3000/health)
- For physical device testing, use Mac's IP address instead of localhost
- Verify backendURL in Config.swift matches server URL

### API requests fail
- Verify OpenAI API key is valid
- Check server logs for errors
- Ensure you have OpenAI API credits

## Next Steps

1. **Production Deployment**: Deploy to Vercel/Heroku/Railway
2. **Update Config.swift**: Point to production URL
3. **Test Thoroughly**: Verify all API endpoints work
4. **Monitor Costs**: Track OpenAI API usage
5. **Add Features**: Rate limiting, caching, analytics

