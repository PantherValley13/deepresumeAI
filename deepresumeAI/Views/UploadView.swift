import SwiftUI
import PDFKit

struct UploadView: View {
    @StateObject private var viewModel = UploadViewModel()
    @State private var showingFilePicker = false
    @State private var showingTemplateSelection = false
    @State private var selectedResume: Resume?
    @State private var showingCollaboration = false
    @State private var showingAnalytics = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color("134E5E").opacity(1.0),
                        Color("71B280").opacity(0.95),
                        Color("71B280").opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Upload Section
                        VStack(spacing: 20) {
                            // Upload Card
                            UploadCard(showDocumentPicker: $showingFilePicker)
                                .padding(.horizontal)
                                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 8)
                            
                            // Or Divider
                            HStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(height: 1)
                                Text("or")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal)
                            
                            // Create New Button
                            Button {
                                showingTemplateSelection = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .font(.title2)
                                    Text("Create New Resume")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
                        .padding(.horizontal)
                        
                        // Recent Resumes Section
                        if !viewModel.resumes.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Recent Resumes")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.resumes) { resume in
                                    ResumeRow(resume: resume) {
                                        selectedResume = resume
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Additional Features Section
                        VStack(spacing: 15) {
                            Text("Additional Features")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            HStack(spacing: 15) {
                                FeatureButton(
                                    title: "Collaboration",
                                    icon: "person.2",
                                    action: { showingCollaboration = true }
                                )
                                
                                FeatureButton(
                                    title: "Analytics",
                                    icon: "chart.bar",
                                    action: { showingAnalytics = true }
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Resume Builder")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker { url in
                    Task {
                        await viewModel.uploadResume(from: url)
                    }
                }
            }
            .sheet(isPresented: $showingTemplateSelection) {
                TemplateSelectionView(selectedTemplate: .constant(nil))
            }
            .sheet(isPresented: $showingCollaboration) {
                CollaborationView()
            }
            .sheet(isPresented: $showingAnalytics) {
                CareerAnalyticsView()
            }
            .sheet(item: $selectedResume) { resume in
                ResumeDetailView(resume: resume)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Processing your resume...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Preview
struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Supporting Views
struct FeatureButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

struct UploadCard: View {
    @Binding var showDocumentPicker: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon and Title
            VStack(spacing: 20) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 3)
                
                VStack(spacing: 8) {
                    Text("Upload Your Resume")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                    
                    Text("PDF format only")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            
            // Upload Button
            Button {
                showDocumentPicker = true
            } label: {
                HStack {
                    Image(systemName: "folder")
                    Text("Choose PDF")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(Color("134E5E"))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 3)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
    }
}

struct ResumeRow: View {
    let resume: Resume
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(resume.fileName ?? "Untitled Resume")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Last modified: \(resume.lastModified, style: .date)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

struct PDFPreview: View {
    let url: URL
    
    var body: some View {
        PDFKitView(url: url)
            .cornerRadius(12)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemBackground
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            uiView.document = PDFDocument(url: url)
        }
    }
}

struct ResumeSummaryView: View {
    let resume: Resume
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.title2.bold())
                        Text(resume.summary ?? "No summary available")
                    }
                    
                    // Skills Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Skills")
                            .font(.title2.bold())
                        FlowLayout(spacing: 8) {
                            ForEach(resume.skills, id: \.id) { skill in
                                Text(skill.name)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Experience Section
                    if !resume.experiences.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Experience")
                                .font(.title2.bold())
                            ForEach(resume.experiences, id: \.id) { exp in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exp.company)
                                        .font(.headline)
                                    Text(exp.jobTitle)
                                        .font(.subheadline)
                                    Text(exp.duration)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    ForEach(exp.responsibilities, id: \.self) { responsibility in
                                        Text("• \(responsibility)")
                                            .font(.body)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    // Education Section
                    if !resume.education.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Education")
                                .font(.title2.bold())
                            ForEach(resume.education, id: \.id) { edu in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(edu.institution)
                                        .font(.headline)
                                    Text(edu.degree)
                                        .font(.subheadline)
                                    Text(edu.year)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Resume Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UploadView()
} 