import SwiftUI
import AVFoundation
import PhotosUI

struct FormCheckView: View {
    @State private var selectedExercise = ""
    @State private var showExercisePicker = false
    @State private var showCameraSetup = false
    @State private var showVideoRecorder = false
    @State private var showVideoPicker = false
    @State private var cameraPosition: CameraPosition?
    @State private var positionImage: UIImage?
    @State private var isLoadingPosition = false
    @State private var isAnalyzing = false
    @State private var analysisResult: FormAnalysis?
    @State private var selectedVideo: URL?
    @State private var videoFrames: [UIImage] = []
    
    let commonExercises = [
        "Squat", "Deadlift", "Bench Press", "Overhead Press",
        "Barbell Row", "Pull-up", "Push-up", "Lunges",
        "Romanian Deadlift", "Front Squat", "Hip Thrust",
        "Bicep Curl", "Tricep Extension", "Shoulder Press"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Form Check")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("AI-powered form analysis")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Exercise Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Exercise")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button(action: { showExercisePicker.toggle() }) {
                        HStack {
                            Text(selectedExercise.isEmpty ? "Choose an exercise" : selectedExercise)
                                .foregroundColor(selectedExercise.isEmpty ? .white.opacity(0.5) : .white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                // Camera Setup Instructions
                if !selectedExercise.isEmpty && cameraPosition == nil && !isLoadingPosition {
                    Button(action: loadCameraPosition) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Get Camera Setup Guide")
                                .fontWeight(.semibold)
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
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                }
                
                if isLoadingPosition {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Analyzing optimal camera position...")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                // Camera Position Guide
                if let position = cameraPosition {
                    CameraSetupCard(
                        exerciseName: selectedExercise,
                        position: position,
                        positionImage: positionImage,
                        onRecordVideo: {
                            showVideoRecorder = true
                        },
                        onUploadVideo: {
                            showVideoPicker = true
                        }
                    )
                    .padding(.horizontal, 24)
                }
                
                // Analysis Loading
                if isAnalyzing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Analyzing your form...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("This may take a moment")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.2))
                    )
                    .padding(.horizontal, 24)
                }
                
                // Analysis Results
                if let analysis = analysisResult {
                    FormAnalysisResultView(analysis: analysis)
                        .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 100)
            }
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerSheet(exercises: commonExercises, selectedExercise: $selectedExercise)
        }
        .sheet(isPresented: $showVideoRecorder) {
            VideoRecorderView(
                isPresented: $showVideoRecorder,
                onVideoRecorded: handleVideoRecorded
            )
        }
        .sheet(isPresented: $showVideoPicker) {
            VideoPickerView(onVideoPicked: handleVideoRecorded)
        }
    }
    
    private func loadCameraPosition() {
        isLoadingPosition = true
        
        Task {
            do {
                let position = try await OpenAIService.shared.getCameraPositionGuidance(for: selectedExercise)
                let image = try await OpenAIService.shared.generateCameraPositionImage(for: position, exerciseName: selectedExercise)
                
                await MainActor.run {
                    cameraPosition = position
                    positionImage = image
                    isLoadingPosition = false
                }
            } catch {
                await MainActor.run {
                    isLoadingPosition = false
                    // Handle error
                    print("Error loading camera position: \(error)")
                }
            }
        }
    }
    
    private func handleVideoRecorded(_ videoURL: URL) {
        guard let position = cameraPosition else { return }
        
        // Extract frames from video
        extractFrames(from: videoURL) { frames in
            videoFrames = frames
            selectedVideo = videoURL
            analyzeForm()
        }
    }
    
    private func analyzeForm() {
        guard let position = cameraPosition, !videoFrames.isEmpty else { return }
        
        isAnalyzing = true
        
        Task {
            do {
                let analysis = try await OpenAIService.shared.analyzeExerciseForm(
                    videoFrames: videoFrames,
                    exerciseName: selectedExercise,
                    cameraPosition: position
                )
                
                await MainActor.run {
                    analysisResult = analysis
                    isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("Error analyzing form: \(error)")
                }
            }
        }
    }
    
    private func extractFrames(from videoURL: URL, completion: @escaping ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero
            
            let duration = asset.duration.seconds
            let frameCount = min(12, Int(duration)) // Extract up to 12 frames
            var frames: [UIImage] = []
            
            for i in 0..<frameCount {
                let time = CMTime(seconds: duration * Double(i) / Double(frameCount), preferredTimescale: 600)
                
                if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                    frames.append(UIImage(cgImage: cgImage))
                }
            }
            
            DispatchQueue.main.async {
                completion(frames)
            }
        }
    }
}

struct CameraSetupCard: View {
    let exerciseName: String
    let position: CameraPosition
    let positionImage: UIImage?
    let onRecordVideo: () -> Void
    let onUploadVideo: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Camera Setup Guide")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            // Position Image
            if let image = positionImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
            }
            
            // Position Details
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(icon: "camera.fill", title: "Angle", value: position.angle.rawValue)
                DetailRow(icon: "arrow.left.and.right", title: "Distance", value: position.distance)
                DetailRow(icon: "arrow.up.and.down", title: "Height", value: position.height)
            }
            
            // YouTube Tutorial Link
            if let url = exerciseName.youtubeSearchURL {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                        Text("Watch \(exerciseName) Tutorial")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Setup Instructions")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(position.instructions)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onRecordVideo) {
                    HStack {
                        Image(systemName: "video.fill")
                        Text("Record")
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
                
                Button(action: onUploadVideo) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Upload")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

struct ExercisePickerSheet: View {
    let exercises: [String]
    @Binding var selectedExercise: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0A0E27").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(exercises, id: \.self) { exercise in
                            Button(action: {
                                selectedExercise = exercise
                                dismiss()
                            }) {
                                HStack {
                                    Text(exercise)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    if selectedExercise == exercise {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedExercise == exercise ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

