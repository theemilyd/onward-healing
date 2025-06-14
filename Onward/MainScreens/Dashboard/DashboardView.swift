import SwiftUI
import SwiftData

struct DashboardView: View {
    let onNavigateToTab: ((Int) -> Void)?
    
    @Query private var profiles: [UserProfile]
    @State private var showingSOS = false
    @State private var currentDisplayMode: DurationDisplayMode = .days
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @State private var dragOffset: CGSize = .zero
    @State private var showingSOSChat = false
    @State private var showingWhyEditor = false
    @State private var showingSettings = false
    
    init(onNavigateToTab: ((Int) -> Void)? = nil) {
        self.onNavigateToTab = onNavigateToTab
    }
    
    enum DurationDisplayMode: CaseIterable {
        case days, weeks, months, detailed
        
        var title: String {
            switch self {
            case .days: return "days"
            case .weeks: return "weeks"
            case .months: return "months"
            case .detailed: return "detailed"
            }
        }
    }
    
    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        ZStack {
            // Cream background from the design
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            if let profile = profile {
                ScrollView {
                    bodyContent(for: profile)
                }
            } else {
                Text("Loading your dashboard...")
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            // Floating Talk Button from design
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingSOSChat = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                            Image(systemName: "waveform")
                            Text("Talk")
                    }
                        .font(.custom("Nunito", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
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
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.4), radius: 10, x: 0, y: 5)
        }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingSOSChat) {
            ChatView()
        }
        .sheet(isPresented: $showingWhyEditor) {
            WhyEditorView(profile: profile!)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
    }
    
    @ViewBuilder
    private func bodyContent(for profile: UserProfile) -> some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
        HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.custom("Nunito", size: 24))
                    .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                Text("You're doing great today")
                            .font(.custom("Nunito", size: 16))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
            }
            Spacer()
            
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
        }
            }
            .padding(.top, 20)
            
            // Main duration display card
            durationCard(for: profile)
                .gesture(
                    DragGesture()
                        .onChanged { value in dragOffset = value.translation }
                        .onEnded { value in
                            let threshold: CGFloat = 80
                            withAnimation(.spring()) {
                                if value.translation.width > threshold {
                                    if let currentIndex = DurationDisplayMode.allCases.firstIndex(of: currentDisplayMode), currentIndex > 0 {
                                        currentDisplayMode = DurationDisplayMode.allCases[currentIndex - 1]
                                    }
                                } else if value.translation.width < -threshold {
                                    if let currentIndex = DurationDisplayMode.allCases.firstIndex(of: currentDisplayMode), currentIndex < DurationDisplayMode.allCases.count - 1 {
                                        currentDisplayMode = DurationDisplayMode.allCases[currentIndex + 1]
                                    }
                                }
                                dragOffset = .zero
                            }
                        }
                )
            
            whySection(for: profile)
            dailyCheckInSection(for: profile)
            quickActionsRow()
            affirmationSection()
            
            Spacer(minLength: 100) // Space for floating button
        }
        .padding(.horizontal, 20)
    }

    private func durationCard(for profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            Group {
                switch currentDisplayMode {
                case .days:
                    durationUnit(value: "\(profile.daysSinceNoContact)", unit: "days")
                case .weeks:
                    HStack(spacing: 30) {
                        durationUnit(value: "\(profile.weeksSinceNoContact)", unit: "weeks")
                        durationUnit(value: "\(profile.daysSinceNoContact % 7)", unit: "days")
                    }
                case .months:
                    HStack(spacing: 25) {
                        durationUnit(value: "\(profile.monthsSinceNoContact)", unit: "months")
                        durationUnit(value: "\(profile.weeksSinceNoContact % 4)", unit: "weeks")
                        durationUnit(value: "\(profile.daysSinceNoContact % 7)", unit: "days")
        }
                case .detailed:
                    let components = profile.durationComponents
                    HStack(spacing: 30) {
                        durationUnit(value: "\(components.day ?? 0)", unit: "days")
                        durationUnit(value: "\(components.hour ?? 0)", unit: "hours")
                        durationUnit(value: "\(components.minute ?? 0)", unit: "minutes")
                    }
                }
            }
            .fontWeight(.regular)
            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            .monospacedDigit()
            
            VStack {
                Text("Time of healing")
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Text("Since \(formatDateDetailed(profile.noContactStartDate))")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
            }
        }
        .offset(x: dragOffset.width * 0.1)
    }

    @ViewBuilder
    private func durationUnit(value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Nunito", size: 30))
            Text(unit)
                .font(.custom("Nunito", size: 14))
        }
    }

    private func whySection(for profile: UserProfile) -> some View {
        HStack(spacing: 16) {
            if let anchorImageData = profile.anchorImage, let uiImage = UIImage(data: anchorImageData) {
                Image(uiImage: uiImage)
                    .resizable().scaledToFill()
                    .frame(width: 60, height: 60).clipShape(Circle())
            } else {
                Image(systemName: "photo.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.7))
        .frame(width: 60, height: 60)
                    .background(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1))
        .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 4) {
            Text("Your Why")
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.bold)
                Text(profile.whyStatement.isEmpty ? "\"I want to find peace...\"" : profile.whyStatement)
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                    .lineLimit(3).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(20).background(Color.white)
        .cornerRadius(24).shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onTapGesture(count: 2) {
            showingWhyEditor = true
        }
    }

    private func dailyCheckInSection(for profile: UserProfile) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Check-in")
                    .font(.custom("Nunito", size: 14))
                .fontWeight(.bold)
                Text("How are you feeling today?")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                HStack {
                    Circle().fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.5)).frame(width: 8, height: 8)
                    Text("Track your mood")
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
            }
            Spacer()
            VStack {
                ZStack {
                    Circle().fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3)).frame(width: 48, height: 48)
                    Text("💭").font(.system(size: 24))
                }
                Text("Check-in")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
            }
        }
        .padding(20).background(Color(red: 245/255, green: 240/255, blue: 250/255))
        .cornerRadius(24).shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
}

    private func gardenSection(for profile: UserProfile) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Garden")
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.bold)
                Text("Your healing is growing")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                HStack {
                    Circle().fill(.green.opacity(0.5)).frame(width: 8, height: 8)
                    Text("\(profile.currentPlantStage) Stage")
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
            }
            Spacer()
            VStack {
                ZStack {
                    Circle().fill(Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.3)).frame(width: 48, height: 48)
                    Text(plantEmoji(for: profile.currentPlantStage)).font(.system(size: 24))
                }
                Text("Day \(profile.daysSinceNoContact)")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
            }
        }
        .padding(20).background(Color(red: 240/255, green: 243/255, blue: 240/255))
        .cornerRadius(24).shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private func quickActionsRow() -> some View {
        HStack(spacing: 20) {
            QuickActionCard(icon: "book.fill", title: "Journal", subtitle: "Reflect & write") {
                onNavigateToTab?(2) // Journal tab is index 2
            }
            QuickActionCard(icon: "leaf.fill", title: "Programs", subtitle: "Healing programs") {
                onNavigateToTab?(3) // Programs tab is index 3
            }
        }
    }

    private func affirmationSection() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            Text(dailyAffirmation)
                .font(.custom("Nunito", size: 16))
                .fontWeight(.regular)
                .italic()
                .multilineTextAlignment(.center)
            Text("Today's affirmation")
                .font(.custom("Nunito", size: 12))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
        }
        .padding(20).frame(maxWidth: .infinity)
        .background(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1))
        .cornerRadius(24).shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
}

    private func startTimer() {
        guard profile?.precisionLevel == "minute" else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in currentTime = Date() }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = profile?.name.isEmpty == false ? profile!.name : "friend"
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "Good morning"
        case 12..<17: timeGreeting = "Good afternoon"
        default: timeGreeting = "Good evening"
        }
        
        // If name is long (more than 12 characters), put it on a new line
        if name.count > 12 {
            return "\(timeGreeting),\n\(name)"
        } else {
            return "\(timeGreeting), \(name)"
        }
    }
    
    private var dailyAffirmation: String {
        "\"You are exactly where you need to be in this moment. Trust your journey.\""
    }

    private func formatDateDetailed(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private func plantEmoji(for stage: String) -> String {
        switch stage {
        case "Seed": return "🌱"
        case "Sprout": return "🌿"
        case "Young Plant": return "🪴"
        default: return "🌱"
        }
    }
}

// MARK: - Subviews

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String, action: @escaping () -> Void = {}) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
            HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("Nunito", size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text(subtitle)
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WhyEditorView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var whyText: String
    
    init(profile: UserProfile) {
        self.profile = profile
        self._whyText = State(initialValue: profile.whyStatement)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Your Why")
                    .font(.custom("Nunito", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Text("What drives your healing journey? This is your anchor.")
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    .multilineTextAlignment(.center)
                
                TextEditor(text: $whyText)
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .frame(minHeight: 120)
                
                Spacer()
            }
            .padding()
            .background(Color(red: 250/255, green: 247/255, blue: 245/255))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profile.whyStatement = whyText
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
    }
            }
        }
    }
} 
