import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct SelectionCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .white.opacity(0.3))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.white.opacity(0.1), lineWidth: 2)
            )
        }
    }
}

struct MultiSelectCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.5))
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.white.opacity(0.1), lineWidth: 1.5)
            )
        }
    }
}

