import SwiftUI

struct EnhancedAIPersonalizationView: View {
    @ObservedObject var viewModel: ResumeViewModel
    @State private var jobDescription: String = ""
    @State private var selectedTab = 0
    @State private var careerGoal: String = ""
    @State private var selectedLanguage: SupportedLanguage = .english
    @Environment(\.dismiss) var dismiss
    
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
                
                VStack(spacing: 0) {
                    // Custom segmented control
                    HStack(spacing: 0) {
                        ForEach(["Resume Tailoring", "Industry Focus", "Career Path", "Languages"].indices, id: \.self) { index in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = index
                                }
                            } label: {
                                Text(["Resume Tailoring", "Industry Focus", "Career Path", "Languages"][index])
                                    .font(.system(.subheadline, design: .rounded, weight: selectedTab == index ? .bold : .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedTab == index ? Color.white.opacity(0.15) : Color.clear)
                                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                            }
                        }
                    }
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Tab content
                    TabView(selection: $selectedTab) {
                        // Resume Tailoring
                        resumeTailoringView
                            .tag(0)
                        
                        // Industry Focus
                        industryFocusView
                            .tag(1)
                        
                        // Career Path
                        careerPathView
                            .tag(2)
                        
                        // Languages
                        languagesView
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("AI Personalization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .alert("Error", isPresented: .init(get: {
                viewModel.errorMessage != nil
            }, set: { _ in
                viewModel.errorMessage = nil
            })) {
                Button("OK") {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Resume Tailoring View
    private var resumeTailoringView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36))
                    .foregroundColor(.yellow)
                
                Text("AI-Powered Resume Tailoring")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Automatically adjust your resume content to match specific job descriptions")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 25)
            
            // Job description input
            VStack(alignment: .leading, spacing: 8) {
                Text("Paste Job Description")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextEditor(text: $jobDescription)
                    .frame(height: 200)
                    .padding(10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            
            // Action button
            Button {
                viewModel.tailorResumeForJob(jobDescription: jobDescription)
            } label: {
                Text("Tailor My Resume")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color("FF5F6D"), Color("FF9966")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(jobDescription.isEmpty || viewModel.isLoading)
            .opacity(jobDescription.isEmpty ? 0.5 : 1.0)
            
            // Info text
            Text("This process will optimize your resume's content to highlight the most relevant skills and experiences for this specific job.")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 5)
            
            Spacer()
        }
    }
    
    // MARK: - Industry Focus View
    private var industryFocusView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "building.2")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
                
                Text("Industry & Role Focus")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Get dynamic content suggestions based on your target industry and role")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 25)
            
            // Industry & role input
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Industry")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("E.g. Technology, Healthcare, Finance", text: $viewModel.targetIndustry)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Role")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("E.g. Software Engineer, Product Manager", text: $viewModel.targetRole)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)
            
            // Action button
            Button {
                viewModel.generateIndustrySpecificSuggestions()
            } label: {
                Text("Generate Industry-Specific Suggestions")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color("4776E6"), Color("8E54E9")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(viewModel.targetIndustry.isEmpty || viewModel.targetRole.isEmpty || viewModel.isLoading)
            .opacity((viewModel.targetIndustry.isEmpty || viewModel.targetRole.isEmpty) ? 0.5 : 1.0)
            
            // Info text
            Text("Personalized recommendations will help you highlight the most relevant skills and experiences for your target industry and role.")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 5)
            
            Spacer()
        }
    }
    
    // MARK: - Career Path View
    private var careerPathView: some View {
        VStack(spacing: 5) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "arrow.up.forward.circle")
                    .font(.system(size: 36))
                    .foregroundColor(.green)
                
                Text("Career Path Recommendations")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Get AI-driven suggestions for skills and certifications to boost your career")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            // Career goals section
            VStack(alignment: .leading, spacing: 10) {
                Text("Career Goals")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    TextField("Add a career goal", text: $careerGoal)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Button {
                        if !careerGoal.isEmpty {
                            viewModel.addCareerGoal(careerGoal)
                            careerGoal = ""
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .disabled(careerGoal.isEmpty)
                }
                
                // Career goals list
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.resume.careerGoals.indices, id: \.self) { index in
                            HStack {
                                Text(viewModel.resume.careerGoals[index])
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                Button {
                                    viewModel.removeCareerGoal(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 120)
            }
            .padding(.horizontal)
            .padding(.top, 5)
            
            // Recommendations
            if !viewModel.careerRecommendations.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("AI Recommendations")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(viewModel.careerRecommendations) { recommendation in
                                recommendationCard(recommendation)
                            }
                        }
                    }
                    .frame(height: 180)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            
            // Action button
            Button {
                viewModel.generateCareerPathRecommendations()
            } label: {
                Text("Generate Career Recommendations")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color("16A085"), Color("3498DB")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(viewModel.resume.careerGoals.isEmpty || viewModel.isLoading)
            .opacity(viewModel.resume.careerGoals.isEmpty ? 0.5 : 1.0)
            .padding(.top, 15)
            
            // Info text
            Text("Add your career goals to get personalized recommendations for skills and certifications that can help you achieve them.")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 5)
            
            Spacer()
        }
    }
    
    private func recommendationCard(_ recommendation: CareerPathRecommendation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .padding(.top, 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.skillName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let certification = recommendation.certificationName {
                    Text("Certification: \(certification)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text("Est. time: \(recommendation.estimatedTimeToAcquire)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack {
                    Text("Relevance:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    // Relevance bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: geometry.size.width, height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * recommendation.relevanceScore, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Languages View
    private var languagesView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.system(size: 36))
                    .foregroundColor(.purple)
                
                Text("Multi-Language Support")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Translate your resume for global job markets")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 25)
            
            // Current language
            VStack(spacing: 5) {
                Text("Current Language")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(viewModel.currentLanguage.flagEmoji)
                        .font(.title)
                    
                    Text(viewModel.currentLanguage.displayName)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Language selection
            if viewModel.hasTranslatedVersions {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Available Translations")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.supportedLanguages, id: \.self) { language in
                                Button {
                                    viewModel.switchLanguage(to: language)
                                } label: {
                                    VStack {
                                        Text(language.flagEmoji)
                                            .font(.title)
                                        
                                        Text(language.displayName)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(viewModel.currentLanguage == language ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(viewModel.currentLanguage == language ? Color.white : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding(.horizontal)
            }
            
            // Add new language
            VStack(alignment: .leading, spacing: 10) {
                Text("Translate to New Language")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Picker("Select Language", selection: $selectedLanguage) {
                    ForEach(viewModel.availableLanguages, id: \.self) { language in
                        HStack {
                            Text(language.flagEmoji)
                            Text(language.displayName)
                        }
                        .tag(language)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .accentColor(.white)
            }
            .padding(.horizontal)
            
            // Action button
            Button {
                viewModel.translateResume(to: selectedLanguage)
            } label: {
                Text("Translate Resume")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color("8E2DE2"), Color("4A00E0")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(viewModel.isLoading || viewModel.supportedLanguages.contains(selectedLanguage))
            .opacity(viewModel.supportedLanguages.contains(selectedLanguage) ? 0.5 : 1.0)
            
            // Info text
            Text("AI-assisted translation preserves professional terminology and ensures your resume reads naturally in each language.")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 5)
            
            Spacer()
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Processing with AI...")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }
}

#Preview {
    EnhancedAIPersonalizationView(viewModel: ResumeViewModel())
} 