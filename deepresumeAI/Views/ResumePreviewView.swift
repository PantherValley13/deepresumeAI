import SwiftUI

struct ResumePreviewView: View {
    @Binding var resume: Resume
    @ObservedObject private var templateManager = ResumeModels.TemplateManager()
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header with glassmorphism effect
                VStack(alignment: .center, spacing: 8) {
                    Text(resume.personalInfo.name)
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundStyle(templateColor)
                        .animation(.easeInOut(duration: 0.5), value: resume.templateType)
                    
                    if !resume.personalInfo.email.isEmpty || !resume.personalInfo.phone.isEmpty {
                        HStack(spacing: 15) {
                            if !resume.personalInfo.email.isEmpty {
                                Label(resume.personalInfo.email, systemImage: "envelope.fill")
                                    .font(.subheadline)
                            }
                            
                            if !resume.personalInfo.phone.isEmpty {
                                Label(resume.personalInfo.phone, systemImage: "phone.fill")
                                    .font(.subheadline)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    if !resume.personalInfo.address.isEmpty {
                        Label(resume.personalInfo.address, systemImage: "location.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !resume.personalInfo.linkedIn.isEmpty || !resume.personalInfo.portfolio.isEmpty {
                        HStack(spacing: 15) {
                            if !resume.personalInfo.linkedIn.isEmpty {
                                Label(resume.personalInfo.linkedIn, systemImage: "link")
                                    .font(.subheadline)
                            }
                            
                            if !resume.personalInfo.portfolio.isEmpty {
                                Label(resume.personalInfo.portfolio, systemImage: "globe")
                                    .font(.subheadline)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(templateColor.opacity(0.2), lineWidth: 1)
                )
                .padding(.bottom, 8)
                
                // Experience
                if !resume.experiences.isEmpty {
                    ModernSectionView(title: "Experience", icon: "briefcase.fill", color: templateColor) {
                        ForEach(resume.experiences) { experience in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(experience.jobTitle)
                                        .font(.headline)
                                        .foregroundStyle(templateColor)
                                    
                                    Spacer()
                                    
                                    Text(experience.duration)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(templateColor.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                
                                Text(experience.company)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                if !experience.responsibilities.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(experience.responsibilities, id: \.self) { responsibility in
                                            HStack(alignment: .top, spacing: 8) {
                                                Circle()
                                                    .fill(templateColor)
                                                    .frame(width: 6, height: 6)
                                                    .padding(.top, 6)
                                                
                                                Text(responsibility)
                                                    .font(.subheadline)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .foregroundStyle(.primary.opacity(0.8))
                                            }
                                        }
                                    }
                                    .padding(.top, 6)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                
                // Education
                if !resume.education.isEmpty {
                    ModernSectionView(title: "Education", icon: "graduationcap.fill", color: templateColor) {
                        ForEach(resume.education) { education in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(education.degree)
                                        .font(.headline)
                                        .foregroundStyle(templateColor)
                                    
                                    Spacer()
                                    
                                    Text(education.year)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(templateColor.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                
                                Text(education.institution)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                
                // Skills
                if !resume.skills.isEmpty {
                    ModernSectionView(title: "Skills", icon: "star.fill", color: templateColor) {
                        FlowLayout(spacing: 8) {
                            ForEach(resume.skills) { skill in
                                ModernSkillBadgeView(skill: skill, color: templateColor)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding()
            .animation(.easeInOut, value: resume.experiences.count)
            .animation(.easeInOut, value: resume.education.count)
            .animation(.easeInOut, value: resume.skills.count)
        }
        .background(backgroundColor)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
    
    private var backgroundColor: Color {
        Color(.systemBackground)
    }
    
    private var templateColor: Color {
        resume.templateType.primaryColor
    }
}

struct ModernSectionView<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Label {
                    Text(title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                } icon: {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                }
                
                Spacer()
                
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(height: 2)
                    .frame(maxWidth: 80)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ModernSkillBadgeView: View {
    let skill: Skill
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Text(skill.name)
                .font(.system(.subheadline, design: .rounded))
            
            if !skill.level.isEmpty {
                HStack(spacing: 2) {
                    ForEach(1...levelCount, id: \.self) { _ in
                        Circle()
                            .fill(color)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
    
    private var levelCount: Int {
        switch skill.level {
        case "Beginner": return 1
        case "Intermediate": return 2
        case "Advanced": return 3
        default: return 0
        }
    }
} 