import Foundation  // Add this import for UUID and Date
import SwiftUI

struct Resume: Identifiable, Codable {
    let id: UUID
    var personalInfo: PersonalInfo
    var experiences: [Experience]
    var education: [Education]
    var skills: [Skill]
    var selectedTemplate: String  // Template identifier
    var lastModified: Date
    var targetIndustry: String?
    var targetRole: String?
    var careerGoals: [String]
    var supportedLanguages: [String]
    var currentLanguage: String
    
    // New fields for PDF uploads
    var fileName: String?
    var textContent: String?
    var pdfData: Data?
    var summary: String?
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "id": id.uuidString,
            "personalInfo": [
                "name": personalInfo.name,
                "email": personalInfo.email,
                "phone": personalInfo.phone,
                "address": personalInfo.address,
                "linkedIn": personalInfo.linkedIn,
                "portfolio": personalInfo.portfolio
            ],
            "experiences": experiences.map { exp in
                [
                    "id": exp.id.uuidString,
                    "jobTitle": exp.jobTitle,
                    "company": exp.company,
                    "duration": exp.duration,
                    "responsibilities": exp.responsibilities
                ]
            },
            "education": education.map { edu in
                [
                    "id": edu.id.uuidString,
                    "degree": edu.degree,
                    "institution": edu.institution,
                    "year": edu.year
                ]
            },
            "skills": skills.map { skill in
                [
                    "id": skill.id.uuidString,
                    "name": skill.name,
                    "level": skill.level
                ]
            },
            "selectedTemplate": selectedTemplate,
            "lastModified": lastModified.timeIntervalSince1970,
            "targetIndustry": targetIndustry as Any,
            "targetRole": targetRole as Any,
            "careerGoals": careerGoals,
            "supportedLanguages": supportedLanguages,
            "currentLanguage": currentLanguage,
            "fileName": fileName as Any,
            "textContent": textContent as Any,
            "summary": summary as Any
        ]
    }
    
    init(id: UUID = UUID(),
         personalInfo: PersonalInfo = PersonalInfo(),
         experiences: [Experience] = [],
         education: [Education] = [],
         skills: [Skill] = [],
         selectedTemplate: String = "modern",  // Default template
         lastModified: Date = Date(),
         targetIndustry: String? = nil,
         targetRole: String? = nil,
         careerGoals: [String] = [],
         supportedLanguages: [String] = ["en"],
         currentLanguage: String = "en",
         fileName: String? = nil,
         textContent: String? = nil,
         pdfData: Data? = nil,
         summary: String? = nil) {
        self.id = id
        self.personalInfo = personalInfo
        self.experiences = experiences
        self.education = education
        self.skills = skills
        self.selectedTemplate = selectedTemplate
        self.lastModified = lastModified
        self.targetIndustry = targetIndustry
        self.targetRole = targetRole
        self.careerGoals = careerGoals
        self.supportedLanguages = supportedLanguages
        self.currentLanguage = currentLanguage
        self.fileName = fileName
        self.textContent = textContent
        self.pdfData = pdfData
        self.summary = summary
    }
    
    // Convenience getter for template type
    var templateType: ResumeModels.TemplateType {
        if let type = ResumeModels.TemplateType.allCases.first(where: { $0.rawValue == selectedTemplate }) {
            return type
        }
        return .modern // Default
    }
    
    // Get localized content if available
    func getLocalizedContent(for languageCode: String) -> LocalizedResumeContent? {
        guard let language = SupportedLanguage.allCases.first(where: { $0.rawValue == languageCode }) else {
            return nil
        }
        return LanguageManager.shared.getLocalizedContent(resumeId: id.uuidString, language: language)
    }
    
    // Add localized content
    mutating func addLocalizedContent(_ content: LocalizedResumeContent) {
        LanguageManager.shared.saveLocalizedContent(resumeId: id.uuidString, content: content)
        if !supportedLanguages.contains(content.language.rawValue) {
            supportedLanguages.append(content.language.rawValue)
        }
    }
    
    // Switch current language
    mutating func switchLanguage(to languageCode: String) {
        if supportedLanguages.contains(languageCode) {
            currentLanguage = languageCode
        }
    }
}

struct PersonalInfo: Codable {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var address: String = ""
    var linkedIn: String = ""
    var portfolio: String = ""
}

struct Experience: Codable, Identifiable {
    let id: UUID
    var jobTitle: String
    var company: String
    var duration: String
    var responsibilities: [String]
    
    init(id: UUID = UUID(),
         jobTitle: String = "",
         company: String = "",
         duration: String = "",
         responsibilities: [String] = []) {
        self.id = id
        self.jobTitle = jobTitle
        self.company = company
        self.duration = duration
        self.responsibilities = responsibilities
    }
}

struct Education: Codable, Identifiable {
    let id: UUID
    var degree: String
    var institution: String
    var year: String
    
    init(id: UUID = UUID(),
         degree: String = "",
         institution: String = "",
         year: String = "") {
        self.id = id
        self.degree = degree
        self.institution = institution
        self.year = year
    }
}

struct Skill: Codable, Identifiable {
    let id: UUID
    var name: String
    var level: String
    
    init(id: UUID = UUID(),
         name: String = "",
         level: String = "Intermediate") {
        self.id = id
        self.name = name
        self.level = level
    }
}

struct CareerPathRecommendation: Codable, Identifiable {
    let id: UUID
    var skillName: String
    var certificationName: String?
    var estimatedTimeToAcquire: String
    var relevanceScore: Double // 0-1 scale
    
    init(id: UUID = UUID(),
         skillName: String,
         certificationName: String? = nil,
         estimatedTimeToAcquire: String = "3 months",
         relevanceScore: Double = 0.5) {
        self.id = id
        self.skillName = skillName
        self.certificationName = certificationName
        self.estimatedTimeToAcquire = estimatedTimeToAcquire
        self.relevanceScore = relevanceScore
    }
}
