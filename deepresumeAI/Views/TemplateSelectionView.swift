import SwiftUI

struct TemplateSelectionView: View {
    @Binding var selectedTemplate: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndex: Int?
    @State private var hoveredIndex: Int?
    @State private var showTemplatePreview: Bool = false
    @State private var previewTemplate: ResumeTemplate?
    @Namespace private var animation
    
    let templates = [
        ResumeTemplate(id: "modern", name: "Modern", description: "Clean and contemporary design", color: Color("4776E6"), features: ["Minimalist layout", "Modern typography", "Strategic white space"]),
        ResumeTemplate(id: "classic", name: "Classic", description: "Traditional and timeless layout", color: Color("2C3E50"), features: ["Professional format", "Traditional sections", "Clear hierarchy"]),
        ResumeTemplate(id: "creative", name: "Creative", description: "Unique and eye-catching style", color: Color("FF5F6D"), features: ["Bold design", "Custom sections", "Visual elements"]),
        ResumeTemplate(id: "professional", name: "Professional", description: "Polished and business-focused", color: Color("16A085"), features: ["Executive style", "Achievement focused", "Industry standard"]),
        ResumeTemplate(id: "minimal", name: "Minimal", description: "Simple and elegant format", color: Color("8E2DE2"), features: ["Clean design", "Essential sections", "Easy to scan"])
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color("134E5E").opacity(0.95),
                        Color("71B280").opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.title)
                                    .foregroundStyle(.linearGradient(
                                        colors: [.white, .white.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                
                                Text("Choose Your Style")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            Text("Select a template that best represents your professional identity")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Templates Grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 20)], spacing: 20) {
                            ForEach(Array(templates.enumerated()), id: \.element.id) { index, template in
                                TemplateCard(
                                    template: template,
                                    isSelected: selectedTemplate == template.id,
                                    isAnimating: selectedIndex == index,
                                    isHovered: hoveredIndex == index,
                                    namespace: animation
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedIndex = index
                                        selectedTemplate = template.id
                                        previewTemplate = template
                                        showTemplatePreview = true
                                    }
                                }
                                .onHover { isHovered in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        hoveredIndex = isHovered ? index : nil
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .sheet(isPresented: $showTemplatePreview, onDismiss: {
                if selectedTemplate != nil {
                    dismiss()
                }
            }) {
                if let template = previewTemplate {
                    TemplatePreviewSheet(template: template, isSelected: selectedTemplate == template.id) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTemplate = template.id
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct ResumeTemplate: Identifiable {
    let id: String
    let name: String
    let description: String
    let color: Color
    let features: [String]
}

struct TemplateCard: View {
    let template: ResumeTemplate
    let isSelected: Bool
    let isAnimating: Bool
    let isHovered: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 12) {
            // Template Preview
            ZStack {
                // Template thumbnail with gradient background
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                template.color.opacity(0.8),
                                template.color.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.9))
                                .symbolRenderingMode(.hierarchical)
                            
                            if isHovered {
                                Text("Preview")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .aspectRatio(0.7, contentMode: .fit)
                    .cornerRadius(16)
                    .shadow(color: template.color.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 3)
                        .matchedGeometryEffect(id: "selection_\(template.id)", in: namespace)
                }
            }
            .scaleEffect(isAnimating ? 0.95 : isHovered ? 1.05 : 1.0)
            
            // Template Info
            VStack(spacing: 4) {
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(template.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, 8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(isHovered ? 0.15 : 0.1))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

struct TemplatePreviewSheet: View {
    let template: ResumeTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Template Preview
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        template.color.opacity(0.8),
                                        template.color.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 400)
                            .cornerRadius(20)
                            .shadow(color: template.color.opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.9))
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(.horizontal)
                    
                    // Template Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text(template.name)
                            .font(.title.bold())
                        
                        Text(template.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        
                        // Features
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Features")
                                .font(.headline)
                            
                            ForEach(template.features, id: \.self) { feature in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(template.color)
                                    Text(feature)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isSelected {
                        Button("Select") {
                            onSelect()
                        }
                        .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TemplateSelectionView(selectedTemplate: .constant("modern"))
} 