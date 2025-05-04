import Foundation
import SwiftUI

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var subscription: Subscription
    var preferredTemplates: [String]  // Changed to String to avoid TemplateType dependency
    var savedResumes: [UUID]
    var preferences: Preferences
    var lastActive: Date
    
    init(id: UUID = UUID(),
         name: String = "",
         email: String = "",
         subscription: Subscription = .free,
         preferredTemplates: [String] = ["modern", "professional"],
         savedResumes: [UUID] = [],
         preferences: Preferences = Preferences(),
         lastActive: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.subscription = subscription
        self.preferredTemplates = preferredTemplates
        self.savedResumes = savedResumes
        self.preferences = preferences
        self.lastActive = lastActive
    }
    
    enum Subscription: String, Codable {
        case free
        case premiumMonthly = "premium_monthly"
        case premiumAnnual = "premium_annual"
        
        var hasPremiumAccess: Bool {
            self != .free
        }
        
        var displayName: String {
            switch self {
            case .free: return "Free"
            case .premiumMonthly: return "Premium (Monthly)"
            case .premiumAnnual: return "Premium (Annual)"
            }
        }
    }
    
    struct Preferences: Codable {
        var autoSave: Bool = true
        var darkMode: Bool = false
        var fontSize: FontSize = .medium
        var defaultExportFormat: ExportFormat = .pdf
        
        enum FontSize: String, Codable {
            case small = "Small"
            case medium = "Medium"
            case large = "Large"
        }
        
        enum ExportFormat: String, Codable {
            case pdf = "PDF"
            case docx = "Word"
            case txt = "Plain Text"
        }
    }
    
    var canAccessPremiumTemplates: Bool {
        subscription.hasPremiumAccess
    }
    
    mutating func addFavoriteTemplate(_ template: String) {
        if !preferredTemplates.contains(template) {
            preferredTemplates.append(template)
        }
    }
    
    mutating func removeFavoriteTemplate(_ template: String) {
        preferredTemplates.removeAll { $0 == template }
    }
}
