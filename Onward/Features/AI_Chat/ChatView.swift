import SwiftUI
import SwiftData

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(content: String, isFromUser: Bool) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
}

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }
    
    @State private var messages: [ChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var isTyping: Bool = false
    
    private let quickReplies = ["I need support", "Feeling anxious", "Having a hard day"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                        
                        if isTyping {
                            TypingIndicatorView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // Quick Reply Suggestions (if no typing)
            if !currentMessage.isEmpty == false && !isTyping {
                QuickReplySection()
            }
            
            // Input Area
            InputAreaView()
        }
        .background(Color(red: 250/255, green: 247/255, blue: 245/255))
        .navigationBarHidden(true)
        .onAppear {
            if messages.isEmpty {
                let welcomeMessage = generateWelcomeMessage()
                messages.append(ChatMessage(content: welcomeMessage, isFromUser: false))
                
                // Update chat sessions count
                updateChatSession()
            }
        }
    }
    
    private func sendMessage(_ text: String = "") {
        let messageText = text.isEmpty ? currentMessage : text
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: messageText, isFromUser: true)
        messages.append(userMessage)
        
        currentMessage = ""
        
        // Show typing indicator
        isTyping = true
        
        // Simulate AI response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            let aiResponse = generateContextualAIResponse(for: messageText)
            let aiMessage = ChatMessage(content: aiResponse, isFromUser: false)
            messages.append(aiMessage)
        }
    }
    
    private func generateWelcomeMessage() -> String {
        guard let profile = profile else {
            return "Hello there, beautiful soul. I'm here whenever you need someone to listen. What's on your heart today?"
        }
        
        let daysSinceStart = Calendar.current.dateComponents([.day], from: profile.startDate, to: Date()).day ?? 0
        let plantStage = profile.currentPlantStage.lowercased()
        
        if daysSinceStart == 0 {
            return "Welcome to your healing journey! I'm so glad you're here. This is the beginning of something beautiful. What's bringing you here today?"
        } else if daysSinceStart < 7 {
            return "Hello again, brave soul. You've been on this journey for \(daysSinceStart) day\(daysSinceStart == 1 ? "" : "s") now. I can see your \(plantStage) is taking root. How are you feeling today?"
        } else {
            return "It's wonderful to see you again. \(daysSinceStart) days of growth and healing - your \(plantStage) is a testament to your resilience. What's on your heart today?"
        }
    }
    
    private func generateContextualAIResponse(for userMessage: String) -> String {
        let message = userMessage.lowercased()
        let profile = self.profile
        
        // Determine message intent
        if message.contains("anxious") || message.contains("anxiety") || message.contains("worried") || message.contains("stress") {
            return generateAnxietyResponse()
        } else if message.contains("sad") || message.contains("depressed") || message.contains("down") || message.contains("low") {
            return generateSadnessResponse()
        } else if message.contains("progress") || message.contains("better") || message.contains("good") || message.contains("happy") {
            return generateProgressResponse(profile: profile)
        } else if message.contains("overwhelmed") || message.contains("too much") || message.contains("difficult") {
            return generateOverwhelmResponse()
        } else if message.contains("thank") || message.contains("grateful") {
            return generateGratitudeResponse()
        } else {
            return generateGeneralSupportResponse()
        }
    }
    
    private func generateAnxietyResponse() -> String {
        let responses = [
            "I hear that anxiety in your words, and I want you to know it's completely valid. When anxiety visits, try taking three slow, deep breaths with me. You are safe in this moment. 💜",
            "Anxiety can feel so overwhelming, but you're not alone in this feeling. Let's ground ourselves together - what are three things you can see around you right now?",
            "That anxious energy you're carrying doesn't define you. You've weathered difficult moments before, and you have the strength to move through this one too. What would help you feel a little lighter right now?"
        ]
        return responses.randomElement() ?? "Your feelings are so valid. You're safe here with me."
    }
    
    private func generateSadnessResponse() -> String {
        let responses = [
            "I can feel the weight you're carrying, and I want you to know that sadness is a natural part of healing. You don't have to carry this alone. What would bring you the smallest comfort right now?",
            "Sometimes sadness is our heart's way of processing and releasing what no longer serves us. It's okay to feel this deeply - it shows your capacity for healing. 💜",
            "Your sadness is honored here. There's no rush to feel differently - just know that this feeling will shift and change, like everything does. You're exactly where you need to be."
        ]
        return responses.randomElement() ?? "Your sadness is seen and honored. You're not alone."
    }
    
    private func generateProgressResponse(profile: UserProfile?) -> String {
        let responses = [
            "I can hear the light returning to your voice! It's beautiful to witness your growth. Every small step forward is worth celebrating. 🌟",
            "Look at you, recognizing your own progress! That awareness itself is a sign of how far you've come. Your resilience is truly inspiring.",
            "These moments of feeling good are so precious. Let yourself fully receive this lightness - you've earned every bit of joy that comes your way."
        ]
        return responses.randomElement() ?? "Your progress fills my heart with joy. Keep shining!"
    }
    
    private func generateOverwhelmResponse() -> String {
        let responses = [
            "When everything feels like too much, we can start with just this breath. Then this moment. You don't have to solve everything at once - just this one thing in front of you. 💙",
            "Overwhelm is your system's way of saying 'slow down.' What if we could find one small thing to set aside for now? You deserve to feel at ease.",
            "I see you trying to carry so much. What would it look like to put some of that weight down, even for just a moment? You don't have to do this all alone."
        ]
        return responses.randomElement() ?? "One breath at a time. You've got this."
    }
    
    private func generateGratitudeResponse() -> String {
        let responses = [
            "Your gratitude touches my heart deeply. It takes real strength to find appreciation in the midst of healing. Thank you for sharing this light with me. ✨",
            "Gratitude is such a powerful healing force. I'm honored to be part of your journey, and I'm grateful for your courage in sharing so openly.",
            "Thank you for letting me witness your beautiful heart. Your gratitude is a gift not just to yourself, but to the world around you."
        ]
        return responses.randomElement() ?? "Your gratitude is a beautiful light. Thank you for sharing it."
    }
    
    private func generateGeneralSupportResponse() -> String {
        let responses = [
            "I hear you, and what you're feeling is so valid. When everything feels heavy, it's okay to just breathe and take things one moment at a time. You don't have to carry it all at once. 💜",
            "Thank you for sharing that with me. It takes courage to open up about what's in your heart. You're not alone in this journey.",
            "Your feelings are completely valid, and it's okay to feel however you're feeling right now. What small step could you take today to care for yourself?",
            "I'm grateful you felt safe enough to share this with me. Your healing matters, and you're doing better than you think.",
            "That sounds really meaningful. Remember that asking for support is a sign of strength, not weakness. How can you be gentle with yourself today?",
            "Your strength in sharing this shows how resilient you are, even when it doesn't feel that way. What would help you feel a little lighter right now?"
        ]
        return responses.randomElement() ?? "I'm here with you, and I'm listening with my whole heart."
    }
    
    private func updateChatSession() {
        guard let profile = profile else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastSession = Calendar.current.startOfDay(for: profile.lastChatSessionDate)
        
        if today > lastSession {
            // New day, reset counter
            profile.aiChatSessionsToday = 1
        } else {
            // Same day, increment
            profile.aiChatSessionsToday += 1
        }
        
        profile.lastChatSessionDate = Date()
        
        // Save the changes
        do {
            try modelContext.save()
        } catch {
            print("Failed to update chat session: \(error)")
        }
    }
}

// MARK: - Subviews

private extension ChatView {
    
    func HeaderView() -> some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text("Always here to listen")
                    .font(.custom("Nunito", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            Spacer()
            
            Button(action: {
                // Music/sound toggle functionality
            }) {
                Image(systemName: "music.note")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 44)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
    
    func QuickReplySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(quickReplies, id: \.self) { reply in
                        Button(action: { sendMessage(reply) }) {
                            Text(reply)
                                .font(.custom("Nunito", size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 12)
    }
    
    func InputAreaView() -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(red: 230/255, green: 230/255, blue: 235/255).opacity(0.3))
                .frame(height: 0.5)
            
            HStack(alignment: .bottom, spacing: 12) {
                TextField("Share what's in your heart...", text: $currentMessage, axis: .vertical)
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .lineLimit(1...4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    )
                
                Button(action: { sendMessage() }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(
                                    currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3),
                                            Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 195/255, green: 177/255, blue: 225/255),
                                            Color(red: 184/255, green: 197/255, blue: 184/255)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(Color(red: 250/255, green: 247/255, blue: 245/255))
        }
    }
}

// MARK: - Message Views

private struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        if message.isFromUser {
            UserMessageView(message: message)
        } else {
            AIMessageView(message: message)
        }
    }
}

private struct AIMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // AI Avatar
            Image(systemName: "heart.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(message.content)
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .lineSpacing(4)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 8,
                            bottomLeadingRadius: 22,
                            bottomTrailingRadius: 22,
                            topTrailingRadius: 22
                        )
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    )
                
                Text(formatTime(message.timestamp))
                    .font(.custom("Nunito", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    .padding(.leading, 6)
            }
            
            Spacer(minLength: 50)
        }
    }
}

private struct UserMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            Spacer(minLength: 50)
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(message.content)
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .lineSpacing(4)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 22,
                            bottomLeadingRadius: 22,
                            bottomTrailingRadius: 8,
                            topTrailingRadius: 22
                        )
                        .fill(Color(red: 242/255, green: 242/255, blue: 247/255))
                    )
                
                Text(formatTime(message.timestamp))
                    .font(.custom("Nunito", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    .padding(.trailing, 6)
            }
        }
    }
}

private struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // AI Avatar
            Image(systemName: "heart.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                )
            
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.4))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 22,
                    bottomTrailingRadius: 22,
                    topTrailingRadius: 22
                )
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
            
            Spacer(minLength: 50)
        }
        .onAppear {
            animationPhase = 1
        }
    }
}

// MARK: - Models & Helpers

private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    let now = Date()
    let calendar = Calendar.current
    
    if calendar.isDateInToday(date) {
        let components = calendar.dateComponents([.minute], from: date, to: now)
        if let minutes = components.minute {
            if minutes < 1 {
                return "Just now"
            } else if minutes == 1 {
                return "1 min ago"
            } else {
                return "\(minutes) min ago"
            }
        }
    }
    
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// MARK: - Preview

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView()
        }
    }
} 