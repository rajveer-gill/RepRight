const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Allow large payloads for images

// OpenAI configuration
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const OPENAI_BASE_URL = 'https://api.openai.com/v1';

// Validate API key on startup
if (!OPENAI_API_KEY) {
  console.error('ERROR: OPENAI_API_KEY not found in .env file');
  process.exit(1);
}

// Helper function to make OpenAI API requests
async function makeOpenAIRequest(endpoint, body) {
  try {
    const response = await axios.post(
      `${OPENAI_BASE_URL}${endpoint}`,
      body,
      {
        headers: {
          'Authorization': `Bearer ${OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    return response.data;
  } catch (error) {
    console.error('OpenAI API Error:', error.response?.data || error.message);
    throw error;
  }
}

// POST /api/generate-workout-plan
app.post('/api/generate-workout-plan', async (req, res) => {
  try {
    const { profile, userNotes } = req.body;

    // Build the prompt (simplified version of the iOS prompt)
    const prompt = buildWorkoutPlanPrompt(profile, userNotes);

    const requestBody = {
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are an expert fitness trainer and exercise physiologist. Create personalized, safe, and effective workout plans based on user profiles. Always respond in valid JSON format.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      response_format: { type: 'json_object' }
    };

    const response = await makeOpenAIRequest('/chat/completions', requestBody);
    
    res.json({
      success: true,
      data: response
    });
  } catch (error) {
    console.error('Error generating workout plan:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to generate workout plan'
    });
  }
});

// POST /api/customize-workout-plan
app.post('/api/customize-workout-plan', async (req, res) => {
  try {
    const { currentPlan, request } = req.body;

    // Build customization prompt (simplified version)
    const prompt = buildCustomizationPrompt(currentPlan, request);

    const requestBody = {
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are an expert fitness trainer and exercise physiologist. When users request workout plan changes, you must evaluate if the change is harmful to their development. If harmful, provide a clear warning and explanation. If safe, create a modified plan. Always respond in valid JSON format.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      response_format: { type: 'json_object' }
    };

    const response = await makeOpenAIRequest('/chat/completions', requestBody);
    
    res.json({
      success: true,
      data: response
    });
  } catch (error) {
    console.error('Error customizing workout plan:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to customize workout plan'
    });
  }
});

// POST /api/get-camera-position
app.post('/api/get-camera-position', async (req, res) => {
  try {
    const { exerciseName } = req.body;

    const prompt = `For the exercise "${exerciseName}", determine the OPTIMAL camera position for form analysis.

Consider:
- Which angle shows the most critical form elements
- What distance and height provides the clearest view
- How to frame the entire movement

Respond in JSON format with:
{
    "angle": "Front View" | "Side View" | "Back View" | "45° Diagonal" | "Overhead View",
    "distance": "distance description",
    "height": "height description",
    "instructions": "clear, step-by-step setup instructions",
    "visualGuidePrompt": "a detailed prompt for generating an illustration showing camera placement"
}`;

    const requestBody = {
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are an expert in exercise biomechanics and video analysis. Provide precise camera positioning guidance for optimal form assessment.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.5,
      response_format: { type: 'json_object' }
    };

    const response = await makeOpenAIRequest('/chat/completions', requestBody);
    
    res.json({
      success: true,
      data: response
    });
  } catch (error) {
    console.error('Error getting camera position:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to get camera position'
    });
  }
});

// POST /api/generate-camera-image
app.post('/api/generate-camera-image', async (req, res) => {
  try {
    const { position, exerciseName } = req.body;

    const enhancedPrompt = `Create a clean, professional diagram showing camera setup for filming the exercise "${exerciseName}".

Style: Minimalist technical illustration with:
- A simple stick figure or silhouette performing the exercise
- A camera icon positioned at: ${position.angle}, ${position.height}, ${position.distance}
- Dotted lines showing the camera's field of view
- Clear labels and measurements
- Modern, professional design with a white or light gradient background
- Blue and black color scheme

The illustration should clearly show: ${position.instructions}`;

    const requestBody = {
      model: 'dall-e-3',
      prompt: enhancedPrompt,
      n: 1,
      size: '1024x1024',
      quality: 'standard',
      style: 'natural'
    };

    const response = await makeOpenAIRequest('/images/generations', requestBody);
    
    res.json({
      success: true,
      data: response
    });
  } catch (error) {
    console.error('Error generating camera image:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to generate camera image'
    });
  }
});

// POST /api/analyze-form
app.post('/api/analyze-form', async (req, res) => {
  try {
    const { frames, exerciseName, cameraPosition } = req.body;

    const prompt = `Analyze this exercise form for: ${exerciseName}
Camera Position: ${cameraPosition.angle} at ${cameraPosition.height}, ${cameraPosition.distance}

Provide a detailed form analysis including:
1. Overall score (0-100)
2. General analysis summary
3. What they're doing well (strengths)
4. What needs improvement
5. Specific feedback for key aspects (back position, knee alignment, hip hinge, etc.)

Be encouraging but honest. Prioritize safety and injury prevention.

Respond in JSON format:
{
    "overallScore": number,
    "analysis": "string",
    "strengths": ["array of strings"],
    "improvements": ["array of strings"],
    "detailedFeedback": [
        {
            "aspect": "string",
            "rating": "Excellent" | "Good" | "Needs Improvement" | "Poor",
            "description": "string"
        }
    ]
}`;

    // Add frames as images
    const messageContent = [
      { type: 'text', text: prompt }
    ];

    // Add up to 4 frames (API limit)
    for (const frame of frames.slice(0, 4)) {
      messageContent.push({
        type: 'image_url',
        image_url: {
          url: `data:image/jpeg;base64,${frame}`,
          detail: 'high'
        }
      });
    }

    const requestBody = {
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are an expert fitness trainer specializing in form correction and injury prevention. Analyze exercise videos with precision and provide actionable feedback.'
        },
        {
          role: 'user',
          content: messageContent
        }
      ],
      max_tokens: 2000,
      temperature: 0.5,
      response_format: { type: 'json_object' }
    };

    const response = await makeOpenAIRequest('/chat/completions', requestBody);
    
    res.json({
      success: true,
      data: response
    });
  } catch (error) {
    console.error('Error analyzing form:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to analyze form'
    });
  }
});

// Helper function to build workout plan prompt (simplified)
function buildWorkoutPlanPrompt(profile, userNotes) {
  // This is a simplified version - you may want to add more detail
  return `Create a personalized workout plan for:
- Name: ${profile.name}
- Age: ${profile.age}
- Fitness Level: ${profile.fitnessLevel}
- Goals: ${profile.goals.join(', ')}
- Available Equipment: ${profile.availableEquipment.join(', ')}
- Workout Frequency: ${profile.workoutFrequency}

${userNotes ? `Additional Notes: ${userNotes}` : ''}

Create a comprehensive workout plan...`; // Add full prompt from iOS app
}

function buildCustomizationPrompt(currentPlan, request) {
  // Simplified version
  return `Modify this workout plan: ${request}

Current plan details...`; // Add full prompt from iOS app
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  console.log(`RepRight Backend API running on port ${PORT}`);
  console.log(`OpenAI API Key: ${OPENAI_API_KEY.substring(0, 10)}...`);
});

