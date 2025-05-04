//
//  PremiumFeaturesView 2.swift
//  deepresumeAI
//
//  Created by Darius Church on 5/3/25.
//

import SwiftUI

struct AnalysisView: View {
    let resume: Resume
    @ObservedObject var viewModel: ResumeViewModel
    @State private var selectedTab = 0
    @State private var animateChart = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color("0F2027").opacity(0.95),
                    Color("203A43").opacity(0.85),
                    Color("2C5364").opacity(0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Custom segmented control
                HStack(spacing: 0) {
                    ForEach(["ATS Score", "Keywords", "Suggestions"].indices, id: \.self) { index in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                            }
                        } label: {
                            Text(["ATS Score", "Keywords", "Suggestions"][index])
                                .font(.system(.subheadline, design: .rounded, weight: selectedTab == index ? .bold : .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == index ? Color.white.opacity(0.2) : Color.clear)
                                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.8))
                        }
                    }
                }
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Error message if any
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Tab content with animation
                TabView(selection: $selectedTab) {
                    ModernATSScoreView(score: viewModel.atsScore ?? 0, suggestions: viewModel.atsSuggestions)
                        .tag(0)
                    
                    ModernKeywordsView(suggestions: viewModel.aiSuggestions?.keywordSuggestions ?? [])
                        .tag(1)
                    
                    ModernSuggestionsView(suggestions: viewModel.aiSuggestions?.contentImprovements ?? [], viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationTitle("DeepSeek AI Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("0F2027").opacity(0.9), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            animateChart = true
        }
    }
}

struct ModernATSScoreView: View {
    let score: Double
    let suggestions: [String]
    @State private var animateScore = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Score gauge
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 25)
                        .frame(width: 220, height: 220)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: animateScore ? score / 100 : 0)
                        .stroke(
                            AngularGradient(
                                colors: [scoreColor.opacity(0.5), scoreColor],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360 * (score / 100))
                            ),
                            style: StrokeStyle(lineWidth: 25, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.5).delay(0.2), value: animateScore)
                    
                    // Score text
                    VStack(spacing: 5) {
                        Text("\(Int(animateScore ? score : 0))")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.interpolatingSpring(stiffness: 50, damping: 10).delay(0.5), value: animateScore)
                        
                        Text("DeepSeek ATS Score")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, 20)
                
                // Score assessment
                VStack(spacing: 15) {
                    Text(scoreMessage)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    // Score breakdown
                    VStack(spacing: 15) {
                        ScoreDetailRow(
                            title: "Keyword Match",
                            score: min(score + 5, 100),
                            color: .blue
                        )
                        
                        ScoreDetailRow(
                            title: "Formatting",
                            score: min(score - 5, 100),
                            color: .green
                        )
                        
                        ScoreDetailRow(
                            title: "Content Quality",
                            score: min(score + 2, 100),
                            color: .purple
                        )
                        
                        ScoreDetailRow(
                            title: "Overall Readability",
                            score: min(score - 10, 100),
                            color: .orange
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Recommendations card
                VStack(alignment: .leading, spacing: 15) {
                    Label("DeepSeek AI Recommendations", systemImage: "lightbulb.fill")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    
                    if suggestions.isEmpty {
                        Text("Run the ATS analysis to get DeepSeek's recommendations for improving your ATS score")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 10)
                    } else {
                        ForEach(suggestions.prefix(5), id: \.self) { item in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .padding(.top, 2)
                                
                                Text(item)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 3)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            withAnimation {
                animateScore = true
            }
        }
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...: return .green
        case 60...: return .yellow
        default: return .red
        }
    }
    
    private var scoreMessage: String {
        switch score {
        case 80...: return "Great job! Your resume is well-optimized for ATS systems."
        case 60...: return "Good start, but there's room for improvement in your ATS compatibility."
        default: return "Your resume needs optimization to pass through ATS systems effectively."
        }
    }
}

struct ScoreDetailRow: View {
    let title: String
    let score: Double
    let color: Color
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(animate ? score : 0))%")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 8)
                    .foregroundColor(.white.opacity(0.1))
                    .clipShape(Capsule())
                
                Rectangle()
                    .frame(width: animate ? (CGFloat(score) / 100) * 300 : 0, height: 8)
                    .foregroundColor(color)
                    .clipShape(Capsule())
                    .animation(.easeOut(duration: 1.5).delay(0.4), value: animate)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animate = true
            }
        }
    }
}

struct ModernKeywordsView: View {
    let suggestions: [String]
    @State private var animate = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header info
                VStack(spacing: 10) {
                    Text("Recommended Keywords")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Adding these keywords will improve your resume's visibility to employers and ATS systems")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 15)
                
                // Keywords section
                if suggestions.isEmpty {
                    emptyStateView
                } else {
                    staggeredGridView
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation {
                animate = true
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 10)
            
            Text("No keywords available yet")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
            
            Text("Run the AI analysis to get recommended keywords for your resume")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    private var staggeredGridView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120, maximum: 170))], spacing: 12) {
            ForEach(suggestions.indices, id: \.self) { index in
                KeywordBadge(
                    keyword: suggestions[index],
                    color: keywordColors[index % keywordColors.count],
                    delay: Double(index) * 0.1
                )
                .scaleEffect(animate ? 1 : 0.5)
                .opacity(animate ? 1 : 0)
            }
        }
        .padding(.horizontal, 5)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1), value: animate)
    }
    
    private let keywordColors: [Color] = [
        Color("3498db"),
        Color("1abc9c"),
        Color("9b59b6"),
        Color("f1c40f"),
        Color("e74c3c"),
        Color("2ecc71")
    ]
}

struct KeywordBadge: View {
    let keyword: String
    let color: Color
    let delay: Double
    @State private var appear = false
    
    var body: some View {
        Text(keyword)
            .font(.system(.subheadline, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 1.5)
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        appear = true
                    }
                }
            }
    }
}

struct ModernSuggestionsView: View {
    let suggestions: [String]
    @ObservedObject var viewModel: ResumeViewModel
    @State private var animate = false
    @State private var appliedSuggestions: Set<Int> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("DeepSeek AI Recommendations")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Smart recommendations powered by DeepSeek's AI to strengthen your resume")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 15)
                
                // Suggestions
                if suggestions.isEmpty {
                    emptyStateView
                } else {
                    ForEach(suggestions.indices, id: \.self) { index in
                        SuggestionCard(
                            suggestion: suggestions[index],
                            index: index + 1,
                            isApplied: appliedSuggestions.contains(index),
                            delay: Double(index) * 0.15,
                            onApply: {
                                applySuggestion(at: index)
                            }
                        )
                        .offset(y: animate ? 0 : 50)
                        .opacity(animate ? 1 : 0)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
    
    private func applySuggestion(at index: Int) {
        guard index < suggestions.count else { return }
        
        let suggestion = suggestions[index]
        viewModel.applySuggestion(suggestion)
        
        // Mark as applied
        withAnimation {
            appliedSuggestions.insert(index)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "lightbulb.slash")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 10)
            
            Text("No suggestions available yet")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
            
            Text("Run the DeepSeek AI analysis to get content improvement suggestions for your resume")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

struct SuggestionCard: View {
    let suggestion: String
    let index: Int
    let isApplied: Bool
    let delay: Double
    let onApply: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Numbered circle
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Text("\(index)")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(suggestion)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Apply button
                Button {
                    onApply()
                } label: {
                    Text(isApplied ? "Applied" : "Apply Suggestion")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(isApplied ? Color.gray : Color.blue.opacity(0.4))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    // Apply animation
                }
            }
        }
    }
}
