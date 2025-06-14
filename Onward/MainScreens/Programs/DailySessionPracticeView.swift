import SwiftUI

struct DailySessionPracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var programManager = ProgramManager.shared
    let session: Session
    
    @State private var selectedMood: Int? = nil
    @State private var exerciseResponses: [String: String] = [:]
    @State private var reflectionResponses: [String: String] = [:]
    @State private var completedExercises: Set<String> = []
    @State private var showingCompletionAlert = false
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    HeaderSection(session: session, programManager: programManager)
                    
                    // Page Title
                    PageTitleSection()
                    
                    // Practice Exercises
                    PracticeExercisesSection(
                        session: session,
                        exerciseResponses: $exerciseResponses,
                        completedExercises: $completedExercises
                    )
                    
                    // Gentle Reflection
                    GentleReflectionSection(
                        session: session,
                        reflectionResponses: $reflectionResponses
                    )
                    
                    // Mood Rating
                    MoodRatingSection(selectedMood: $selectedMood)
                    
                    // Complete Session Button
                    CompleteSessionButton(
                        session: session,
                        programManager: programManager,
                        exerciseResponses: exerciseResponses,
                        reflectionResponses: reflectionResponses,
                        selectedMood: selectedMood,
                        showingCompletionAlert: $showingCompletionAlert
                    )
                }
                .padding(.top, 48)
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .alert("Session Completed! 🎉", isPresented: $showingCompletionAlert) {
            Button("Continue") {
                dismiss()
            }
        } message: {
            Text("Your session has been saved to your journal. Great work on your healing journey!")
        }
    }
}

// MARK: - Header Section
private struct HeaderSection: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session
    let programManager: ProgramManager
    
    private var currentProgram: Program? {
        programManager.getProgram(by: session.programId)
    }
    
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
                    if let program = currentProgram {
                        Text("Day \(session.dayNumber) of \(program.totalDays)")
                            .font(.custom("Nunito", size: 14))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(program.progressPercentage * 100))% Complete")
                            .font(.custom("Nunito", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        if let program = currentProgram {
                            Rectangle()
                                .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                                .frame(width: geometry.size.width * program.progressPercentage, height: 4)
                                .cornerRadius(2)
                        }
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Page Title
private struct PageTitleSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Practice & Reflection")
                .font(.custom("Nunito", size: 28))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .multilineTextAlignment(.center)
            
            Text("Put your learning into practice with these exercises")
                .font(.custom("Nunito", size: 16))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Practice Exercises
private struct PracticeExercisesSection: View {
    let session: Session
    @Binding var exerciseResponses: [String: String]
    @Binding var completedExercises: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
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
            
            VStack(spacing: 24) {
                ForEach(Array(session.practiceContent.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseItemWithText(
                        number: index + 1,
                        title: exercise.title,
                        placeholder: exercise.placeholder,
                        text: Binding(
                            get: { exerciseResponses[exercise.id] ?? "" },
                            set: { exerciseResponses[exercise.id] = $0 }
                        ),
                        isCompleted: completedExercises.contains(exercise.id)
                    ) {
                        if completedExercises.contains(exercise.id) {
                            completedExercises.remove(exercise.id)
                        } else {
                            completedExercises.insert(exercise.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Gentle Reflection
private struct GentleReflectionSection: View {
    let session: Session
    @Binding var reflectionResponses: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Gentle Reflection")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .padding(.horizontal, 24)
            
            VStack(spacing: 20) {
                ForEach(session.practiceContent.reflections) { reflection in
                    ReflectionItem(
                        question: reflection.question,
                        placeholder: reflection.placeholder,
                        text: Binding(
                            get: { reflectionResponses[reflection.id] ?? "" },
                            set: { reflectionResponses[reflection.id] = $0 }
                        )
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Mood Rating
private struct MoodRatingSection: View {
    @Binding var selectedMood: Int?
    
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
    let session: Session
    let programManager: ProgramManager
    let exerciseResponses: [String: String]
    let reflectionResponses: [String: String]
    let selectedMood: Int?
    @Binding var showingCompletionAlert: Bool
    
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
            
            Button(action: {
                // Update all responses in program manager
                for (exerciseId, response) in exerciseResponses {
                    programManager.updateExerciseResponse(exerciseId: exerciseId, response: response)
                }
                for (reflectionId, response) in reflectionResponses {
                    programManager.updateReflectionResponse(reflectionId: reflectionId, response: response)
                }
                if let mood = selectedMood {
                    programManager.setMood(mood)
                }
                
                // Complete the session
                programManager.completeSession()
                
                // Show completion feedback
                showingCompletionAlert = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text("Complete & Save to Journal")
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

private struct ExerciseItemWithText: View {
    let number: Int
    let title: String
    let placeholder: String
    @Binding var text: String
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            
            // Text input field
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $text)
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .stroke(Color(red: 220/255, green: 220/255, blue: 225/255).opacity(0.4), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if text.isEmpty {
                                VStack {
                                    HStack {
                                        Text(placeholder)
                                            .font(.custom("Nunito", size: 14))
                                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                                            .padding(.top, 24)
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    )
                
                Text("\(text.count) characters")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ReflectionItem: View {
    let question: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.custom("Nunito", size: 15))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
            
            // Text input field
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $text)
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 80)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .stroke(Color(red: 220/255, green: 220/255, blue: 225/255).opacity(0.4), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if text.isEmpty {
                                VStack {
                                    HStack {
                                        Text(placeholder)
                                            .font(.custom("Nunito", size: 14))
                                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                                            .padding(.top, 24)
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    )
                
                Text("\(text.count) characters")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

struct DailySessionPracticeView_Previews: PreviewProvider {
    static var previews: some View {
        if let sampleSession = ProgramManager.shared.getTodaysSession() {
            DailySessionPracticeView(session: sampleSession)
        } else {
            Text("No session available")
        }
    }
} 