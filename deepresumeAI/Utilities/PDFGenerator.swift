import PDFKit
import UIKit

class PDFGenerator {
    static func generatePDF(from resume: Resume) -> Data {
        // Create a PDF document
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        return renderer.pdfData { context in
            context.beginPage()
            
            // Add content based on template
            let templateType = resume.templateType
            switch templateType {
            case .modern:
                drawModernTemplate(resume: resume, context: context, bounds: pageSize)
            case .professional:
                drawProfessionalTemplate(resume: resume, context: context, bounds: pageSize)
            case .creative:
                drawCreativeTemplate(resume: resume, context: context, bounds: pageSize)
            case .minimal:
                drawMinimalTemplate(resume: resume, context: context, bounds: pageSize)
            case .classic:
                drawClassicTemplate(resume: resume, context: context, bounds: pageSize)
            @unknown default:
                // Fallback to modern template for any future cases
                print("Unknown template type: \(templateType.rawValue), falling back to modern")
                drawModernTemplate(resume: resume, context: context, bounds: pageSize)
            }
        }
    }
    
    private static func drawModernTemplate(resume: Resume, context: UIGraphicsPDFRendererContext, bounds: CGRect) {
        // Implement modern template design
        let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                               NSAttributedString.Key.foregroundColor: UIColor.blue]
        
        let name = NSAttributedString(string: resume.personalInfo.name, attributes: titleAttributes)
        name.draw(at: CGPoint(x: 50, y: 50))
        
        // Add other resume elements
        drawBasicInfo(resume: resume, yPosition: 100, bounds: bounds)
    }
    
    private static func drawProfessionalTemplate(resume: Resume, context: UIGraphicsPDFRendererContext, bounds: CGRect) {
        // Implement professional template design
        let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22),
                               NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        
        let name = NSAttributedString(string: resume.personalInfo.name, attributes: titleAttributes)
        name.draw(at: CGPoint(x: 40, y: 40))
        
        // Add other resume elements
        drawBasicInfo(resume: resume, yPosition: 90, bounds: bounds)
    }
    
    private static func drawCreativeTemplate(resume: Resume, context: UIGraphicsPDFRendererContext, bounds: CGRect) {
        // Implement creative template design
        let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 26),
                               NSAttributedString.Key.foregroundColor: UIColor.purple]
        
        let name = NSAttributedString(string: resume.personalInfo.name, attributes: titleAttributes)
        name.draw(at: CGPoint(x: 60, y: 60))
        
        // Add other resume elements
        drawBasicInfo(resume: resume, yPosition: 120, bounds: bounds)
    }
    
    private static func drawMinimalTemplate(resume: Resume, context: UIGraphicsPDFRendererContext, bounds: CGRect) {
        // Implement minimal template design
        let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                               NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let name = NSAttributedString(string: resume.personalInfo.name, attributes: titleAttributes)
        name.draw(at: CGPoint(x: 30, y: 30))
        
        // Add other resume elements
        drawBasicInfo(resume: resume, yPosition: 70, bounds: bounds)
    }
    
    private static func drawClassicTemplate(resume: Resume, context: UIGraphicsPDFRendererContext, bounds: CGRect) {
        // Implement classic template design
        let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22),
                               NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let name = NSAttributedString(string: resume.personalInfo.name, attributes: titleAttributes)
        name.draw(at: CGPoint(x: 40, y: 40))
        
        // Add other resume elements
        drawBasicInfo(resume: resume, yPosition: 90, bounds: bounds)
    }
    
    private static func drawBasicInfo(resume: Resume, yPosition: CGFloat, bounds: CGRect) {
        let infoAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                              NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        
        let email = NSAttributedString(string: "Email: \(resume.personalInfo.email)", attributes: infoAttributes)
        email.draw(at: CGPoint(x: 50, y: yPosition))
        
        let phone = NSAttributedString(string: "Phone: \(resume.personalInfo.phone)", attributes: infoAttributes)
        phone.draw(at: CGPoint(x: 50, y: yPosition + 20))
        
        // Add more personal info elements
    }
}

