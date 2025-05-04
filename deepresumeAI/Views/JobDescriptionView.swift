import SwiftUI

struct JobDescriptionView: View {
    @ObservedObject var viewModel: ResumeViewModel
    @Binding var jobDescription: String
    @Environment(\.dismiss) var dismiss
    @State private var isAnalyzing = false
    @State private var analysisType: AnalysisType = .atsScore
    
    enum AnalysisType: String, CaseIterable, Identifiable {
        case atsScore = "ATS Score"
        case aiEnhance = "AI Enhancement"
        
        var id: Self { self }
        
        var description: String {
            switch self {
            case .atsScore:
                return "Analyze how well your resume matches this job description through an ATS system"
            case .aiEnhance:
                return "Get AI-powered suggestions to improve your resume for this specific role"
            }
        }
        
        var icon: String {
            switch self {
            case .atsScore: return "checkmark.shield"
            case .aiEnhance: return "wand.and.stars"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color("134E5E").opacity(0.7), Color("71B280").opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Info text
                    VStack(spacing: 8) {
                        Text("Enter Job Description")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Paste a job description to get personalized DeepSeek AI analysis")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Job description input
                    TextEditor(text: $jobDescription)
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .cornerRadius(16)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    
                    // Analysis type picker
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Analysis Type")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)
                        
                        ForEach(AnalysisType.allCases) { type in
                            Button {
                                analysisType = type
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: type.icon)
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(type == analysisType ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(type.rawValue)
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundStyle(.white)
                                        
                                        Text(type.description)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.8))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                    
                                    if type == analysisType {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(type == analysisType ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Analyze button
                    Button {
                        isAnalyzing = true
                        switch analysisType {
                        case .atsScore:
                            viewModel.analyzeATSCompliance(jobDescription: jobDescription)
                        case .aiEnhance:
                            viewModel.generateAIContent(jobDescription: jobDescription)
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Text("Analyze with DeepSeek AI")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("6441A5").opacity(0.8), Color("2a0845").opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .disabled(jobDescription.isEmpty)
                    .opacity(jobDescription.isEmpty ? 0.6 : 1)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Job Description")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        jobDescription = ""
                    } label: {
                        Text("Clear")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
    }
}

#Preview {
    JobDescriptionView(viewModel: ResumeViewModel(), jobDescription: .constant(""))
} 