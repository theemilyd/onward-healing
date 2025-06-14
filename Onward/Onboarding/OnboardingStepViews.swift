import SwiftUI
import PhotosUI

// MARK: - Step 1: Name Input
struct NameInputStepView: View {
    @Binding var userName: String
    let onContinue: () -> Void
    let onSkip: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            // Hero section
            VStack(spacing: 24) {
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
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                VStack(spacing: 16) {
                    Text("What Should We Call You?")
                        .font(.custom("Inter", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .multilineTextAlignment(.center)
                    
                    Text("We'd love to personalize your experience. Your name stays private and secure on your device.")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Name input
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your first name:")
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    TextField("Enter your name", text: $userName)
                        .font(.custom("Inter", size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .padding(16)
                        .background(
                            Color.white.opacity(0.5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isTextFieldFocused ? 
                                            Color(red: 195/255, green: 177/255, blue: 225/255) : 
                                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), 
                                            lineWidth: isTextFieldFocused ? 2 : 1
                                        )
                                )
                        )
                        .cornerRadius(12)
                        .focused($isTextFieldFocused)
                        .submitLabel(.continue)
                        .onSubmit {
                            if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onContinue()
                            }
                        }
                }
                .padding(24)
                .background(
                    Color.white.opacity(0.3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                        )
                )
                .cornerRadius(16)
            }
            
            // Preview greeting
            if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(spacing: 8) {
                    Text("Preview:")
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                    
                    Text("Good afternoon, \(userName.trimmingCharacters(in: .whitespacesAndNewlines))")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                                )
                        )
                        .cornerRadius(12)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.easeInOut(duration: 0.3), value: userName)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onSkip) {
                    Text("Skip for Now")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1)
                        )
                        .cornerRadius(25)
                }
                
                Button(action: onContinue) {
                    Text(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Continue" : "Nice to Meet You!")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(25)
                }
            }
        }
        .padding(.top, 32)
        .onAppear {
            // Auto-focus the text field when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Step 2: Date Selection
struct DateSelectionStepView: View {
    @Binding var selectedPrecision: String
    @Binding var noContactDate: Date
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Hero section
            VStack(spacing: 24) {
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
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                VStack(spacing: 16) {
                    Text("When Did Your Healing Begin?")
                        .font(.custom("Inter", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .multilineTextAlignment(.center)
                    
                    Text("This date helps us track your beautiful progress and celebrate your growth milestones. You can always adjust this later.")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Precision selection
            VStack(spacing: 16) {
                Text("Choose your tracking style:")
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                VStack(spacing: 12) {
                    PrecisionCard(
                        title: "Track by Day",
                        description: "Clean, simple view perfect for gentle progress tracking",
                        preview: "Preview: \"5 days of healing\"",
                        icon: "sun.max.fill",
                        isSelected: selectedPrecision == "day"
                    ) {
                        selectedPrecision = "day"
                    }
                    
                    PrecisionCard(
                        title: "Track by Hour",
                        description: "Detailed progress monitoring for incremental growth",
                        preview: "Preview: \"3 days, 14 hours of growth\"",
                        icon: "clock.fill",
                        isSelected: selectedPrecision == "hour"
                    ) {
                        selectedPrecision = "hour"
                    }
                    
                    PrecisionCard(
                        title: "Track by Minute",
                        description: "Live updates with continuous progress tracking",
                        preview: "Preview: \"2d 7h 23m of healing\"",
                        icon: "stopwatch.fill",
                        isSelected: selectedPrecision == "minute"
                    ) {
                        selectedPrecision = "minute"
                    }
                }
            }
            
            // Date picker
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select your healing start date:")
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    DatePicker(
                        "Healing Start Date",
                        selection: $noContactDate,
                        in: ...Date(),
                        displayedComponents: selectedPrecision == "day" ? [.date] : [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(16)
                    .background(
                        Color.white.opacity(0.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .cornerRadius(12)
                }
                .padding(24)
                .background(
                    Color.white.opacity(0.3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                        )
                )
                .cornerRadius(16)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onSkip) {
                    Text("I'm Not Sure Yet")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1)
                        )
                        .cornerRadius(25)
                }
                
                Button(action: onContinue) {
                    Text("Continue My Setup")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(25)
                }
            }
        }
        .padding(.top, 32)
    }
}

struct PrecisionCard: View {
    let title: String
    let description: String
    let preview: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(isSelected ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color.clear)
                            .stroke(Color(red: 195/255, green: 177/255, blue: 225/255), lineWidth: 2)
                            .frame(width: 16, height: 16)
                        
                        Text(title)
                            .font(.custom("Inter", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                    
                    Text(description)
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .multilineTextAlignment(.leading)
                    
                    Text(preview)
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1)
                        )
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.6))
            }
            .padding(16)
            .background(
                Color.white.opacity(0.3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .cornerRadius(16)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Step 3: Relationship Context
struct RelationshipContextStepView: View {
    @Binding var relationshipType: String
    @Binding var relationshipDuration: String
    @Binding var noContactDecision: String
    @Binding var previousAttempts: String
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Hero section
            VStack(spacing: 24) {
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
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                VStack(spacing: 16) {
                    Text("Help Us Understand Your Journey")
                        .font(.custom("Inter", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .multilineTextAlignment(.center)
                    
                    Text("Sharing a bit of context helps us create a more personalized healing experience. All information stays private and can be changed anytime.")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 24) {
                // Relationship type
                ContextSection(
                    title: "What kind of relationship was this?",
                    options: [
                        ("romantic", "Romantic Partnership", "heart.fill"),
                        ("friendship", "Close Friendship", "person.2.fill"),
                        ("family", "Family Relationship", "house.fill"),
                        ("other", "Other Meaningful Connection", "circle.grid.2x2.fill")
                    ],
                    selectedValue: $relationshipType
                )
                
                // Duration
                ContextSection(
                    title: "How long were you connected?",
                    options: [
                        ("weeks", "Recent weeks", ""),
                        ("months", "Several months", ""),
                        ("year", "About a year", ""),
                        ("years", "Multiple years", ""),
                        ("prefer-not", "Prefer not to specify", "")
                    ],
                    selectedValue: $relationshipDuration
                )
                
                // No-contact decision
                ContextSection(
                    title: "How did the no-contact begin?",
                    options: [
                        ("personal", "My personal choice", ""),
                        ("mutual", "Mutual decision we made together", ""),
                        ("their-choice", "Their decision to end contact", ""),
                        ("circumstances", "Life circumstances that separated us", ""),
                        ("prefer-not-share", "Prefer not to share", "")
                    ],
                    selectedValue: $noContactDecision
                )
                
                // Previous attempts
                ContextSection(
                    title: "Is this your first time going no-contact?",
                    options: [
                        ("first-time", "First time going no-contact", ""),
                        ("tried-before", "Tried before but reconnected", ""),
                        ("multiple", "Multiple previous attempts", ""),
                        ("unsure", "Unsure about past patterns", "")
                    ],
                    selectedValue: $previousAttempts
                )
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onSkip) {
                    Text("Skip This Step")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1)
                        )
                        .cornerRadius(25)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(25)
                }
            }
        }
        .padding(.top, 32)
    }
}

struct ContextSection: View {
    let title: String
    let options: [(String, String, String)] // value, display, icon
    @Binding var selectedValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Inter", size: 14))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            VStack(spacing: 12) {
                ForEach(options, id: \.0) { option in
                    Button(action: {
                        selectedValue = option.0
                    }) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(selectedValue == option.0 ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color.clear)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255), lineWidth: 2)
                                .frame(width: 20, height: 20)
                            
                            HStack(spacing: 12) {
                                if !option.2.isEmpty {
                                    Image(systemName: option.2)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.6))
                                        .frame(width: 20)
                                }
                                
                                Text(option.1)
                                    .font(.custom("Inter", size: 14))
                                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(
                            Color.white.opacity(0.3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                                )
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Step 4: Why Statement
struct WhyStatementStepView: View {
    @Binding var whyStatement: String
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Hero section
            VStack(spacing: 24) {
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
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                VStack(spacing: 16) {
                    Text("What's Your Why?")
                        .font(.custom("Inter", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .multilineTextAlignment(.center)
                    
                    Text("Your personal motivation can be a powerful anchor during challenging moments. What drives your healing journey?")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Text editor
            VStack(alignment: .leading, spacing: 16) {
                Text("Share your motivation (optional):")
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.5))
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                        .frame(minHeight: 120)
                    
                    if whyStatement.isEmpty {
                        Text("I'm choosing to heal because...")
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    
                    TextEditor(text: $whyStatement)
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                }
                
                HStack {
                    Spacer()
                    Text("\(whyStatement.count)/200")
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
            }
            
            // Examples
            VStack(alignment: .leading, spacing: 12) {
                Text("Need inspiration? Here are some examples:")
                    .font(.custom("Inter", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                
                VStack(spacing: 8) {
                    ExampleCard(text: "I deserve peace and happiness in my life")
                    ExampleCard(text: "I want to build healthier relationships")
                    ExampleCard(text: "I'm ready to focus on my own growth")
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onSkip) {
                    Text("Skip For Now")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1)
                        )
                        .cornerRadius(25)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(25)
                }
            }
        }
        .padding(.top, 32)
        .onChange(of: whyStatement) { _, newValue in
            if newValue.count > 200 {
                whyStatement = String(newValue.prefix(200))
            }
        }
    }
}

struct ExampleCard: View {
    let text: String
    
    var body: some View {
        Text("• \(text)")
            .font(.custom("Inter", size: 12))
            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1)
            )
            .cornerRadius(12)
    }
}

// MARK: - Step 5: Anchor Image
struct AnchorImageStepView: View {
    @Binding var selectedImage: Data?
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var showingImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 32) {
            // Hero section
            VStack(spacing: 24) {
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
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                VStack(spacing: 16) {
                    Text("Choose Your Anchor Image")
                        .font(.custom("Inter", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .multilineTextAlignment(.center)
                    
                    Text("Select an image that represents peace, strength, or your goals. This will be your visual reminder of why you're on this journey.")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Image selection
            VStack(spacing: 20) {
                // Current image display
                if let imageData = selectedImage, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255), lineWidth: 2)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.3))
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 2)
                        .frame(width: 200, height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.6))
                                
                                Text("Tap to select image")
                                    .font(.custom("Inter", size: 14))
                                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                            }
                        )
                }
                
                // Photo picker button
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text(selectedImage == nil ? "Choose From Photos" : "Change Image")
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1)
                        )
                        .cornerRadius(20)
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImage = data
                        }
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onSkip) {
                    Text("Skip For Now")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1)
                        )
                        .cornerRadius(25)
                }
                
                Button(action: onContinue) {
                    Text("Complete Setup")
                        .font(.custom("Inter", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(25)
                }
            }
        }
        .padding(.top, 32)
    }
} 