
import Foundation
import NaturalLanguage

class ATSAnalyzer {
    // MARK: - Configuration
    struct ATSConfig {
        var keywordWeight: Double = 0.5
        var skillsWeight: Double = 0.3
        var experienceWeight: Double = 0.2
        var minimumMatchThreshold: Double = 0.6
    }
    
    // MARK: - Analysis Result
    struct ATSResult {
        var score: Double // 0.0 - 1.0
        var missingKeywords: [String]
        var matchedKeywords: [String]
        var skillGaps: [String]
        var suggestions: [String]
        var resumeSections: [SectionAnalysis]
        
        struct SectionAnalysis {
            let name: String
            let score: Double
            let suggestions: [String]
        }
    }
    
    // MARK: - Public Methods
    
    /// Analyzes resume against job description for ATS compatibility
    func analyze(resume: Resume, jobDescription: String, config: ATSConfig = ATSConfig()) -> ATSResult {
        // Extract keywords from job description
        let jobKeywords = extractKeywords(from: jobDescription)
        let requiredSkills = extractSkills(from: jobDescription)
        
        // Analyze resume content
        let resumeText = generateResumeText(resume: resume)
        let resumeKeywords = extractKeywords(from: resumeText)
        let resumeSkills = resume.skills.map { $0.name.lowercased() }
        
        // Calculate matches
        let keywordMatches = calculateMatches(jobKeywords: jobKeywords, resumeKeywords: resumeKeywords)
        let skillMatches = calculateSkillMatches(requiredSkills: requiredSkills, resumeSkills: resumeSkills)
        
        // Calculate experience match (simplified)
        let experienceMatch = calculateExperienceMatch(resume: resume, jobDescription: jobDescription)
        
        // Calculate composite score
        let score = (keywordMatches.score * config.keywordWeight) +
                   (skillMatches.score * config.skillsWeight) +
                   (experienceMatch * config.experienceWeight)
        
        // Generate suggestions
        let suggestions = generateSuggestions(
            missingKeywords: keywordMatches.missing,
            missingSkills: skillMatches.missing,
            experienceMatch: experienceMatch
        )
        
        // Section analysis
        let sections = analyzeSections(resume: resume, jobKeywords: jobKeywords)
        
        return ATSResult(
            score: score,
            missingKeywords: keywordMatches.missing,
            matchedKeywords: keywordMatches.matched,
            skillGaps: skillMatches.missing,
            suggestions: suggestions,
            resumeSections: sections
        )
    }
    
    // MARK: - Private Methods
    
    private func extractKeywords(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text.lowercased()
        
        var keywords = [String]()
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let excludedTags: [NLTag] = [.determiner, .pronoun, .preposition, .conjunction, .adverb]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                            unit: .word,
                            scheme: .lexicalClass,
                            options: options) { tag, tokenRange in
            if let tag = tag, !excludedTags.contains(tag) {
                let word = String(text[tokenRange])
                if word.count > 3 { // Filter out short words
                    keywords.append(word)
                }
            }
            return true
        }
        
        return Array(Set(keywords)) // Remove duplicates
    }
    
    private func extractSkills(from text: String) -> [String] {
        // Look for phrases like "knowledge of X", "experience with Y", "Z skills"
        let skillPatterns = [
            "knowledge of (\\w+)",
            "experience with (\\w+)",
            "proficiency in (\\w+)",
            "(\\w+) skills",
            "familiarity with (\\w+)"
        ]
        
        var skills = [String]()
        let textLower = text.lowercased()
        
        for pattern in skillPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let matches = regex.matches(in: textLower,
                                           range: NSRange(textLower.startIndex..., in: textLower))
                
                for match in matches where match.numberOfRanges > 1 {
                    if let range = Range(match.range(at: 1), in: textLower) {
                        let skill = String(textLower[range])
                        skills.append(skill)
                    }
                }
            }
        }
        
        return Array(Set(skills)) // Remove duplicates
    }
    
    private func generateResumeText(resume: Resume) -> String {
        var text = ""
        
        // Personal Info
        text += "\(resume.personalInfo.name)\n"
        text += "\(resume.personalInfo.email)\n"
        text += "\(resume.personalInfo.phone)\n\n"
        
        // Experiences
        text += "EXPERIENCE\n"
        for exp in resume.experiences {
            text += "\(exp.jobTitle) at \(exp.company)\n"
            text += "\(exp.duration)\n"
            text += exp.responsibilities.joined(separator: "\n") + "\n\n"
        }
        
        // Education
        text += "EDUCATION\n"
        for edu in resume.education {
            text += "\(edu.degree) at \(edu.institution)\n"
            text += "\(edu.year)\n\n"
        }
        
        // Skills
        text += "SKILLS\n"
        text += resume.skills.map { $0.name }.joined(separator: ", ")
        
        return text
    }
    
    private func calculateMatches(jobKeywords: [String], resumeKeywords: [String]) -> (score: Double, matched: [String], missing: [String]) {
        let matched = Set(jobKeywords).intersection(Set(resumeKeywords))
        let missing = Set(jobKeywords).subtracting(Set(resumeKeywords))
        
        let score = jobKeywords.isEmpty ? 1.0 : Double(matched.count) / Double(jobKeywords.count)
        
        return (score, Array(matched), Array(missing))
    }
    
    private func calculateSkillMatches(requiredSkills: [String], resumeSkills: [String]) -> (score: Double, matched: [String], missing: [String]) {
        guard !requiredSkills.isEmpty else { return (1.0, [], []) }
        
        let matched = Set(requiredSkills).intersection(Set(resumeSkills))
        let missing = Set(requiredSkills).subtracting(Set(resumeSkills))
        
        let score = Double(matched.count) / Double(requiredSkills.count)
        
        return (score, Array(matched), Array(missing))
    }
    
    private func calculateExperienceMatch(resume: Resume, jobDescription: String) -> Double {
        // Simple implementation - count years of experience matching job title keywords
        let jobTitleKeywords = extractKeywords(from: jobDescription)
        var relevantExperience = 0
        
        for exp in resume.experiences {
            let expKeywords = extractKeywords(from: exp.jobTitle)
            if !Set(jobTitleKeywords).isDisjoint(with: expKeywords) {
                // Very simplified - assumes duration contains years
                if exp.duration.contains("year") {
                    relevantExperience += 1
                }
            }
        }
        
        // Normalize to 0-1 range (assuming 5+ years is ideal)
        return min(Double(relevantExperience) / 5.0, 1.0)
    }
    
    private func generateSuggestions(missingKeywords: [String],
                                   missingSkills: [String],
                                   experienceMatch: Double) -> [String] {
        var suggestions = [String]()
        
        if !missingKeywords.isEmpty {
            let topKeywords = missingKeywords.prefix(5)
            suggestions.append("Add these keywords: \(topKeywords.joined(separator: ", "))")
        }
        
        if !missingSkills.isEmpty {
            suggestions.append("Consider adding these skills: \(missingSkills.joined(separator: ", "))")
        }
        
        if experienceMatch < 0.5 {
            suggestions.append("Highlight more relevant experience matching the job requirements")
        }
        
        if suggestions.isEmpty {
            suggestions.append("Your resume looks well-optimized for this position!")
        }
        
        return suggestions
    }
    
    private func analyzeSections(resume: Resume, jobKeywords: [String]) -> [ATSResult.SectionAnalysis] {
        var sections = [ATSResult.SectionAnalysis]()
        
        // Analyze Experience section
        let expText = resume.experiences.map { "\($0.jobTitle) \($0.responsibilities.joined(separator: " "))" }.joined(separator: " ")
        let expKeywords = extractKeywords(from: expText)
        let expMatches = calculateMatches(jobKeywords: jobKeywords, resumeKeywords: expKeywords)
        sections.append(.init(
            name: "Experience",
            score: expMatches.score,
            suggestions: expMatches.missing.isEmpty ? [] : ["Add more relevant keywords to your experience descriptions"]
        ))
        
        // Analyze Skills section
        let skillsText = resume.skills.map { $0.name }.joined(separator: " ")
        let skillsKeywords = extractKeywords(from: skillsText)
        let skillsMatches = calculateMatches(jobKeywords: jobKeywords, resumeKeywords: skillsKeywords)
        sections.append(.init(
            name: "Skills",
            score: skillsMatches.score,
            suggestions: skillsMatches.missing.isEmpty ? [] : ["Add missing skills: \(skillsMatches.missing.prefix(3).joined(separator: ", "))"]
        ))
        
        return sections
    }
}
