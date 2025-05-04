import Foundation

struct AISuggestions: Codable {
    var contentImprovements: [String]
    var keywordSuggestions: [String]
    var formattingTips: [String]
    var overallScore: Double
    var jobSpecificSuggestions: [String]
    var careerPathRecommendations: [String]
    var targetedIndustryInsights: [String]
    
    init(contentImprovements: [String] = [],
         keywordSuggestions: [String] = [],
         formattingTips: [String] = [],
         overallScore: Double = 0.0,
         jobSpecificSuggestions: [String] = [],
         careerPathRecommendations: [String] = [],
         targetedIndustryInsights: [String] = []) {
        self.contentImprovements = contentImprovements
        self.keywordSuggestions = keywordSuggestions
        self.formattingTips = formattingTips
        self.overallScore = overallScore
        self.jobSpecificSuggestions = jobSpecificSuggestions
        self.careerPathRecommendations = careerPathRecommendations
        self.targetedIndustryInsights = targetedIndustryInsights
    }
} 