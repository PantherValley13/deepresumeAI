// Note: This file is deprecated - all functionality has been moved to ResumeModels.swift
// This file exists only to fix compiler errors and should be removed once the project builds successfully

import SwiftUI

// We're defining this type to eliminate ambiguity
enum LegacyTemplateType {
    case modern, professional, creative, minimal
}

// Empty struct to satisfy any remaining references to Template
struct Template {
    let id = UUID()
    let type: ResumeModels.TemplateType
    var isSelected: Bool = false
    var isLocked: Bool = false
    
    init(type: ResumeModels.TemplateType = .modern, isSelected: Bool = false, isLocked: Bool = false) {
        self.type = type
        self.isSelected = isSelected
        self.isLocked = isLocked
    }
    
    var displayName: String {
        type.displayName
    }
}

// Clear type aliases to help migration
typealias TemplateType = ResumeModels.TemplateType 