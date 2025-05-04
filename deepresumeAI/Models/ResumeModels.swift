import SwiftUI
import Foundation

struct ResumeModels {
    enum TemplateType: String, CaseIterable, Codable, Identifiable {
        case modern = "modern"
        case classic = "classic"
        case creative = "creative"
        case professional = "professional"
        case minimal = "minimal"
        
        var id: Self { self }
        
        var primaryColor: Color {
            switch self {
            case .modern: return Color("6441A5")
            case .classic: return Color.blue
            case .creative: return Color("FF5F6D")
            case .professional: return Color("134E5E")
            case .minimal: return Color("8E2DE2")
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .modern: return Color("2a0845")
            case .classic: return Color.blue.opacity(0.7)
            case .creative: return Color("FFC371") 
            case .professional: return Color("71B280")
            case .minimal: return Color("4A00E0")
            }
        }
        
        var displayName: String {
            self.rawValue.capitalized
        }
        
        var thumbnailName: String {
            "template-\(rawValue)"
        }
    }
    
    class TemplateManager: ObservableObject {
        @Published var templates: [TemplateType] = TemplateType.allCases
    }
} 