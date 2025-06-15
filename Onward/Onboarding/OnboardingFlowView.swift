import SwiftUI
import SwiftData
import PhotosUI

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var selectedPrecision = "day"
    @State private var noContactDate = Date()
    @State private var relationshipType = ""
    @State private var relationshipDuration = ""
    @State private var noContactDecision = ""
    @State private var previousAttempts = ""
    @State private var whyStatement = ""
    @State private var selectedImage: Data?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 250/255, green: 247/255, blue: 245/255),
                    Color(red: 250/255, green: 247/255, blue: 245/255).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Progress indicator
                if currentStep > 0 {
                    HStack {
                        Button(action: { 
                            if currentStep > 0 {
                                currentStep -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        }
                        
                        Spacer()
                        
                        // Progress dots
                        HStack(spacing: 8) {
                            ForEach(0..<6) { index in
                                Circle()
                                    .fill(index <= currentStep ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Skip") {
                            if currentStep < 5 {
                                currentStep += 1
                            } else {
                                completeOnboarding()
                            }
                        }
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                // Step content
                ScrollView {
                    VStack {
                        switch currentStep {
                        case 0:
                            WelcomeStepView {
                                currentStep = 1
                            }
                        case 1:
                            NameInputStepView(
                                userName: $userName,
                                onContinue: { currentStep = 2 },
                                onSkip: { currentStep = 2 }
                            )
                        case 2:
                            DateSelectionStepView(
                                selectedPrecision: $selectedPrecision,
                                noContactDate: $noContactDate,
                                onContinue: { currentStep = 3 },
                                onSkip: { currentStep = 3 }
                            )
                        case 3:
                            RelationshipContextStepView(
                                relationshipType: $relationshipType,
                                relationshipDuration: $relationshipDuration,
                                noContactDecision: $noContactDecision,
                                previousAttempts: $previousAttempts,
                                onContinue: { currentStep = 4 },
                                onSkip: { currentStep = 4 }
                            )
                        case 4:
                            WhyStatementStepView(
                                whyStatement: $whyStatement,
                                onContinue: { currentStep = 5 },
                                onSkip: { currentStep = 5 }
                            )
                        case 5:
                            AnchorImageStepView(
                                selectedImage: $selectedImage,
                                onContinue: { completeOnboarding() },
                                onSkip: { completeOnboarding() }
                            )
                        default:
                            WelcomeStepView {
                                currentStep = 1
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    private func completeOnboarding() {
        // Create user profile
        let profile = UserProfile(
            name: userName,
            noContactStartDate: noContactDate,
            whyStatement: whyStatement,
            anchorImage: selectedImage,
            precisionLevel: selectedPrecision,
            relationshipType: relationshipType,
            relationshipDuration: relationshipDuration,
            reasonForNoContact: noContactDecision,
            previousNoContactAttempts: previousAttempts == "first-time" ? 0 : (previousAttempts == "tried-before" ? 1 : 2),
            noContactDecision: noContactDecision,
            previousAttempts: previousAttempts
        )
        
        modelContext.insert(profile)
        try? modelContext.save()
        
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Trigger post-onboarding paywall
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            PaywallTrigger.shared.checkPostOnboarding()
        }
    }
}

// MARK: - Step 1: Welcome
struct WelcomeStepView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Hero section
            VStack(spacing: 32) {
                // Animated heart icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2),
                                    Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                VStack(spacing: 20) {
                    Text("Welcome to No Contact Tracker")
                        .font(.custom("Inter", size: 28))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .multilineTextAlignment(.center)
                    
                    Text("Your safe space for healing, growth, and moving forward with intention.")
                        .font(.custom("Inter", size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Feature cards
            VStack(spacing: 16) {
                FeatureCard(
                    icon: "lock.shield.fill",
                    title: "Complete Privacy",
                    description: "Your data stays on your device. No accounts, no tracking, no judgment."
                )
                
                FeatureCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Your Growth",
                    description: "Gentle progress tracking that celebrates every step forward."
                )
                
                FeatureCard(
                    icon: "heart.text.square.fill",
                    title: "Compassionate Support",
                    description: "Tools and insights designed with empathy for your healing journey."
                )
            }
            
            Spacer()
            
            // Continue button
            Button(action: onContinue) {
                Text("Begin My Journey")
                    .font(.custom("Inter", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 195/255, green: 177/255, blue: 225/255),
                                Color(red: 184/255, green: 197/255, blue: 184/255)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 40)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Text(description)
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            Color.white.opacity(0.4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingFlowView()
} 