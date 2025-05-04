import SwiftUI

struct CareerAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Career Analytics")
                    .font(.title2)
                
                Text("Gain insights into your career progression, skill development, and market positioning with AI-powered analytics.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Spacer()
                
                Text("Coming soon!")
                    .font(.headline)
                    .foregroundColor(.purple)
            }
            .padding()
            .navigationTitle("Career Analytics")
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
    CareerAnalyticsView()
} 