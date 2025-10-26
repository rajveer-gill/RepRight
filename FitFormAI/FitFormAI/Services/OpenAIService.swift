import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService()
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    private init() {
        // Load API key from configuration
        self.apiKey = Config.getAPIKey()
        
        if apiKey.isEmpty || apiKey == "YOUR_OPENAI_API_KEY_HERE" {
            print("⚠️ WARNING: OpenAI API key not found. Please add it to Config.swift")
            print("📝 See SECURITY.md for setup instructions")
        }
    }
    
    // MARK: - Workout Plan Generation
    
    func generateWorkoutPlan(for profile: UserProfile) async throws -> WorkoutPlan {
        let prompt = buildWorkoutPlanPrompt(profile: profile)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are an expert fitness trainer and exercise physiologist. Create personalized, safe, and effective workout plans based on user profiles. Always respond in valid JSON format."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "response_format": ["type": "json_object"]
        ]
        
        let response = try await makeAPIRequest(endpoint: "/chat/completions", body: requestBody)
        return try parseWorkoutPlanResponse(response)
    }
    
    // MARK: - Camera Position Guidance
    
    func getCameraPositionGuidance(for exerciseName: String) async throws -> CameraPosition {
        let prompt = """
        For the exercise "\(exerciseName)", determine the OPTIMAL camera position for form analysis.
        
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
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are an expert in exercise biomechanics and video analysis. Provide precise camera positioning guidance for optimal form assessment."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.5,
            "response_format": ["type": "json_object"]
        ]
        
        let response = try await makeAPIRequest(endpoint: "/chat/completions", body: requestBody)
        return try parseCameraPositionResponse(response)
    }
    
    // MARK: - Generate Camera Position Image
    
    func generateCameraPositionImage(for position: CameraPosition, exerciseName: String) async throws -> UIImage {
        let enhancedPrompt = """
        Create a clean, professional diagram showing camera setup for filming the exercise "\(exerciseName)".
        
        Style: Minimalist technical illustration with:
        - A simple stick figure or silhouette performing the exercise
        - A camera icon positioned at: \(position.angle), \(position.height), \(position.distance)
        - Dotted lines showing the camera's field of view
        - Clear labels and measurements
        - Modern, professional design with a white or light gradient background
        - Blue and black color scheme
        
        The illustration should clearly show: \(position.instructions)
        """
        
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": enhancedPrompt,
            "n": 1,
            "size": "1024x1024",
            "quality": "standard",
            "style": "natural"
        ]
        
        let response = try await makeAPIRequest(endpoint: "/images/generations", body: requestBody)
        
        guard let data = response["data"] as? [[String: Any]],
              let firstImage = data.first,
              let urlString = firstImage["url"] as? String,
              let imageURL = URL(string: urlString) else {
            throw APIError.invalidResponse
        }
        
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        guard let image = UIImage(data: imageData) else {
            throw APIError.invalidResponse
        }
        
        return image
    }
    
    // MARK: - Video Form Analysis
    
    func analyzeExerciseForm(videoFrames: [UIImage], exerciseName: String, cameraPosition: CameraPosition) async throws -> FormAnalysis {
        // For optimal analysis, we'll sample key frames from the video
        let selectedFrames = selectKeyFrames(from: videoFrames, count: 8)
        let base64Frames = selectedFrames.compactMap { $0.jpegData(compressionQuality: 0.7)?.base64EncodedString() }
        
        let prompt = """
        Analyze this exercise form for: \(exerciseName)
        Camera Position: \(cameraPosition.angle) at \(cameraPosition.height), \(cameraPosition.distance)
        
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
        }
        """
        
        var messageContent: [[String: Any]] = [
            ["type": "text", "text": prompt]
        ]
        
        // Add frames as images
        for base64Frame in base64Frames.prefix(4) { // Limit to 4 frames for API constraints
            messageContent.append([
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(base64Frame)",
                    "detail": "high"
                ]
            ])
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are an expert fitness trainer specializing in form correction and injury prevention. Analyze exercise videos with precision and provide actionable feedback."],
                ["role": "user", "content": messageContent]
            ],
            "max_tokens": 2000,
            "temperature": 0.5,
            "response_format": ["type": "json_object"]
        ]
        
        let response = try await makeAPIRequest(endpoint: "/chat/completions", body: requestBody)
        return try parseFormAnalysisResponse(response, exerciseName: exerciseName, cameraPosition: cameraPosition)
    }
    
    // MARK: - Helper Methods
    
    private func makeAPIRequest(endpoint: String, body: [String: Any]) async throws -> [String: Any] {
        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidResponse
        }
        
        return json
    }
    
    private func buildWorkoutPlanPrompt(profile: UserProfile) -> String {
        let frequencyInstruction = profile.workoutFrequency.daysPerWeek == 7 ?
            "The user wants to work out every day. Create a smart 7-day routine with active recovery days. Include lighter activities like yoga, stretching, or light cardio on recovery days. Never have 7 consecutive intense training days." :
            "Create exactly \(profile.workoutFrequency.daysPerWeek) workout days per week."
        
        return """
        Create a personalized workout plan with the following specifications:
        
        User Profile:
        - Fitness Level: \(profile.fitnessLevel.rawValue)
        - Goals: \(profile.goals.map { $0.rawValue }.joined(separator: ", "))
        - Workout Frequency: \(profile.workoutFrequency.rawValue)
        - Restrictions: \(profile.restrictions.isEmpty ? "None" : profile.restrictions.joined(separator: ", "))
        - Preferred Workout Types: \(profile.preferredWorkoutTypes.map { $0.rawValue }.joined(separator: ", "))
        - Available Equipment: \(profile.availableEquipment.map { $0.rawValue }.joined(separator: ", "))
        
        IMPORTANT: \(frequencyInstruction)
        
        Create a comprehensive workout plan with:
        - Appropriate exercises for their level and goals
        - Proper progression and rest days (if not working out 7 days)
        - Clear sets, reps, and rest periods
        
        Respond in JSON format:
        {
            "title": "string",
            "description": "string",
            "durationWeeks": number,
            "workouts": [
                {
                    "day": "string (e.g., Monday, Day 1)",
                    "title": "string",
                    "exercises": [
                        {
                            "name": "string",
                            "sets": number,
                            "reps": "string (e.g., '8-12', '30 seconds')",
                            "restTime": number (seconds),
                            "notes": "string or null",
                            "muscleGroups": ["array of strings"],
                            "difficulty": "string"
                        }
                    ]
                }
            ]
        }
        """
    }
    
    private func parseWorkoutPlanResponse(_ response: [String: Any]) throws -> WorkoutPlan {
        guard let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String,
              let jsonData = content.data(using: .utf8),
              let planData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw APIError.invalidResponse
        }
        
        let title = planData["title"] as? String ?? "Your Workout Plan"
        let description = planData["description"] as? String ?? ""
        let durationWeeks = planData["durationWeeks"] as? Int ?? 4
        
        var workouts: [Workout] = []
        if let workoutsData = planData["workouts"] as? [[String: Any]] {
            for workoutData in workoutsData {
                let workout = try parseWorkout(workoutData)
                workouts.append(workout)
            }
        }
        
        return WorkoutPlan(title: title, description: description, durationWeeks: durationWeeks, workouts: workouts)
    }
    
    private func parseWorkout(_ data: [String: Any]) throws -> Workout {
        let day = data["day"] as? String ?? "Day"
        let title = data["title"] as? String ?? "Workout"
        
        var exercises: [Exercise] = []
        if let exercisesData = data["exercises"] as? [[String: Any]] {
            for exerciseData in exercisesData {
                let exercise = try parseExercise(exerciseData)
                exercises.append(exercise)
            }
        }
        
        // Calculate estimated duration based on exercises
        let estimatedDuration = calculateWorkoutDuration(exercises: exercises)
        
        return Workout(day: day, title: title, exercises: exercises, estimatedDuration: estimatedDuration)
    }
    
    private func calculateWorkoutDuration(exercises: [Exercise]) -> Int {
        // Average time per exercise: 5-10 minutes (sets + rest)
        let avgTimePerExercise = 7
        return exercises.count * avgTimePerExercise
    }
    
    private func parseExercise(_ data: [String: Any]) throws -> Exercise {
        let name = data["name"] as? String ?? "Exercise"
        let sets = data["sets"] as? Int ?? 3
        let reps = data["reps"] as? String ?? "10"
        let restTime = data["restTime"] as? Int ?? 60
        let notes = data["notes"] as? String
        let muscleGroups = data["muscleGroups"] as? [String] ?? []
        let difficulty = data["difficulty"] as? String ?? "Intermediate"
        
        return Exercise(name: name, sets: sets, reps: reps, restTime: restTime, notes: notes, muscleGroups: muscleGroups, difficulty: difficulty)
    }
    
    private func parseCameraPositionResponse(_ response: [String: Any]) throws -> CameraPosition {
        guard let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String,
              let jsonData = content.data(using: .utf8),
              let positionData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw APIError.invalidResponse
        }
        
        let angleString = positionData["angle"] as? String ?? "Side View"
        let angle = CameraPosition.CameraAngle(rawValue: angleString) ?? .side
        let distance = positionData["distance"] as? String ?? "6-8 feet away"
        let height = positionData["height"] as? String ?? "Waist height"
        let instructions = positionData["instructions"] as? String ?? "Position camera at side view"
        let visualGuidePrompt = positionData["visualGuidePrompt"] as? String ?? "Camera setup diagram"
        
        return CameraPosition(angle: angle, distance: distance, height: height, instructions: instructions, visualGuidePrompt: visualGuidePrompt)
    }
    
    private func parseFormAnalysisResponse(_ response: [String: Any], exerciseName: String, cameraPosition: CameraPosition) throws -> FormAnalysis {
        guard let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String,
              let jsonData = content.data(using: .utf8),
              let analysisData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw APIError.invalidResponse
        }
        
        let overallScore = analysisData["overallScore"] as? Int ?? 70
        let analysis = analysisData["analysis"] as? String ?? "Form analysis complete"
        let strengths = analysisData["strengths"] as? [String] ?? []
        let improvements = analysisData["improvements"] as? [String] ?? []
        
        var detailedFeedback: [FormFeedback] = []
        if let feedbackData = analysisData["detailedFeedback"] as? [[String: Any]] {
            for item in feedbackData {
                let aspect = item["aspect"] as? String ?? "General"
                let ratingString = item["rating"] as? String ?? "Good"
                let rating = FormFeedback.FeedbackRating(rawValue: ratingString) ?? .good
                let description = item["description"] as? String ?? ""
                
                detailedFeedback.append(FormFeedback(aspect: aspect, rating: rating, description: description))
            }
        }
        
        return FormAnalysis(
            exerciseName: exerciseName,
            videoURL: nil,
            overallScore: overallScore,
            analysis: analysis,
            strengths: strengths,
            improvements: improvements,
            detailedFeedback: detailedFeedback,
            cameraPositionUsed: cameraPosition
        )
    }
    
    // MARK: - Workout Customization
    
    func customizeWorkoutPlan(_ request: CustomizationRequest) async throws -> CustomizationResponse {
        let prompt = buildCustomizationPrompt(request: request)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are an expert fitness trainer and exercise physiologist. When users request workout plan changes, you must:\n1. Evaluate if the change is harmful to their development\n2. If harmful, provide a clear warning and explanation\n3. If safe, create a modified plan\n4. Always respond in valid JSON format."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "response_format": ["type": "json_object"]
        ]
        
        let response = try await makeAPIRequest(endpoint: "/chat/completions", body: requestBody)
        return try parseCustomizationResponse(response)
    }
    
    private func buildCustomizationPrompt(request: CustomizationRequest) -> String {
        let exercisesList = request.currentPlan.workouts.flatMap { $0.exercises.map { $0.name } }.joined(separator: ", ")
        let workoutTitles = request.currentPlan.workouts.map { "\($0.day): \($0.title)" }.joined(separator: ", ")
        
        return """
        Current Workout Plan:
        - Title: \(request.currentPlan.title)
        - Duration: \(request.currentPlan.durationWeeks) weeks
        - Number of workouts: \(request.currentPlan.workouts.count)
        - Workout Schedule: \(workoutTitles)
        - Exercises: \(exercisesList)
        
        User's Customization Request: "\(request.request)"
        
        IMPORTANT: When modifying the plan:
        - Keep the same workout structure and day/title labels (e.g., "Upper Body", "Lower Body", "Push Day", "Pull Day", "Leg Day")
        - Only change the specific exercises requested
        - Maintain the same workout focus unless the request explicitly changes it
        
        Analyze this request and respond in JSON format:
        {
            "isHarmful": boolean (true if the change is bad for their development, false if it's safe),
            "warningMessage": "string or null" (explain why it's harmful if isHarmful is true),
            "modifiedPlan": { 
                "title": "string",
                "description": "string",
                "durationWeeks": number,
                "workouts": [array of workout objects with same structure as original]
            } or null,
            "explanation": "string" (explain what you changed and why, or why you refused)
        }
        
        CRITICAL: The modifiedPlan MUST include the "workouts" array with ALL workout days, even if you're only changing exercises. DO NOT create an empty plan.
        
        IMPORTANT SAFETY RULES:
        - If they try to remove compound exercises (squats, deadlifts, bench press) for muscle groups that need them, mark as harmful
        - If they want to add dangerous exercises, mark as harmful
        - If they want to do extreme volume that could cause injury, mark as harmful
        - Push-pull-legs split, removing leg press, adding more cardio = SAFE
        - Removing squats entirely for leg days = HARMFUL
        - If not harmful, provide the complete modified workout plan in the same JSON format as the original
        
        CRITICAL: The "modifiedPlan" must be a complete, valid workout plan JSON object with the EXACT same structure as the original plan. Include ALL fields: title, description, durationWeeks, and all workouts with all their exercises (name, sets, reps, restTime, notes, muscleGroups, difficulty).
        
        IMPORTANT: When creating modified workouts, preserve meaningful "day" and "title" fields (e.g., "Upper Body", "Lower Body", "Push Day", "Pull Day", "Leg Day") - DO NOT use generic "Workout" labels.
        """
    }
    
    private func parseCustomizationResponse(_ response: [String: Any]) throws -> CustomizationResponse {
        guard let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            print("❌ Failed to extract content from API response")
            throw APIError.invalidResponse
        }
        
        let jsonData = content.data(using: .utf8)
        guard let data = jsonData,
              let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse JSON from AI response")
            print("Content: \(content)")
            throw APIError.invalidResponse
        }
        
        let isHarmful = responseData["isHarmful"] as? Bool ?? false
        let warningMessage = responseData["warningMessage"] as? String
        let explanation = responseData["explanation"] as? String ?? "Customization processed"
        
        print("✅ isHarmful: \(isHarmful)")
        print("✅ hasModifiedPlan: \(responseData["modifiedPlan"] != nil)")
        
        var modifiedPlan: WorkoutPlan? = nil
        if let planData = responseData["modifiedPlan"] as? [String: Any] {
            do {
                print("📋 Attempting to parse modified plan...")
                modifiedPlan = try parseWorkoutPlanFromDict(planData)
                print("✅ Successfully parsed modified plan!")
                print("📊 Plan has \(modifiedPlan?.workouts.count ?? 0) workouts")
                print("📝 Plan title: \(modifiedPlan?.title ?? "nil")")
            } catch {
                print("❌ Error parsing modified plan: \(error)")
                print("Plan data keys: \(planData.keys)")
            }
        } else {
            print("⚠️ No modifiedPlan in response")
        }
        
        return CustomizationResponse(
            isHarmful: isHarmful,
            warningMessage: warningMessage,
            modifiedPlan: modifiedPlan,
            explanation: explanation
        )
    }
    
    private func parseWorkoutPlanFromDict(_ data: [String: Any]) throws -> WorkoutPlan {
        let title = data["title"] as? String ?? "Your Workout Plan"
        let description = data["description"] as? String ?? ""
        let durationWeeks = data["durationWeeks"] as? Int ?? 4
        
        print("🔍 Parsing workout plan from dict:")
        print("   Title: \(title)")
        print("   Description: \(description)")
        print("   Duration: \(durationWeeks) weeks")
        print("   Available keys in data: \(data.keys)")
        
        var workouts: [Workout] = []
        if let workoutsData = data["workouts"] as? [[String: Any]] {
            print("   Found \(workoutsData.count) workouts in data")
            for (index, workoutData) in workoutsData.enumerated() {
                print("   Parsing workout \(index + 1)...")
                let workout = try parseWorkout(workoutData)
                print("   ✅ Workout \(index + 1): \(workout.day) - \(workout.title) (\(workout.exercises.count) exercises)")
                workouts.append(workout)
            }
        } else {
            print("   ⚠️ No workouts array found in data!")
            print("   Data contents: \(data)")
        }
        
        print("   Final plan has \(workouts.count) workouts")
        
        return WorkoutPlan(title: title, description: description, durationWeeks: durationWeeks, workouts: workouts)
    }
    
    private func selectKeyFrames(from frames: [UIImage], count: Int) -> [UIImage] {
        guard frames.count > count else { return frames }
        
        let interval = frames.count / count
        var selectedFrames: [UIImage] = []
        
        for i in 0..<count {
            let index = i * interval
            if index < frames.count {
                selectedFrames.append(frames[index])
            }
        }
        
        return selectedFrames
    }
    
    enum APIError: LocalizedError {
        case missingAPIKey
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "OpenAI API key is missing. Please add it to your configuration."
            case .invalidURL:
                return "Invalid API URL"
            case .invalidResponse:
                return "Invalid response from API"
            case .httpError(let statusCode, let message):
                return "HTTP Error \(statusCode): \(message)"
            }
        }
    }
}

