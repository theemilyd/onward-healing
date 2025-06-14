import SwiftUI

struct DailySessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: Int? = nil
    @State private var innerCriticResponse = ""
    @State private var innerFriendResponse = ""
    @State private var reflectionResponse = ""
    @State private var completedExercises: Set<Int> = []
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    HeaderSection()
                    
                    // Session Title
                    SessionTitleSection()
                    
                    // Today's Focus
                    TodaysFocusSection()
                    
                    // Understanding Section
                    UnderstandingSection()
                    
                    // Inner Critic vs Inner Friend
                    InnerCriticFriendSection()
                    
                    // Practice Exercises
                    PracticeExercisesSection()
                    
                    // Gentle Reflection
                    GentleReflectionSection()
                    
                    // Mood Rating
                    MoodRatingSection()
                    
                    // Complete Session Button
                    CompleteSessionButton()
                }
                .padding(.top, 48)
                .padding(.bottom, 120) // Space for bottom navigation
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Header Section
private struct HeaderSection: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            // Top navigation
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
                
                Spacer()
                
                Text("Onward")
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
            }
            .padding(.horizontal, 24)
            
            // Progress section
            VStack(spacing: 8) {
                HStack {
                    Text("Day 12 of 30")
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    
                    Spacer()
                    
                    Text("70% Complete")
                        .font(.custom("Nunito", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                            .frame(width: geometry.size.width * 0.7, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Session Title
private struct SessionTitleSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Building Self-Compassion")
                .font(.custom("Nunito", size: 28))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .multilineTextAlignment(.center)
            
            Text("Today's journey toward treating yourself with kindness")
                .font(.custom("Nunito", size: 16))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Today's Focus
private struct TodaysFocusSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text("Today's Focus")
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            Text("Learning to speak to yourself with the same kindness you would a good friend. Self-compassion isn't about being perfect—it's about being gentle when you are not.")
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                .lineSpacing(6)
        }
        .padding(20)
        .background(
            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.08)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
}

// MARK: - Understanding Section
private struct UnderstandingSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Understanding Self-Compassion")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            Text("Self-compassion has three vital components: being kind to yourself with understanding, remembering that you're part of the human experience, and observing your thoughts without judgment.")
                .font(.custom("Nunito", size: 15))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                .lineSpacing(6)
            
            Text("You cannot get angry at yourself or the situation. Sometimes we criticize ourselves for not having the \"perfect\" response.")
                .font(.custom("Nunito", size: 15))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
}

// MARK: - Inner Critic vs Inner Friend
private struct InnerCriticFriendSection: View {
    @State private var innerCriticResponse = ""
    @State private var innerFriendResponse = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Inner Critic vs. Your Inner Friend")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                // Inner Critic Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 255/255, green: 107/255, blue: 53/255))
                        
                        Text("Inner Critic Says")
                            .font(.custom("Nunito", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                    
                    Text("\"You can't do anything right. You should have known better.\"")
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .italic()
                        .padding(.leading, 24)
                }
                .padding(16)
                .background(
                    Color(red: 255/255, green: 107/255, blue: 53/255).opacity(0.05)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 255/255, green: 107/255, blue: 53/255).opacity(0.2), lineWidth: 1)
                        )
                )
                .cornerRadius(12)
                
                // Inner Friend Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 184/255, green: 197/255, blue: 184/255))
                        
                        Text("Inner Friend Says")
                            .font(.custom("Nunito", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                    
                    Text("\"It's ok, everyone makes mistakes. You're human and you're doing your best.\"")
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .italic()
                        .padding(.leading, 24)
                }
                .padding(16)
                .background(
                    Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.05)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.2), lineWidth: 1)
                        )
                )
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Practice Exercises
private struct PracticeExercisesSection: View {
    @State private var completedExercises: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Practice Exercises")
                    .font(.custom("Nunito", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 20) {
                // Exercise 1
                ExerciseItem(
                    number: 1,
                    title: "Think of a recent moment when you were hard on yourself. Write down what your inner critic was saying.",
                    isCompleted: completedExercises.contains(1)
                ) {
                    if completedExercises.contains(1) {
                        completedExercises.remove(1)
                    } else {
                        completedExercises.insert(1)
                    }
                }
                
                // Exercise 2
                ExerciseItem(
                    number: 2,
                    title: "Now rewrite it as your inner friend. What would you tell a loved one in the same situation?",
                    isCompleted: completedExercises.contains(2)
                ) {
                    if completedExercises.contains(2) {
                        completedExercises.remove(2)
                    } else {
                        completedExercises.insert(2)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Gentle Reflection
private struct GentleReflectionSection: View {
    @State private var reflectionResponse = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Gentle Reflection")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("How does it feel to try to treat yourself with kindness you'd give a friend?")
                    .font(.custom("Nunito", size: 15))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                    .lineSpacing(6)
                
                Text("How are you today? What would you like to tell yourself with more compassion?")
                    .font(.custom("Nunito", size: 15))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    .lineSpacing(6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
}

// MARK: - Mood Rating
private struct MoodRatingSection: View {
    @State private var selectedMood: Int? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.custom("Nunito", size: 18))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 24) {
                ForEach(1...5, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        Text(moodEmoji(for: mood))
                            .font(.system(size: 36))
                            .scaleEffect(selectedMood == mood ? 1.1 : 1.0)
                            .opacity(selectedMood == nil || selectedMood == mood ? 1.0 : 0.6)
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedMood)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func moodEmoji(for mood: Int) -> String {
        switch mood {
        case 1: return "😢"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
}

// MARK: - Complete Session Button
private struct CompleteSessionButton: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Session Progress")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                
                Spacer()
                
                Text("8 of 8")
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            }
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text("Complete Today's Session")
                        .font(.custom("Nunito", size: 16))
                        .fontWeight(.semibold)
                }
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
                .cornerRadius(25)
            }
            
            HStack(spacing: 32) {
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 14))
                        Text("Save Progress")
                            .font(.custom("Nunito", size: 14))
                    }
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14))
                        Text("Next Activity")
                            .font(.custom("Nunito", size: 14))
                    }
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Views

private struct ExerciseItem: View {
    let number: Int
    let title: String
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(
                        isCompleted ? 
                        Color(red: 76/255, green: 175/255, blue: 80/255) :
                        Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.4)
                    )
            }
            
            Text(title)
                .font(.custom("Nunito", size: 15))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DailySessionView_Previews: PreviewProvider {
    static var previews: some View {
        DailySessionView()
    }
} 