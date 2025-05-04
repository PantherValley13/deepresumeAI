import SwiftUI

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        
        var height: CGFloat = 0
        var width: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if rowWidth + viewSize.width + spacing > containerWidth {
                // New row
                width = max(width, rowWidth)
                height += rowHeight + spacing
                rowWidth = viewSize.width
                rowHeight = viewSize.height
            } else {
                rowWidth += viewSize.width + spacing
                rowHeight = max(rowHeight, viewSize.height)
            }
        }
        
        // Add the last row
        height += rowHeight
        width = max(width, rowWidth)
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        
        var rowX: CGFloat = bounds.minX
        var rowY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        let spacing = self.spacing
        let containerWidth = bounds.width
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if rowX + viewSize.width > containerWidth - bounds.minX {
                // New row
                rowX = bounds.minX
                rowY += rowHeight + spacing
                rowHeight = 0
            }
            
            view.place(at: CGPoint(x: rowX, y: rowY), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            
            rowHeight = max(rowHeight, viewSize.height)
            rowX += viewSize.width + spacing
        }
    }
} 