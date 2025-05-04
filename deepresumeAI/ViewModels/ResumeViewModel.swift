import Combine
import SwiftUI

class ResumeViewModel: ObservableObject {
    @Published var resume: Resume
    @Published var isLoading = false
    @Published var aiSuggestions: AISuggestions?
    @Published var atsScore: Double?
    @Published var atsSuggestions: [String] = []
    @Published var errorMessage: String?
    @Published var careerRecommendations: [CareerPathRecommendation] = []
    @Published var targetIndustry: String = ""
    @Published var targetRole: String = ""
    @Published var supportedLanguages: [SupportedLanguage] = [.english]
    @Published var hasTranslatedVersions: Bool = false
    @Published var showLanguageSelection: Bool = false
    
    private let deepSeekService = DeepSeekService()
    private var cancellables = Set<AnyCancellable>()
    
    init(resume: Resume = Resume()) {
        self.resume = resume
        
        // Load existing language versions if available
        if !resume.supportedLanguages.isEmpty {
            self.supportedLanguages = resume.supportedLanguages.compactMap { langCode in
                SupportedLanguage.allCases.first { $0.rawValue == langCode }
            }
            self.hasTranslatedVersions = supportedLanguages.count > 1
        }
        
        // Load target industry/role if available
        if let industry = resume.targetIndustry {
            self.targetIndustry = industry
        }
        if let role = resume.targetRole {
            self.targetRole = role
        }
    }
    
    // Add cancel operation method
    func cancelOperation() {
        // Cancel all ongoing operations
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // Reset loading state
        isLoading = false
        errorMessage = "Operation cancelled by user"
    }
    
    // MARK: - Existing AI Content Generation
    
    func generateAIContent(jobDescription: String) {
        isLoading = true
        errorMessage = nil
        
        deepSeekService.generateAIContent(resume: resume, jobDescription: jobDescription) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let suggestions):
                    self?.aiSuggestions = suggestions
                    self?.applyAISuggestions(suggestions)
                case .failure(let error):
                    self?.errorMessage = "Error generating content: \(error.localizedDescription)"
                    print("Error generating AI content: \(error)")
                }
            }
        }
    }
    
    func analyzeATSCompliance(jobDescription: String) {
        isLoading = true
        errorMessage = nil
        
        deepSeekService.analyzeATSCompliance(resume: resume, jobDescription: jobDescription) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let analysis):
                    self?.atsScore = analysis.score
                    self?.atsSuggestions = analysis.suggestions
                case .failure(let error):
                    self?.errorMessage = "Error analyzing ATS: \(error.localizedDescription)"
                    print("Error analyzing ATS: \(error)")
                }
            }
        }
    }
    
    private func applyAISuggestions(_ suggestions: AISuggestions) {
        // Apply content improvements
        for improvement in suggestions.contentImprovements {
            // Implement logic to apply improvements to resume
            print("Applying improvement: \(improvement)")
        }
        
        // Apply keyword suggestions
        for keyword in suggestions.keywordSuggestions {
            // Implement logic to add keywords to resume
            print("Adding keyword: \(keyword)")
        }
    }
    
    // Method to apply a specific suggestion to the resume
    func applySuggestion(_ suggestion: String) {
        // Implement smart logic to apply a specific suggestion
        // This could involve parsing the suggestion and making 
        // targeted changes to the resume
        print("Automatically applying suggestion: \(suggestion)")
        
        // For demonstration, let's just add it as a skill if it's short
        if suggestion.count < 50 {
            let newSkill = Skill(name: suggestion, level: "Intermediate")
            resume.skills.append(newSkill)
        }
    }
    
    // MARK: - New Enhanced AI Features
    
    // Tailor resume for a specific job description
    func tailorResumeForJob(jobDescription: String) {
        isLoading = true
        errorMessage = nil
        
        deepSeekService.tailorResumeForJob(resume: resume, jobDescription: jobDescription) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let tailoredResume):
                    // Update the resume with tailored content
                    self.resume = tailoredResume
                    
                    // Update UI elements
                    if let role = tailoredResume.targetRole {
                        self.targetRole = role
                    }
                    
                case .failure(let error):
                    self.errorMessage = "Error tailoring resume: \(error.localizedDescription)"
                    print("Error tailoring resume: \(error)")
                }
            }
        }
    }
    
    // Generate dynamic content suggestions based on industry/role
    func generateIndustrySpecificSuggestions() {
        guard !targetIndustry.isEmpty, !targetRole.isEmpty else {
            errorMessage = "Please specify a target industry and role"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        deepSeekService.generateIndustrySpecificSuggestions(
            resume: resume,
            targetIndustry: targetIndustry,
            targetRole: targetRole
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let suggestions):
                    self.aiSuggestions = suggestions
                    
                    // Update resume to store target industry/role
                    var updatedResume = self.resume
                    updatedResume.targetIndustry = self.targetIndustry
                    updatedResume.targetRole = self.targetRole
                    self.resume = updatedResume
                    
                case .failure(let error):
                    self.errorMessage = "Error generating industry suggestions: \(error.localizedDescription)"
                    print("Error generating industry suggestions: \(error)")
                }
            }
        }
    }
    
    // Generate career path recommendations
    func generateCareerPathRecommendations() {
        guard !resume.careerGoals.isEmpty else {
            errorMessage = "Please add at least one career goal"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        deepSeekService.generateCareerPathRecommendations(
            resume: resume,
            careerGoals: resume.careerGoals
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let recommendations):
                    self.careerRecommendations = recommendations
                    
                case .failure(let error):
                    self.errorMessage = "Error generating career recommendations: \(error.localizedDescription)"
                    print("Error generating career recommendations: \(error)")
                }
            }
        }
    }
    
    // Add a career goal
    func addCareerGoal(_ goal: String) {
        var updatedResume = resume
        updatedResume.careerGoals.append(goal)
        resume = updatedResume
    }
    
    // Remove a career goal at specific index
    func removeCareerGoal(at index: Int) {
        guard index < resume.careerGoals.count else { return }
        var updatedResume = resume
        updatedResume.careerGoals.remove(at: index)
        resume = updatedResume
    }
    
    // MARK: - Multi-language Support
    
    // Translate resume to another language
    func translateResume(to language: SupportedLanguage) {
        isLoading = true
        errorMessage = nil
        
        deepSeekService.translateResume(
            resume: resume,
            targetLanguage: language
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let localizedContent):
                    // Save translated content
                    var updatedResume = self.resume
                    updatedResume.addLocalizedContent(localizedContent)
                    self.resume = updatedResume
                    
                    // Update UI state
                    if !self.supportedLanguages.contains(language) {
                        self.supportedLanguages.append(language)
                    }
                    self.hasTranslatedVersions = true
                    
                case .failure(let error):
                    self.errorMessage = "Error translating resume: \(error.localizedDescription)"
                    print("Error translating resume: \(error)")
                }
            }
        }
    }
    
    // Switch resume display language
    func switchLanguage(to language: SupportedLanguage) {
        var updatedResume = resume
        updatedResume.switchLanguage(to: language.rawValue)
        resume = updatedResume
        
        // Update language manager
        LanguageManager.shared.setLanguage(language)
    }
    
    // Get available language options
    var availableLanguages: [SupportedLanguage] {
        SupportedLanguage.allCases.filter { lang in
            !supportedLanguages.contains(lang)
        }
    }
    
    // Current display language
    var currentLanguage: SupportedLanguage {
        SupportedLanguage.allCases.first { $0.rawValue == resume.currentLanguage } ?? .english
    }
}
