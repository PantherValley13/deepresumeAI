import SwiftUI
import UIKit

struct ExportView: View {
    @State private var isExporting = false
    @State private var selectedFormat: ExportFormat = .pdf
    @State private var pdfData: Data?
    
    let resume: Resume
    
    enum ExportFormat {
        case pdf, docx, txt
    }
    
    var body: some View {
        VStack {
            Picker("Format", selection: $selectedFormat) {
                Text("PDF").tag(ExportFormat.pdf)
                Text("DOCX").tag(ExportFormat.docx)
                Text("TXT").tag(ExportFormat.txt)
                    }
                    .pickerStyle(.segmented)
            .padding()
            
            Button("Export") {
                exportResume()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isExporting)
        }
        .sheet(isPresented: $isExporting) {
            ActivityViewController(activityItems: [pdfData as Any])
        }
    }
    
    private func exportResume() {
        isExporting = true
        // Generate PDF data
        pdfData = PDFGenerator.generatePDF(from: resume)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
