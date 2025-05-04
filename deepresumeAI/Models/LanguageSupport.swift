import Foundation

enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case chinese = "zh"
    case japanese = "ja"
    case portuguese = "pt"
    case russian = "ru"
    case arabic = "ar"
    case hindi = "hi"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .portuguese: return "Português"
        case .russian: return "Русский"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        }
    }
    
    var flagEmoji: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .portuguese: return "🇵🇹"
        case .russian: return "🇷🇺"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        }
    }
}

struct LocalizedResumeContent {
    let language: SupportedLanguage
    var jobTitle: String
    var responsibilities: [String]
    var skills: [String]
    var education: String
    
    init(language: SupportedLanguage, 
         jobTitle: String = "", 
         responsibilities: [String] = [], 
         skills: [String] = [], 
         education: String = "") {
        self.language = language
        self.jobTitle = jobTitle
        self.responsibilities = responsibilities
        self.skills = skills
        self.education = education
    }
}

class LanguageManager {
    static let shared = LanguageManager()
    
    var currentLanguage: SupportedLanguage = .english
    private var localizedContents: [String: LocalizedResumeContent] = [:]
    
    private init() {}
    
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
    }
    
    func saveLocalizedContent(resumeId: String, content: LocalizedResumeContent) {
        let key = "\(resumeId)_\(content.language.rawValue)"
        localizedContents[key] = content
    }
    
    func getLocalizedContent(resumeId: String, language: SupportedLanguage) -> LocalizedResumeContent? {
        let key = "\(resumeId)_\(language.rawValue)"
        return localizedContents[key]
    }
} 