# RepRight Backend API

This is a Node.js backend server that acts as a proxy between the RepRight iOS app and OpenAI's API.

## Why This Exists

- **Security**: OpenAI API keys never leave the server
- **Cost Control**: You can implement rate limiting and monitor usage
- **Monetization**: Easy to add subscription checks, usage limits, etc.
- **Scalability**: Can add caching, analytics, user management

## Setup Instructions

### 1. Prerequisites
- Node.js 18+ installed
- OpenAI API key

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Configure Environment
Create a `.env` file in the `backend` directory:
```env
OPENAI_API_KEY=sk-proj-your-key-here
PORT=3000
```

### 4. Start the Server
```bash
npm start
```

The server will run on `http://localhost:3000`

### 5. Deploy to Production

**Recommended hosting services:**
- **Vercel** (free tier): Easiest deployment, serverless
- **Heroku**: Simple deployment with free tier
- **Railway**: Modern alternative to Heroku
- **DigitalOcean**: More control, ~$5/month
- **AWS/GCP**: Enterprise-grade

Update the `BACKEND_URL` in the iOS app after deployment.

## API Endpoints

All endpoints accept JSON and return JSON.

### POST `/api/generate-workout-plan`
Generates a workout plan based on user profile.

**Request:**
```json
{
  "profile": {
    "name": "John Doe",
    "age": 25,
    "fitnessLevel": "Intermediate",
    "goals": ["Muscle Gain", "Build Strength"],
    "restrictions": [],
    "preferredWorkoutTypes": ["Weightlifting"],
    "availableEquipment": ["Dumbbells", "Barbell"],
    "workoutFrequency": "4 days/week"
  },
  "userNotes": "Focus on upper body"
}
```

**Response:**
```json
{
  "success": true,
  "data": { /* WorkoutPlan object */ }
}
```

### POST `/api/customize-workout-plan`
Customizes an existing workout plan.

**Request:**
```json
{
  "currentPlan": { /* WorkoutPlan object */ },
  "request": "I don't like pull-ups. Replace with other back exercises."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "isHarmful": false,
    "warningMessage": null,
    "modifiedPlan": { /* WorkoutPlan object */ },
    "explanation": "..."
  }
}
```

### POST `/api/get-camera-position`
Gets optimal camera position for an exercise.

**Request:**
```json
{
  "exerciseName": "Squat"
}
```

### POST `/api/generate-camera-image`
Generates a diagram showing camera setup.

**Request:**
```json
{
  "position": { /* CameraPosition object */ },
  "exerciseName": "Squat"
}
```

### POST `/api/analyze-form`
Analyzes exercise form from video frames.

**Request:**
```json
{
  "frames": ["base64_image_1", "base64_image_2", ...],
  "exerciseName": "Squat",
  "cameraPosition": { /* CameraPosition object */ }
}
```

## Future Enhancements

- [ ] Rate limiting (max requests per day)
- [ ] User authentication
- [ ] Usage analytics
- [ ] Caching popular requests
- [ ] Subscription checks
- [ ] Error logging with Sentry
- [ ] API versioning

## Costs

OpenAI API costs:
- GPT-4o: ~$0.005 per request (workout generation)
- GPT-4 Vision: ~$0.01 per analysis (form check)
- DALL-E 3: ~$0.04 per image (camera diagrams)

**Estimated monthly cost for 1000 active users:**
- Workout generation: ~$500
- Form analysis: ~$200
- Camera diagrams: ~$100
- **Total: ~$800/month**

Plan to monetize with subscriptions to cover costs.

