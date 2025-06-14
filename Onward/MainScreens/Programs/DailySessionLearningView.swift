import SwiftUI

struct DailySessionLearningView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var programManager = ProgramManager.shared
    let session: Session
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    HeaderSection(session: session, programManager: programManager)
                    
                    // Session Title
                    SessionTitleSection(session: session)
                    
                    // Today's Focus
                    TodaysFocusSection(session: session)
                    
                    // Understanding Section
                    UnderstandingSection(session: session)
                    
                    // Inner Critic vs Inner Friend
                    InnerCriticFriendSection(session: session)
                    
                    // Continue to Practice Button
                    ContinueToPracticeButton(session: session)
                }
                .padding(.top, 48)
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
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

// MARK: - Session Title
private struct SessionTitleSection: View {
    let session: Session
    
    var body: some View {
        VStack(spacing: 8) {
            Text(session.title)
                .font(.custom("Nunito", size: 28))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .multilineTextAlignment(.center)
            
            Text(session.subtitle)
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
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text(session.learningContent.focusTitle)
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            Text(session.learningContent.focusDescription)
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
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(session.learningContent.sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    Text(section.title)
                        .font(.custom("Nunito", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    ForEach(section.content, id: \.self) { content in
                        Text(content)
                            .font(.custom("Nunito", size: 15))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                            .lineSpacing(6)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
}

// MARK: - Inner Critic vs Inner Friend
private struct InnerCriticFriendSection: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Inner Critic vs. Your Inner Friend")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                ForEach(session.learningContent.examples) { example in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: example.icon)
                                .font(.system(size: 16))
                                .foregroundColor(exampleIconColor(for: example))
                            
                            Text(example.title)
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        }
                        
                        Text(example.content)
                            .font(.custom("Nunito", size: 14))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                            .italic()
                            .padding(.leading, 24)
                    }
                    .padding(16)
                    .background(
                        exampleBackgroundColor(for: example).opacity(0.05)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(exampleBackgroundColor(for: example).opacity(0.2), lineWidth: 1)
                            )
                    )
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func exampleIconColor(for example: Example) -> Color {
        switch example.type {
        case .innerCritic:
            return Color(red: 255/255, green: 107/255, blue: 53/255)
        case .innerFriend:
            return Color(red: 184/255, green: 197/255, blue: 184/255)
        default:
            return Color(red: 195/255, green: 177/255, blue: 225/255)
        }
    }
    
    private func exampleBackgroundColor(for example: Example) -> Color {
        switch example.type {
        case .innerCritic:
            return Color(red: 255/255, green: 107/255, blue: 53/255)
        case .innerFriend:
            return Color(red: 184/255, green: 197/255, blue: 184/255)
        default:
            return Color(red: 195/255, green: 177/255, blue: 225/255)
        }
    }
}

// MARK: - Continue to Practice Button
private struct ContinueToPracticeButton: View {
    let session: Session
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Learning Progress")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                
                Spacer()
                
                Text("4 of 8")
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            }
            
            NavigationLink(destination: DailySessionPracticeView(session: session)) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text("Continue to Practice")
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
        }
        .padding(.horizontal, 24)
    }
}

struct DailySessionLearningView_Previews: PreviewProvider {
    static var previews: some View {
        if let sampleSession = ProgramManager.shared.getTodaysSession() {
            DailySessionLearningView(session: sampleSession)
        } else {
            Text("No session available")
        }
    }
} 