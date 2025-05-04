import SwiftUI
import PDFKit
import UniformTypeIdentifiers

@MainActor
class UploadViewModel: ObservableObject {
    @Published var resumes: [Resume] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        loadResumes()
    }
    
    func uploadResume(from url: URL) async {
        isLoading = true
        error = nil
        
        do {
            let data = try Data(contentsOf: url)
            guard let pdfDocument = PDFDocument(data: data) else {
                throw NSError(domain: "ResumeUpload", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid PDF file"])
            }
            
            let fileName = url.lastPathComponent
            let textContent = pdfDocument.string ?? ""
            
            // Extract skills as Skill objects
            let skillNames = extractSkills(from: textContent)
            let skills = skillNames.map { Skill(name: $0) }
            
            // Create a new resume
            let resume = Resume(
                personalInfo: PersonalInfo(),
                experiences: extractExperience(from: textContent),
                education: extractEducation(from: textContent),
                skills: skills,
                selectedTemplate: "modern",
                lastModified: Date(),
                careerGoals: [],
                supportedLanguages: ["en"],
                currentLanguage: "en",
                fileName: fileName,
                textContent: textContent,
                pdfData: data,
                summary: extractSummary(from: textContent)
            )
            
            // Add to resumes array
            resumes.append(resume)
            saveResumes()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func loadResumes() {
        if let data = UserDefaults.standard.data(forKey: "SavedResumes"),
           let decoded = try? JSONDecoder().decode([Resume].self, from: data) {
            resumes = decoded
        }
    }
    
    private func saveResumes() {
        if let encoded = try? JSONEncoder().encode(resumes) {
            UserDefaults.standard.set(encoded, forKey: "SavedResumes")
        }
    }
    
    // Helper methods to extract information from PDF text
    private func extractSkills(from text: String) -> [String] {
        var skills: [String] = []
        
        // Look for skills section
        if let skillsRange = text.range(of: "SKILLS|Skills|Technical Skills|Professional Skills", options: .regularExpression) {
            let skillsText = String(text[skillsRange.upperBound...])
            
            // Split by common delimiters
            let skillLines = skillsText.components(separatedBy: .newlines)
            
            for line in skillLines {
                // Skip empty lines and section headers
                guard !line.isEmpty,
                      !line.contains("EXPERIENCE"),
                      !line.contains("EDUCATION"),
                      !line.contains("SUMMARY") else { break }
                
                // Split by commas, semicolons, or bullets
                let lineSkills = line.components(separatedBy: CharacterSet(charactersIn: ",;•"))
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                skills.append(contentsOf: lineSkills)
            }
        }
        
        // If no skills section found, look for skills mentioned throughout the document
        if skills.isEmpty {
            let words = text.components(separatedBy: .whitespacesAndNewlines)
            let commonSkills = ["Python", "Java", "JavaScript", "Swift", "SQL", "HTML", "CSS", "React", "Angular", "Node.js", "AWS", "Azure", "Git", "Docker", "Kubernetes"]
            
            for word in words {
                if commonSkills.contains(word) && !skills.contains(word) {
                    skills.append(word)
                }
            }
        }
        
        return skills
    }
    
    private func extractExperience(from text: String) -> [Experience] {
        var experiences: [Experience] = []
        
        // Look for experience section
        if let expRange = text.range(of: "EXPERIENCE|Experience|Work Experience|Professional Experience", options: .regularExpression) {
            let expText = String(text[expRange.upperBound...])
            
            // Split into individual experiences
            let expSections = expText.components(separatedBy: "\n\n")
            
            for section in expSections {
                let lines = section.components(separatedBy: .newlines)
                guard lines.count >= 2 else { continue }
                
                // First line typically contains company and duration
                let headerLine = lines[0]
                let company = headerLine.components(separatedBy: "|").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let duration = headerLine.components(separatedBy: "|").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                // Second line typically contains job title
                let jobTitle = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Remaining lines are responsibilities
                var responsibilities: [String] = []
                for line in lines.dropFirst(2) {
                    let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedLine.isEmpty && !trimmedLine.contains("EDUCATION") {
                        responsibilities.append(trimmedLine.replacingOccurrences(of: "•", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                
                if !company.isEmpty && !jobTitle.isEmpty {
                    experiences.append(Experience(
                        jobTitle: jobTitle,
                        company: company,
                        duration: duration,
                        responsibilities: responsibilities
                    ))
                }
            }
        }
        
        return experiences
    }
    
    private func extractEducation(from text: String) -> [Education] {
        var education: [Education] = []
        
        // Look for education section
        if let eduRange = text.range(of: "EDUCATION|Education|Academic Background", options: .regularExpression) {
            let eduText = String(text[eduRange.upperBound...])
            
            // Split into individual education entries
            let eduSections = eduText.components(separatedBy: "\n\n")
            
            for section in eduSections {
                let lines = section.components(separatedBy: .newlines)
                guard lines.count >= 2 else { continue }
                
                // First line typically contains institution and year
                let headerLine = lines[0]
                let institution = headerLine.components(separatedBy: "|").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let year = headerLine.components(separatedBy: "|").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                // Second line typically contains degree
                let degree = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !institution.isEmpty && !degree.isEmpty {
                    education.append(Education(
                        degree: degree,
                        institution: institution,
                        year: year
                    ))
                }
            }
        }
        
        return education
    }
    
    private func extractSummary(from text: String) -> String {
        // Look for summary section
        if let summaryRange = text.range(of: "SUMMARY|Summary|Professional Summary|Profile", options: .regularExpression) {
            let summaryText = String(text[summaryRange.upperBound...])
            
            // Take the first paragraph as summary
            if let firstParagraph = summaryText.components(separatedBy: "\n\n").first {
                return firstParagraph.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // If no summary section found, generate one from the first few lines
        let lines = text.components(separatedBy: .newlines)
        let relevantLines = lines.prefix(5).filter { !$0.isEmpty }
        return relevantLines.joined(separator: " ")
    }
} 