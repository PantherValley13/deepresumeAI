import SwiftUI

struct TemplateGalleryView: View {
    @Binding var selectedTemplate: String
    @Environment(\.dismiss) var dismiss
    @State private var selectedIndex: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color("134E5E").opacity(0.6), Color("71B280").opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
            ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Choose Your Style")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        Text("Select a template that best represents your professional identity")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(Array(ResumeModels.TemplateType.allCases.enumerated()), id: \.element.id) { index, template in
                                templateCard(template: template, index: index)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedIndex = index
                                        }
                                        
                                        // After animation, update the actual selection
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            selectedTemplate = template.rawValue
                            dismiss()
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .padding(.vertical)
                            }
                        }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
    }
    
    private func templateCard(template: ResumeModels.TemplateType, index: Int) -> some View {
        let isSelected = selectedTemplate == template.rawValue
        let isAnimating = selectedIndex == index
        
        return VStack {
            ZStack {
                // Template preview image
                Image(template.thumbnailName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(height: 200)
                }
                
                // Premium badge if needed
                if false { // Set your condition for premium templates
                    VStack {
                        HStack {
                            Spacer()
                            Text("PRO")
                                .font(.system(size: 10, weight: .black))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .scaleEffect(isAnimating ? 0.92 : 1.0)
            
            Text(template.displayName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .contentShape(Rectangle()) // Make the entire card tappable
    }
}


