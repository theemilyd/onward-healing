import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var profiles: [UserProfile]
    @State private var showingSOS = false
    @State private var currentDisplayMode: DurationDisplayMode = .days
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @State private var dragOffset: CGSize = .zero
    
    enum DurationDisplayMode: CaseIterable {
        case days, weeks, months, detailed
        
        var title: String {
            switch self {
            case .days: return "Days"
            case .weeks: return "Weeks" 
            case .months: return "Months"
            case .detailed: return "Detailed"
            }
        }
        
        var emoji: String {
            switch self {
            case .days: return "📅"
            case .weeks: return "📊"
            case .months: return "🗓️"
            case .detailed: return "⏱️"
            }
        }
    }
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        ZStack {
            // Cream background
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            if let profile = profile {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with greeting
                        headerSection(for: profile)
                        
                        // Enhanced duration display with swipe navigation
                        durationDisplaySection(for: profile)
                        
                        // Your Why section
                        whySection(for: profile)
                        
                        // Plant progress section
                        plantProgressSection(for: profile)
                        
                        // Quick actions section
                        quickActionsSection()
                        
                        // Today's affirmation
                        affirmationSection()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Space for tab bar
                }
            } else {
                Text("Loading your dashboard...")
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            // Floating SOS button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingSOS = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                            Text("Talk")
                                .font(.custom("Nunito", size: 14))
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingSOS) {
            ChatView()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func headerSection(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.custom("Nunito", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text("Your healing journey continues")
                        .font(.custom("Nunito", size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                }
                Spacer()
            }
        }
        .padding(.top, 10)
    }
    
    private func durationDisplaySection(for profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            // Mode selector tabs
            HStack(spacing: 0) {
                ForEach(DurationDisplayMode.allCases, id: \.self) { mode in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentDisplayMode = mode
                        }
                    }) {
                        VStack(spacing: 6) {
                            Text(mode.emoji)
                                .font(.system(size: 18))
                            
                            Text(mode.title)
                                .font(.custom("Nunito", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(currentDisplayMode == mode ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currentDisplayMode == mode ? Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Duration display card with swipe gesture
            durationCard(for: profile)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold {
                                // Swipe right - previous mode
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if let currentIndex = DurationDisplayMode.allCases.firstIndex(of: currentDisplayMode),
                                       currentIndex > 0 {
                                        currentDisplayMode = DurationDisplayMode.allCases[currentIndex - 1]
                                    }
                                }
                            } else if value.translation.width < -threshold {
                                // Swipe left - next mode
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if let currentIndex = DurationDisplayMode.allCases.firstIndex(of: currentDisplayMode),
                                       currentIndex < DurationDisplayMode.allCases.count - 1 {
                                        currentDisplayMode = DurationDisplayMode.allCases[currentIndex + 1]
                                    }
                                }
                            }
                            dragOffset = .zero
                        }
                )
        }
    }
    
    private func durationCard(for profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            // Main duration display
            switch currentDisplayMode {
            case .days:
                VStack(spacing: 8) {
                    Text("\(profile.daysSinceNoContact)")
                        .font(.custom("Nunito", size: 48))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .monospacedDigit()
                    
                    Text(profile.daysSinceNoContact == 1 ? "Day of Healing" : "Days of Healing")
                        .font(.custom("Nunito", size: 18))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
                
            case .weeks:
                VStack(spacing: 8) {
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("\(profile.weeksSinceNoContact)")
                                .font(.custom("Nunito", size: 36))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                                .monospacedDigit()
                            Text("Weeks")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(profile.daysSinceNoContact % 7)")
                                .font(.custom("Nunito", size: 24))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                .monospacedDigit()
                            Text("Extra Days")
                                .font(.custom("Nunito", size: 12))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        }
                    }
                }
                
            case .months:
                VStack(spacing: 8) {
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(profile.monthsSinceNoContact)")
                                .font(.custom("Nunito", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                                .monospacedDigit()
                            Text("Months")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(profile.weeksSinceNoContact % 4)")
                                .font(.custom("Nunito", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                .monospacedDigit()
                            Text("Extra Weeks")
                                .font(.custom("Nunito", size: 12))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(profile.daysSinceNoContact % 7)")
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                .monospacedDigit()
                            Text("Extra Days")
                                .font(.custom("Nunito", size: 10))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        }
                    }
                }
                
            case .detailed:
                detailedDurationView(for: profile)
            }
            
            // Progress message
            VStack(spacing: 8) {
                progressMessage(for: profile)
                
                Text("Since \(formatDate(profile.noContactStartDate))")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
        .offset(x: dragOffset.width * 0.1) // Subtle visual feedback during drag
    }
    
    private func detailedDurationView(for profile: UserProfile) -> some View {
        let components = profile.durationComponents
        let shouldShowSeconds = profile.precisionLevel == "minute"
        
        return VStack(spacing: 12) {
            // Top row: Days and Hours
            HStack(spacing: 16) {
                DurationUnitView(
                    value: components.day ?? 0,
                    unit: "Days",
                    isMain: true
                )
                
                DurationUnitView(
                    value: components.hour ?? 0,
                    unit: "Hours",
                    isMain: false
                )
            }
            
            // Bottom row: Minutes and optionally Seconds
            HStack(spacing: 16) {
                DurationUnitView(
                    value: components.minute ?? 0,
                    unit: "Minutes",
                    isMain: false
                )
                
                if shouldShowSeconds {
                    DurationUnitView(
                        value: components.second ?? 0,
                        unit: "Seconds",
                        isMain: false,
                        isLive: true
                    )
                }
            }
            
            if shouldShowSeconds {
                Text("Live updating every second")
                    .font(.custom("Nunito", size: 10))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
            }
        }
    }
    
    private func progressMessage(for profile: UserProfile) -> some View {
        let days = profile.daysSinceNoContact
        let message: String
        
        switch days {
        case 0:
            message = "Every journey begins with a single step 🌱"
        case 1:
            message = "One day stronger! You're building new foundations 💪"
        case 2...6:
            message = "Each day is a victory. You're creating healthy distance ✨"
        case 7...13:
            message = "Over a week of healing! Your strength is growing 🌿"
        case 14...29:
            message = "Two weeks of progress! New patterns are forming 🌸"
        case 30...59:
            message = "A full month of healing! You're transforming beautifully 🦋"
        case 60...89:
            message = "Two months of growth! Your resilience is inspiring 🌳"
        case 90...179:
            message = "Three months strong! You're becoming who you're meant to be 🌟"
        case 180...364:
            message = "Half a year of healing! Your transformation is remarkable 🏔️"
        case 365...:
            message = "Over a year of strength! You're a true inspiration 👑"
        default:
            message = "Every moment of healing matters 💜"
        }
        
        return Text(message)
            .font(.custom("Nunito", size: 14))
            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
            .multilineTextAlignment(.center)
    }
    
    // ... rest of existing methods (whySection, plantProgressSection, etc.)
    
    private func whySection(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Why")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            if !profile.whyStatement.isEmpty {
                Text(profile.whyStatement)
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                    .lineLimit(nil)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                            )
                    )
            } else {
                Text("Tap to add your why statement")
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    .italic()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    private func plantProgressSection(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Growth")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            HStack(spacing: 16) {
                Text(plantEmoji(for: profile.currentPlantStage))
                    .font(.system(size: 48))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.currentPlantStage)
                        .font(.custom("Nunito", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text(plantMessage(for: profile.currentPlantStage))
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func quickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            HStack(spacing: 12) {
                quickActionButton(title: "Journal", icon: "book.fill", color: Color(red: 195/255, green: 177/255, blue: 225/255))
                quickActionButton(title: "Garden", icon: "leaf.fill", color: Color(red: 139/255, green: 177/255, blue: 137/255))
                quickActionButton(title: "Settings", icon: "gear", color: Color(red: 139/255, green: 134/255, blue: 128/255))
            }
        }
    }
    
    private func quickActionButton(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(color))
            
            Text(title)
                .font(.custom("Nunito", size: 12))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func affirmationSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Affirmation")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            Text(dailyAffirmation)
                .font(.custom("Nunito", size: 16))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    // Timer functions for live updates
    private func startTimer() {
        guard profile?.precisionLevel == "minute" else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Helper computed properties and functions
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning ☀️"
        case 12..<17: return "Good afternoon 🌤️"
        case 17..<21: return "Good evening 🌅"
        default: return "Good night 🌙"
        }
    }
    
    private var dailyAffirmation: String {
        let affirmations = [
            "You are stronger than you know, braver than you feel, and more loved than you imagine.",
            "Every step away from what hurt you is a step toward what will heal you.",
            "Your worth is not determined by someone else's inability to see it.",
            "Healing isn't linear, and that's perfectly okay. Trust your journey.",
            "You are becoming the person you were always meant to be.",
            "Your peace is more valuable than their presence.",
            "You chose yourself, and that takes incredible courage.",
            "Today you have the power to choose happiness over hurt.",
            "Your healing journey is a testament to your strength.",
            "You are writing a new chapter of your life, and it's beautiful."
        ]
        
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return affirmations[dayOfYear % affirmations.count]
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func plantEmoji(for stage: String) -> String {
        switch stage {
        case "Seed": return "🌱"
        case "Sprout": return "🌿"
        case "Young Plant": return "🪴"
        case "Growing Plant": return "🌾"
        case "Flowering": return "🌸"
        case "Full Bloom": return "🌺"
        default: return "🌱"
        }
    }
    
    private func plantMessage(for stage: String) -> String {
        switch stage {
        case "Seed": return "Your healing journey has begun. Trust the process."
        case "Sprout": return "Growth is happening, even when you can't see it."
        case "Young Plant": return "You're developing stronger roots every day."
        case "Growing Plant": return "Your resilience is growing beautifully."
        case "Flowering": return "You're blossoming into your true self."
        case "Full Bloom": return "You've grown into something magnificent."
        default: return "Every day is a step forward in your growth."
        }
    }
}

struct DurationUnitView: View {
    let value: Int
    let unit: String
    let isMain: Bool
    let isLive: Bool
    
    init(value: Int, unit: String, isMain: Bool, isLive: Bool = false) {
        self.value = value
        self.unit = unit
        self.isMain = isMain
        self.isLive = isLive
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.custom("Nunito", size: isMain ? 28 : 20))
                .fontWeight(.bold)
                .foregroundColor(isMain ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 139/255, green: 134/255, blue: 128/255))
                .monospacedDigit()
                .opacity(isLive ? 0.9 : 1.0)
                .animation(isLive ? .easeInOut(duration: 1.0).repeatForever() : .none, value: value)
            
            Text(unit)
                .font(.custom("Nunito", size: isMain ? 12 : 10))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
        }
        .frame(minWidth: 60)
    }
} 