import Foundation
import SwiftUI

class DeepSeekService {
    private let apiKey = "sk-df169ce80aa44c9cbf72649800c5de46"
    private let baseURL = "https://api.deepseek.com/v1"
    
    enum APIEndpoint {
        case completions
        case suggestions
        case analyze
        
        var path: String {
            switch self {
            case .completions:
                return "/chat/completions"
            case .suggestions:
                return "/resume/suggestions"
            case .analyze:
                return "/resume/analyze"
            }
        }
    }
    
    // Generic request method
    private func makeRequest<T: Decodable>(endpoint: APIEndpoint, 
                                         body: [String: Any],
                                         completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(NSError(domain: "DeepSeekService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "DeepSeekService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch {
                // Try to get error message from response
                if let errorResponse = try? JSONDecoder().decode(DeepSeekErrorResponse.self, from: data) {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "DeepSeekAPI", 
                                                    code: errorResponse.error.code ?? 0, 
                                                    userInfo: [NSLocalizedDescriptionKey: errorResponse.error.message ?? "Unknown error"])))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    // Generate AI content for resume improvement
    func generateAIContent(resume: Resume, 
                          jobDescription: String, 
                          completion: @escaping (Result<AISuggestions, Error>) -> Void) {
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an AI resume assistant that provides professional resume improvement suggestions."
                ],
                [
                    "role": "user",
                    "content": "I need suggestions to improve my resume for this job description: \(jobDescription). Here's my current resume: \(resume.dictionaryRepresentation)"
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        makeRequest(endpoint: .completions, body: body) { (result: Result<DeepSeekChatResponse, Error>) in
            switch result {
            case .success(let response):
                // Process the response to create AISuggestions object
                if let content = response.choices.first?.message.content {
                    // Parse the content to extract suggestions
                    let suggestions = self.parseContentForSuggestions(content)
                    completion(.success(suggestions))
                } else {
                    completion(.failure(NSError(domain: "DeepSeekService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No content in response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Analyze resume for ATS compliance
    func analyzeATSCompliance(resume: Resume, 
                             jobDescription: String, 
                             completion: @escaping (Result<ATSAnalysis, Error>) -> Void) {
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an AI ATS (Applicant Tracking System) analyzer. Score the resume on a scale of 0-100 based on ATS compatibility with the job description, and provide specific improvements."
                ],
                [
                    "role": "user",
                    "content": "Score this resume for ATS compatibility with this job description: \(jobDescription). Here's my resume: \(resume.dictionaryRepresentation)"
                ]
            ],
            "temperature": 0.3,
            "max_tokens": 1000
        ]
        
        makeRequest(endpoint: .completions, body: body) { (result: Result<DeepSeekChatResponse, Error>) in
            switch result {
            case .success(let response):
                if let content = response.choices.first?.message.content {
                    // Parse the content to extract ATS analysis
                    let analysis = self.parseContentForATSAnalysis(content)
                    completion(.success(analysis))
                } else {
                    completion(.failure(NSError(domain: "DeepSeekService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No content in response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Helper methods to parse AI responses
    private func parseContentForSuggestions(_ content: String) -> AISuggestions {
        // Simple parsing logic to extract suggestions from AI response
        var keywordSuggestions: [String] = []
        var contentImprovements: [String] = []
        var formattingTips: [String] = []
        
        // Extract keywords and improvements from the content
        // This is a simplified implementation - in a real app, you might use regex or more sophisticated parsing
        
        let lines = content.components(separatedBy: "\n")
        var currentSection: String?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.contains("Keywords") || trimmedLine.contains("KEYWORDS") {
                currentSection = "keywords"
                continue
            } else if trimmedLine.contains("Improvements") || trimmedLine.contains("IMPROVEMENTS") || trimmedLine.contains("Suggestions") {
                currentSection = "improvements"
                continue
            } else if trimmedLine.contains("Formatting") || trimmedLine.contains("FORMATTING") || trimmedLine.contains("Format") {
                currentSection = "formatting"
                continue
            }
            
            // Check if line starts with bullet points or numbers
            if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") || trimmedLine.hasPrefix("*") || trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) != nil {
                // Remove bullet points or numbers
                var cleanedLine = trimmedLine
                if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") || trimmedLine.hasPrefix("*") {
                    cleanedLine = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
                } else if trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) != nil {
                    if let range = trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) {
                        cleanedLine = String(trimmedLine[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                }
                
                if currentSection == "keywords" && !cleanedLine.isEmpty {
                    keywordSuggestions.append(cleanedLine)
                } else if currentSection == "improvements" && !cleanedLine.isEmpty {
                    contentImprovements.append(cleanedLine)
                } else if currentSection == "formatting" && !cleanedLine.isEmpty {
                    formattingTips.append(cleanedLine)
                }
            }
        }
        
        // If no clear sections were found, make a best effort to classify content
        if keywordSuggestions.isEmpty && contentImprovements.isEmpty && formattingTips.isEmpty {
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty || trimmedLine.count < 5 { continue }
                
                // Short phrases are likely keywords
                if trimmedLine.count < 30 && !trimmedLine.contains(".") {
                    keywordSuggestions.append(trimmedLine)
                } else if trimmedLine.count > 30 {
                    // Check if it's a formatting tip
                    if trimmedLine.lowercased().contains("format") || 
                       trimmedLine.lowercased().contains("layout") || 
                       trimmedLine.lowercased().contains("font") ||
                       trimmedLine.lowercased().contains("spacing") {
                        formattingTips.append(trimmedLine)
                    } else {
                        // Longer phrases are likely improvement suggestions
                        contentImprovements.append(trimmedLine)
                    }
                }
            }
        }
        
        // Calculate a simple overall score based on number of suggestions
        let totalSuggestions = contentImprovements.count + keywordSuggestions.count + formattingTips.count
        let overallScore = min(85.0, max(40.0, 100.0 - (Double(totalSuggestions) * 2.5)))
        
        return AISuggestions(
            contentImprovements: contentImprovements,
            keywordSuggestions: keywordSuggestions,
            formattingTips: formattingTips,
            overallScore: overallScore
        )
    }
    
    private func parseContentForATSAnalysis(_ content: String) -> ATSAnalysis {
        // Extract ATS score and suggestions from the AI response
        var score: Double = 0
        var suggestions: [String] = []
        
        let lines = content.components(separatedBy: "\n")
        
        // Try to find score
        for line in lines {
            if let scoreRange = line.range(of: "\\b([0-9]{1,3})\\b", options: .regularExpression) {
                let scoreString = String(line[scoreRange])
                if let extractedScore = Double(scoreString), extractedScore <= 100 {
                    score = extractedScore
                    break
                }
            }
        }
        
        // Extract suggestions
        var inSuggestionsSection = false
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.contains("Suggestions") || trimmedLine.contains("Improvements") || trimmedLine.contains("Recommendations") {
                inSuggestionsSection = true
                continue
            }
            
            if inSuggestionsSection && (trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") || trimmedLine.hasPrefix("*") || trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) != nil) {
                // Remove bullet points or numbers
                var cleanedLine = trimmedLine
                if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") || trimmedLine.hasPrefix("*") {
                    cleanedLine = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
                } else if trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) != nil {
                    if let range = trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) {
                        cleanedLine = String(trimmedLine[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                }
                
                if !cleanedLine.isEmpty {
                    suggestions.append(cleanedLine)
                }
            }
        }
        
        // If no clear suggestions were found, look for sentences that sound like suggestions
        if suggestions.isEmpty {
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty || trimmedLine.count < 10 { continue }
                
                // Look for sentences that start with action verbs or contain should/could/would
                if trimmedLine.range(of: "^(Add|Include|Consider|Enhance|Improve|Update|Remove|Change|Make sure|Ensure)", options: .regularExpression) != nil ||
                   trimmedLine.contains("should") || trimmedLine.contains("could") || trimmedLine.contains("would") {
                    suggestions.append(trimmedLine)
                }
            }
        }
        
        return ATSAnalysis(
            score: score,
            suggestions: suggestions
        )
    }
    
    // AI Resume Tailoring - automatically adjust resume content for specific job
    func tailorResumeForJob(resume: Resume, 
                           jobDescription: String,
                           completion: @escaping (Result<Resume, Error>) -> Void) {
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an AI resume tailoring specialist that creates job-specific versions of resumes. Adjust the content to highlight relevant experiences and skills for the specific job."
                ],
                [
                    "role": "user",
                    "content": "Tailor this resume specifically for this job description: \(jobDescription). Here's my current resume: \(resume.dictionaryRepresentation)"
                ]
            ],
            "temperature": 0.4,
            "max_tokens": 1500
        ]
        
        makeRequest(endpoint: .completions, body: body) { (result: Result<DeepSeekChatResponse, Error>) in
            switch result {
            case .success(let response):
                if let content = response.choices.first?.message.content {
                    // Parse the content to create a tailored resume
                    let tailoredResume = self.parseTailoredResume(content, originalResume: resume)
                    completion(.success(tailoredResume))
                } else {
                    completion(.failure(NSError(domain: "DeepSeekService", code: 0, 
                                        userInfo: [NSLocalizedDescriptionKey: "No content in response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Generate dynamic content suggestions based on industry/role
    func generateIndustrySpecificSuggestions(resume: Resume,
                                           targetIndustry: String,
                                           targetRole: String,
                                           completion: @escaping (Result<AISuggestions, Error>) -> Void) {
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an industry specialist career advisor. Provide tailored recommendations for skills, experiences, and formatting that are specifically relevant for the target industry and role."
                ],
                [
                    "role": "user",
                    "content": "I want to target the \(targetIndustry) industry for a \(targetRole) position. Here's my current resume: \(resume.dictionaryRepresentation). Provide specific suggestions for content, keywords, formatting, and industry-specific insights."
                ]
            ],
            "temperature": 0.5,
            "max_tokens": 1500
        ]
        
        makeRequest(endpoint: .completions, body: body) { (result: Result<DeepSeekChatResponse, Error>) in
            switch result {
            case .success(let response):
                if let content = response.choices.first?.message.content {
                    // Parse the content for industry-specific suggestions
                    let suggestions = self.parseIndustrySpecificSuggestions(content)
                    completion(.success(suggestions))
                } else {
                    completion(.failure(NSError(domain: "DeepSeekService", code: 0, 
                                        userInfo: [NSLocalizedDescriptionKey: "No content in response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Generate career path recommendations
    func generateCareerPathRecommendations(resume: Resume,
                                         careerGoals: [String],
                                         completion: @escaping (Result<[CareerPathRecommendation], Error>) -> Void) {
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an AI career development advisor specializing in professional growth paths. Suggest skills, certifications, and learning paths to help achieve career goals."
                ],
                [
                    "role": "user",
                    "content": "Based on my resume and career goals, suggest what skills and certifications I should pursue next. Resume: \(resume.dictionaryRepresentation). Career goals: \(careerGoals.joined(separator: ", "))"
                ]
            ],
            "temperature": 0.4,
            "max_tokens": 1000
        ]
        
        makeRequest(endpoint: .completions, body: body) { (result: Result<DeepSeekChatResponse, Error>) in
            switch result {
            case .success(let response):
                if let content = response.choices.first?.message.content {
                    // Parse the recommendations
                    let recommendations = self.parseCareerRecommendations(content)
                    completion(.success(recommendations))
                } else {
                    completion(.failure(NSError(domain: "DeepSeekService", code: 0, 
                                        userInfo: [NSLocalizedDescriptionKey: "No content in response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Translate resume content to another language
    func translateResume(resume: Resume,
                       targetLanguage: SupportedLanguage,
                       completion: @escaping (Result<LocalizedResumeContent, Error>) -> Void) {
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an expert translator specializing in professional documents and resumes. Translate the content maintaining professional tone and industry terminology."
                ],
                [
                    "role": "user",
                    "content": "Translate these resume sections to \(targetLanguage.displayName). Please return ONLY the translated content in a structured format. Job titles: \(resume.experiences.map { $0.jobTitle }.joined(separator: " | ")). Responsibilities: \(resume.experiences.flatMap { $0.responsibilities }.joined(separator: " | ")). Skills: \(resume.skills.map { $0.name }.joined(separator: " | ")). Education: \(resume.education.map { "\($0.degree) at \($0.institution)" }.joined(separator: " | "))"
                ]
            ],
            "temperature": 0.3,
            "max_tokens": 1000
        ]
        
        makeRequest(endpoint: .completions, body: body) { (result: Result<DeepSeekChatResponse, Error>) in
            switch result {
            case .success(let response):
                if let content = response.choices.first?.message.content {
                    // Parse the translated content
                    let localizedContent = self.parseTranslatedContent(content, language: targetLanguage)
                    completion(.success(localizedContent))
                } else {
                    completion(.failure(NSError(domain: "DeepSeekService", code: 0, 
                                        userInfo: [NSLocalizedDescriptionKey: "No content in response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helper Parsing Methods
    
    private func parseTailoredResume(_ content: String, originalResume: Resume) -> Resume {
        // Create a copy of the original resume to modify
        var tailoredResume = originalResume
        
        // Extract the sections from AI response
        let lines = content.components(separatedBy: "\n")
        var currentSection: String?
        var experienceIdx = 0
        var newResponsibilities: [String] = []
        var newSkills: [Skill] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.contains("EXPERIENCE") || trimmedLine.contains("Experience") {
                currentSection = "experience"
                experienceIdx = 0
                continue
            } else if trimmedLine.contains("SKILLS") || trimmedLine.contains("Skills") {
                currentSection = "skills"
                continue
            } else if trimmedLine.contains("RESPONSIBILITIES") || trimmedLine.contains("Responsibilities") {
                currentSection = "responsibilities"
                newResponsibilities = []
                continue
            }
            
            if currentSection == "experience" && trimmedLine.contains("•") && experienceIdx < tailoredResume.experiences.count {
                let responsibility = trimmedLine.replacingOccurrences(of: "• ", with: "")
                                             .replacingOccurrences(of: "•", with: "")
                if !responsibility.isEmpty {
                    if newResponsibilities.count < 5 { // Limit to 5 responsibilities
                        newResponsibilities.append(responsibility)
                    }
                }
            } else if currentSection == "responsibilities" && experienceIdx < tailoredResume.experiences.count {
                if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") {
                    let responsibility = trimmedLine.replacingOccurrences(of: "- ", with: "")
                                                 .replacingOccurrences(of: "• ", with: "")
                    if !responsibility.isEmpty {
                        newResponsibilities.append(responsibility)
                    }
                }
            } else if currentSection == "skills" {
                if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") {
                    let skillName = trimmedLine.replacingOccurrences(of: "- ", with: "")
                                            .replacingOccurrences(of: "• ", with: "")
                    if !skillName.isEmpty {
                        // Check if the skill already exists
                        let skillExists = tailoredResume.skills.contains { $0.name.lowercased() == skillName.lowercased() }
                        if !skillExists {
                            newSkills.append(Skill(name: skillName, level: "Intermediate"))
                        }
                    }
                }
            }
        }
        
        // Update responsibilities if we found any
        if !newResponsibilities.isEmpty && experienceIdx < tailoredResume.experiences.count {
            tailoredResume.experiences[experienceIdx].responsibilities = newResponsibilities
        }
        
        // Add new skills if found
        if !newSkills.isEmpty {
            tailoredResume.skills.append(contentsOf: newSkills)
        }
        
        // Update target info
        if tailoredResume.targetRole == nil {
            let jobTitle = extractJobTitle(from: content)
            tailoredResume.targetRole = jobTitle
        }
        
        return tailoredResume
    }
    
    private func parseIndustrySpecificSuggestions(_ content: String) -> AISuggestions {
        var contentImprovements: [String] = []
        var keywordSuggestions: [String] = []
        var formattingTips: [String] = []
        var jobSpecificSuggestions: [String] = []
        var careerPathRecommendations: [String] = []
        var targetedIndustryInsights: [String] = []
        
        // Parse the content from AI response
        let lines = content.components(separatedBy: "\n")
        var currentSection: String?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.contains("CONTENT IMPROVEMENTS") || trimmedLine.contains("Content Improvements") {
                currentSection = "content"
                continue
            } else if trimmedLine.contains("KEYWORDS") || trimmedLine.contains("Keywords") {
                currentSection = "keywords"
                continue
            } else if trimmedLine.contains("FORMATTING") || trimmedLine.contains("Formatting") {
                currentSection = "formatting"
                continue
            } else if trimmedLine.contains("INDUSTRY INSIGHTS") || trimmedLine.contains("Industry Insights") {
                currentSection = "insights"
                continue
            } else if trimmedLine.contains("JOB-SPECIFIC") || trimmedLine.contains("Job-Specific") {
                currentSection = "jobSpecific"
                continue
            } else if trimmedLine.contains("CAREER PATH") || trimmedLine.contains("Career Path") {
                currentSection = "careerPath"
                continue
            }
            
            // Extract items
            if currentSection != nil && (trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") || 
                                      trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) != nil) {
                var cleanedLine = trimmedLine
                if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") {
                    cleanedLine = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
                } else if trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) != nil {
                    if let range = trimmedLine.range(of: "^\\d+\\.\\s", options: .regularExpression) {
                        cleanedLine = String(trimmedLine[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                }
                
                if !cleanedLine.isEmpty {
                    switch currentSection {
                    case "content": contentImprovements.append(cleanedLine)
                    case "keywords": keywordSuggestions.append(cleanedLine)
                    case "formatting": formattingTips.append(cleanedLine)
                    case "insights": targetedIndustryInsights.append(cleanedLine)
                    case "jobSpecific": jobSpecificSuggestions.append(cleanedLine)
                    case "careerPath": careerPathRecommendations.append(cleanedLine)
                    default: break
                    }
                }
            }
        }
        
        // Calculate a score based on the number of suggestions
        let totalItems = contentImprovements.count + keywordSuggestions.count + formattingTips.count + 
                        jobSpecificSuggestions.count + targetedIndustryInsights.count
        let score = min(95.0, max(50.0, 100.0 - Double(totalItems) * 1.5))
        
        return AISuggestions(
            contentImprovements: contentImprovements,
            keywordSuggestions: keywordSuggestions,
            formattingTips: formattingTips,
            overallScore: score,
            jobSpecificSuggestions: jobSpecificSuggestions,
            careerPathRecommendations: careerPathRecommendations,
            targetedIndustryInsights: targetedIndustryInsights
        )
    }
    
    private func parseCareerRecommendations(_ content: String) -> [CareerPathRecommendation] {
        var recommendations: [CareerPathRecommendation] = []
        
        // Parse the content from AI response
        let lines = content.components(separatedBy: "\n")
        var currentSkill: String?
        var currentCert: String?
        var currentTime: String = "3 months"
        var currentRelevance: Double = 0.7
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty { continue }
            
            // Look for skill/certification patterns
            if trimmedLine.hasPrefix("Skill:") || trimmedLine.hasPrefix("SKILL:") {
                // Save previous recommendation if exists
                if let skill = currentSkill {
                    recommendations.append(CareerPathRecommendation(
                        skillName: skill,
                        certificationName: currentCert,
                        estimatedTimeToAcquire: currentTime,
                        relevanceScore: currentRelevance
                    ))
                }
                
                // Start new recommendation
                currentSkill = trimmedLine.replacingOccurrences(of: "Skill:", with: "")
                                        .replacingOccurrences(of: "SKILL:", with: "")
                                        .trimmingCharacters(in: .whitespaces)
                currentCert = nil
                currentTime = "3 months"
                currentRelevance = 0.7
                
            } else if trimmedLine.hasPrefix("Certification:") || trimmedLine.hasPrefix("CERTIFICATION:") {
                currentCert = trimmedLine.replacingOccurrences(of: "Certification:", with: "")
                                       .replacingOccurrences(of: "CERTIFICATION:", with: "")
                                       .trimmingCharacters(in: .whitespaces)
                
            } else if trimmedLine.hasPrefix("Time:") || trimmedLine.hasPrefix("TIME:") || 
                    trimmedLine.contains("estimated time") {
                currentTime = trimmedLine.replacingOccurrences(of: "Time:", with: "")
                                       .replacingOccurrences(of: "TIME:", with: "")
                                       .replacingOccurrences(of: "Estimated time:", with: "")
                                       .replacingOccurrences(of: "Estimated Time:", with: "")
                                       .trimmingCharacters(in: .whitespaces)
                
            } else if trimmedLine.hasPrefix("Relevance:") || trimmedLine.hasPrefix("RELEVANCE:") {
                let relevanceText = trimmedLine.replacingOccurrences(of: "Relevance:", with: "")
                                            .replacingOccurrences(of: "RELEVANCE:", with: "")
                                            .trimmingCharacters(in: .whitespaces)
                
                // Try to extract a numerical value from text like "High (0.9)" or "8/10"
                if let range = relevanceText.range(of: "[0-9]\\.[0-9]", options: .regularExpression) {
                    let number = relevanceText[range]
                    currentRelevance = Double(String(number)) ?? 0.7
                } else if relevanceText.contains("High") || relevanceText.contains("high") {
                    currentRelevance = 0.9
                } else if relevanceText.contains("Medium") || relevanceText.contains("medium") {
                    currentRelevance = 0.6
                } else if relevanceText.contains("Low") || relevanceText.contains("low") {
                    currentRelevance = 0.3
                }
            }
        }
        
        // Add the last recommendation if it exists
        if let skill = currentSkill {
            recommendations.append(CareerPathRecommendation(
                skillName: skill,
                certificationName: currentCert,
                estimatedTimeToAcquire: currentTime,
                relevanceScore: currentRelevance
            ))
        }
        
        // If no structured recommendations were found, try a simpler approach
        if recommendations.isEmpty {
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty || trimmedLine.count < 3 { continue }
                
                if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") {
                    let cleanedLine = trimmedLine.replacingOccurrences(of: "- ", with: "")
                                              .replacingOccurrences(of: "• ", with: "")
                                              .trimmingCharacters(in: .whitespaces)
                    
                    if !cleanedLine.isEmpty {
                        recommendations.append(CareerPathRecommendation(skillName: cleanedLine))
                    }
                }
            }
        }
        
        return recommendations
    }
    
    private func parseTranslatedContent(_ content: String, language: SupportedLanguage) -> LocalizedResumeContent {
        var jobTitle = ""
        var responsibilities: [String] = []
        var skills: [String] = []
        var education = ""
        
        // Parse the content from AI response
        let lines = content.components(separatedBy: "\n")
        var currentSection: String?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.contains("JOB TITLES") || trimmedLine.contains("Job Titles") ||
               trimmedLine.contains("TITLE") || trimmedLine.contains("Title") {
                currentSection = "jobTitle"
                continue
            } else if trimmedLine.contains("RESPONSIBILITIES") || trimmedLine.contains("Responsibilities") {
                currentSection = "responsibilities"
                continue
            } else if trimmedLine.contains("SKILLS") || trimmedLine.contains("Skills") {
                currentSection = "skills"
                continue
            } else if trimmedLine.contains("EDUCATION") || trimmedLine.contains("Education") {
                currentSection = "education"
                continue
            }
            
            // Extract translated content
            if let section = currentSection {
                if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") {
                    let cleanedLine = trimmedLine.replacingOccurrences(of: "- ", with: "")
                                              .replacingOccurrences(of: "• ", with: "")
                                              .trimmingCharacters(in: .whitespaces)
                    
                    if !cleanedLine.isEmpty {
                        switch section {
                        case "responsibilities": responsibilities.append(cleanedLine)
                        case "skills": skills.append(cleanedLine)
                        default: break
                        }
                    }
                } else {
                    // For sections that might be a single line
                    switch section {
                    case "jobTitle": 
                        if jobTitle.isEmpty {
                            jobTitle = trimmedLine
                        }
                    case "education": 
                        if education.isEmpty {
                            education = trimmedLine
                        } else {
                            education += "\n" + trimmedLine
                        }
                    default: break
                    }
                }
            }
        }
        
        return LocalizedResumeContent(
            language: language,
            jobTitle: jobTitle,
            responsibilities: responsibilities,
            skills: skills,
            education: education
        )
    }
    
    private func extractJobTitle(from content: String) -> String? {
        // Try to find job title in the response
        let lines = content.components(separatedBy: "\n")
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty { continue }
            
            // Look for common job title patterns
            if trimmedLine.contains("Position:") || trimmedLine.contains("Job Title:") || 
               trimmedLine.contains("Role:") {
                let parts = trimmedLine.components(separatedBy: ":")
                if parts.count > 1 {
                    return parts[1].trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        return nil
    }
}

// Response models
struct DeepSeekChatResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    
    struct Choice: Decodable {
        let index: Int
        let message: Message
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Decodable {
        let role: String
        let content: String
    }
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

struct DeepSeekErrorResponse: Decodable {
    let error: ErrorDetails
    
    struct ErrorDetails: Decodable {
        let message: String?
        let type: String?
        let code: Int?
    }
}

// Analysis models
struct ATSAnalysis {
    let score: Double
    let suggestions: [String]
} 
 