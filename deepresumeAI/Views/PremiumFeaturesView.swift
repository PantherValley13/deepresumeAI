//
//  PremiumFeaturesView 2.swift
//  deepresumeAI
//
//  Created by Darius Church on 5/3/25.
//

import SwiftUI

struct PremiumFeaturesView: View {
    @State private var selectedFeature: PremiumFeature?
    
    let features: [PremiumFeature] = [
        PremiumFeature(
            title: "Advanced Templates",
            description: "Access premium templates designed by professionals",
            icon: "doc.text.fill",
            isLocked: true
        ),
        PremiumFeature(
            title: "ATS Optimization",
            description: "Get detailed ATS compatibility analysis",
            icon: "chart.bar.fill",
            isLocked: true
        ),
        PremiumFeature(
            title: "AI Writing Assistant",
            description: "Enhanced AI suggestions for your resume",
            icon: "wand.and.stars",
            isLocked: true
        ),
        PremiumFeature(
            title: "AI Cover Letter",
            description: "Generate personalized cover letters with AI",
            icon: "doc.text",
            isLocked: true
        ),
        PremiumFeature(
            title: "Career Analytics",
            description: "Track resume performance and job matches",
            icon: "chart.bar",
            isLocked: true
        ),
        PremiumFeature(
            title: "Collaboration Mode",
            description: "Share with mentors for feedback",
            icon: "person.2",
            isLocked: true
        )
    ]
    
    var body: some View {
        NavigationStack {
            List(features) { feature in
                Button {
                    selectedFeature = feature
                } label: {
                    PremiumFeatureRow(feature: feature)
                }
            }
            .navigationTitle("Premium Features")
            .sheet(item: $selectedFeature) { feature in
                PremiumFeatureDetailView(feature: feature)
            }
        }
    }
}

struct PremiumFeature: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isLocked: Bool
}

struct PremiumFeatureRow: View {
    let feature: PremiumFeature
    
    var body: some View {
                    HStack {
                        Image(systemName: feature.icon)
                .font(.title2)
                            .foregroundColor(.blue)
                .frame(width: 40)
                        
                        VStack(alignment: .leading) {
                            Text(feature.title)
                                .font(.headline)
                            Text(feature.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
            if feature.isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                    }
                }
        .padding(.vertical, 8)
    }
}

struct PremiumFeatureDetailView: View {
    let feature: PremiumFeature
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
        VStack(spacing: 20) {
            Image(systemName: feature.icon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(feature.title)
                .font(.title)
                .bold()
            
            Text(feature.description)
                    .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
                if feature.isLocked {
                    Button("Upgrade to Premium") {
                        // Handle upgrade
            }
            .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Premium Feature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
