import SwiftUI

struct ResumeDetailView: View {
    let resume: Resume
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab = 0
    @State private var showingJobDescription = false
    @State private var showingEditor = false
    @State private var showingExport = false
    @State private var showingAIEnhancement = false
    @State private var jobDescription = ""
    @State private var scrollOffset: CGFloat = 0
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with glassmorphism effect
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.title)
                                .foregroundStyle(.linearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .matchedGeometryEffect(id: "icon", in: animation)
                            
                            Text(resume.fileName ?? "Untitled Resume")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        
                        Text("Last modified: \(resume.lastModified, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? 
                                Color(.systemGray6).opacity(0.8) : 
                                Color.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .padding()
                    
                    // Tab selection with custom design
                    HStack(spacing: 0) {
                        ForEach(["Summary", "PDF Preview"], id: \.self) { tab in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = tab == "Summary" ? 0 : 1
                                }
                            } label: {
                                Text(tab)
                                    .font(.headline)
                                    .foregroundColor(selectedTab == (tab == "Summary" ? 0 : 1) ? .primary : .secondary)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                            }
                            .background(
                                ZStack {
                                    if selectedTab == (tab == "Summary" ? 0 : 1) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.accentColor.opacity(0.1))
                                            .matchedGeometryEffect(id: "tab", in: animation)
                                    }
                                }
                            )
                        }
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                    )
                    .padding()
                    
                    // Content with improved transitions
                    TabView(selection: $selectedTab) {
                        ResumeSummaryView(resume: resume)
                            .tag(0)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                        
                        if let pdfData = resume.pdfData,
                           let tempURL = savePDFToTempFile(data: pdfData) {
                            PDFPreview(url: tempURL)
                                .tag(1)
                        } else {
                            EmptyPDFView()
                                .tag(1)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 400)
                    
                    // Action Buttons with enhanced design
                    VStack(spacing: 20) {
                        Text("Actions")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        VStack(spacing: 12) {
                            ActionButton(
                                title: "Analyze with Job Description",
                                subtitle: "Get ATS score and optimization tips",
                                icon: "doc.text.magnifyingglass",
                                color: .blue,
                                action: { showingJobDescription = true }
                            )
                            
                            ActionButton(
                                title: "Edit Resume",
                                subtitle: "Modify content and formatting",
                                icon: "pencil",
                                color: .green,
                                action: { showingEditor = true }
                            )
                            
                            ActionButton(
                                title: "Export Resume",
                                subtitle: "Save as PDF, DOCX, or TXT",
                                icon: "square.and.arrow.up",
                                color: .orange,
                                action: { showingExport = true }
                            )
                            
                            ActionButton(
                                title: "AI Enhancement",
                                subtitle: "Smart suggestions and improvements",
                                icon: "sparkles",
                                color: .purple,
                                action: { showingAIEnhancement = true }
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
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
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingJobDescription) {
                JobDescriptionView(viewModel: ResumeViewModel(resume: resume), jobDescription: $jobDescription)
            }
            .sheet(isPresented: $showingEditor) {
                ResumeEditorView(resume: .constant(resume))
            }
            .sheet(isPresented: $showingExport) {
                ExportView(resume: resume)
            }
            .sheet(isPresented: $showingAIEnhancement) {
                EnhancedAIPersonalizationView(viewModel: ResumeViewModel(resume: resume))
            }
        }
    }
    
    private func savePDFToTempFile(data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = resume.fileName ?? "resume.pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving PDF to temp file: \(error)")
            return nil
        }
    }
}

// MARK: - Supporting Views
struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                    action()
                }
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyPDFView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            
            Text("No PDF preview available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Upload a PDF file to view preview")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
        .padding()
    }
}

#Preview {
    ResumeDetailView(resume: Resume())
} 