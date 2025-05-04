import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ResumeViewModel()
    @State private var showTemplateGallery = false
    @State private var showEnhancedAIView = false
    @State private var loadingTimeout = false
    @State private var loadingTimer: Timer? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color("0F2027").opacity(0.95),
                        Color("203A43").opacity(0.85),
                        Color("2C5364").opacity(0.75)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // App logo and title
                        VStack(spacing: 5) {
                            HStack(spacing: 10) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 30))
                                
                                Text("DeepResume AI")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            
                            Text("Smart resumes powered by DeepSeek AI")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(.top, 20)
                        
                        // Main Content
                        if viewModel.isLoading {
                            loadingView
                                .transition(.opacity)
                                .onAppear {
                                    // Create a timer that will set loadingTimeout to true after 30 seconds
                                    loadingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
                                        loadingTimeout = true
                                    }
                                }
                                .onDisappear {
                                    // Invalidate the timer when the loading view disappears
                                    loadingTimer?.invalidate()
                                    loadingTimeout = false
                                }
                        } else {
                            mainContentView
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text(loadingTimeout ? "Still processing... This is taking longer than expected." : "Processing your resume...")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            if loadingTimeout {
                Button {
                    // Cancel the operation and reset loading state
                    viewModel.cancelOperation()
                    loadingTimeout = false
                } label: {
                    Text("Cancel")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var mainContentView: some View {
        VStack(spacing: 25) {
            // Upload Resume Button
            NavigationLink {
                UploadView()
            } label: {
                HStack {
                    Image(systemName: "doc.badge.plus")
                        .font(.title2)
                    Text("Upload Resume")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            // Premium Features section
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Premium Features")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        // Action for "View All"
                    } label: {
                        Text("View All")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    FeatureCard(
                        icon: "doc.text.fill",
                        title: "Cover Letters",
                        description: "AI generated cover letters tailored to job descriptions",
                        color: Color("FF5F6D")
                    )
                    
                    FeatureCard(
                        icon: "text.magnifyingglass",
                        title: "Keyword Optimization",
                        description: "Match your resume to job listings with AI keyword analysis",
                        color: Color("4776E6")
                    )
                    
                    FeatureCard(
                        icon: "chart.bar.fill",
                        title: "Stats & Analysis",
                        description: "Get detailed insights on your resume's effectiveness",
                        color: Color("8E2DE2")
                    )
                    
                    FeatureCard(
                        icon: "rectangle.stack.fill",
                        title: "Premium Templates",
                        description: "Access our library of professionally designed templates",
                        color: Color("16A085")
                    )
                }
            }
            
            // Enhanced AI Personalization button
            enhancedAIButton
        }
    }
    
    private var enhancedAIButton: some View {
        Button {
            showEnhancedAIView = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "sparkles.square.filled.on.square")
                            .font(.title3)
                        
                        Text("Enhanced AI & Personalization")
                            .font(.system(.headline, design: .rounded))
                    }
                    .foregroundColor(.white)
                    
                    Text("AI-powered resume tailoring, industry insights, career path, languages")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("8E2DE2"), Color("4A00E0")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .shadow(color: Color("4A00E0").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .sheet(isPresented: $showEnhancedAIView) {
            EnhancedAIPersonalizationView(viewModel: viewModel)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )
                
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(3)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
} 