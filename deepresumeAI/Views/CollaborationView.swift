import SwiftUI

struct CollaborationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Collaborate with others")
                    .font(.title2)
                
                Text("Share your resume with colleagues, mentors, or professionals for feedback and improvement suggestions.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Spacer()
                
                Text("Coming soon!")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .navigationTitle("Collaboration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CollaborationView()
} 