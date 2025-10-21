import SwiftUI

struct FormAnalysisResultView: View {
    let analysis: FormAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Analysis Results")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            // Overall Score
            ScoreCard(score: analysis.overallScore)
            
            // Summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Summary")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(analysis.analysis)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            
            // Strengths
            if !analysis.strengths.isEmpty {
                FeedbackSection(
                    title: "What You're Doing Well",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    items: analysis.strengths
                )
            }
            
            // Improvements
            if !analysis.improvements.isEmpty {
                FeedbackSection(
                    title: "Areas for Improvement",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    items: analysis.improvements
                )
            }
            
            // Detailed Feedback
            if !analysis.detailedFeedback.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Detailed Feedback")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(analysis.detailedFeedback) { feedback in
                        DetailedFeedbackCard(feedback: feedback)
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Analyze Again")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct ScoreCard: View {
    let score: Int
    
    var scoreColor: Color {
        if score >= 80 { return .green }
        if score >= 60 { return .blue }
        if score >= 40 { return .orange }
        return .red
    }
    
    var scoreLabel: String {
        if score >= 80 { return "Excellent" }
        if score >= 60 { return "Good" }
        if score >= 40 { return "Needs Work" }
        return "Poor"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        LinearGradient(
                            colors: [scoreColor, scoreColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/ 100")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text(scoreLabel)
                .font(.title3.bold())
                .foregroundColor(scoreColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(scoreColor.opacity(0.1))
        )
    }
}

struct FeedbackSection: View {
    let title: String
    let icon: String
    let color: Color
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        
                        Text(item)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DetailedFeedbackCard: View {
    let feedback: FormFeedback
    
    var ratingColor: Color {
        switch feedback.rating {
        case .excellent: return .green
        case .good: return .blue
        case .needsImprovement: return .orange
        case .poor: return .red
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: ratingIcon)
                .foregroundColor(ratingColor)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.aspect)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(feedback.rating.rawValue)
                    .font(.caption)
                    .foregroundColor(ratingColor)
                    .fontWeight(.semibold)
                
                Text(feedback.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ratingColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ratingColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    var ratingIcon: String {
        switch feedback.rating {
        case .excellent: return "star.fill"
        case .good: return "checkmark.circle.fill"
        case .needsImprovement: return "exclamationmark.circle.fill"
        case .poor: return "xmark.circle.fill"
        }
    }
}

