import Foundation

struct FormAnalysis: Codable, Identifiable {
    let id: UUID
    let exerciseName: String
    let videoURL: URL?
    let overallScore: Int // 0-100
    let analysis: String
    let strengths: [String]
    let improvements: [String]
    let detailedFeedback: [FormFeedback]
    let cameraPositionUsed: CameraPosition?
    let analyzedAt: Date
    
    init(id: UUID = UUID(), exerciseName: String, videoURL: URL?, overallScore: Int, analysis: String, strengths: [String], improvements: [String], detailedFeedback: [FormFeedback], cameraPositionUsed: CameraPosition? = nil, analyzedAt: Date = Date()) {
        self.id = id
        self.exerciseName = exerciseName
        self.videoURL = videoURL
        self.overallScore = overallScore
        self.analysis = analysis
        self.strengths = strengths
        self.improvements = improvements
        self.detailedFeedback = detailedFeedback
        self.cameraPositionUsed = cameraPositionUsed
        self.analyzedAt = analyzedAt
    }
}

struct FormFeedback: Codable, Identifiable {
    let id: UUID
    let aspect: String // e.g., "Back Position", "Knee Alignment"
    let rating: FeedbackRating
    let description: String
    
    enum FeedbackRating: String, Codable {
        case excellent = "Excellent"
        case good = "Good"
        case needsImprovement = "Needs Improvement"
        case poor = "Poor"
    }
    
    init(id: UUID = UUID(), aspect: String, rating: FeedbackRating, description: String) {
        self.id = id
        self.aspect = aspect
        self.rating = rating
        self.description = description
    }
}

struct CameraPosition: Codable {
    let angle: CameraAngle
    let distance: String
    let height: String
    let instructions: String
    let visualGuidePrompt: String // For DALL-E image generation
    
    enum CameraAngle: String, Codable, CaseIterable {
        case front = "Front View"
        case side = "Side View"
        case back = "Back View"
        case diagonal = "45° Diagonal"
        case overhead = "Overhead View"
    }
}

extension CameraPosition {
    var instructionLines: [String] {
        let normalized = instructions.replacingOccurrences(of: #"(?<!^)(?=\d+\.)"#,
                                                           with: "\n",
                                                           options: .regularExpression)
        return normalized
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

