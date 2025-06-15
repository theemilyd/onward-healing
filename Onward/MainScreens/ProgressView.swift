import SwiftUI
import SwiftData

struct ProgressPageView: View {
    @Query private var profiles: [UserProfile]
    @State private var isHealingPathExpanded = false
    @State private var isMomentsToCelebrateExpanded = false
    @State private var currentStreak = 0
    @State private var showAchievementAnimation = false
    @State private var showingSettings = false
    @State private var showingChat = false

    
    private var profile: UserProfile? {
        profiles.first
    }

    private var healingMilestones: [HealingMilestoneModel] {
        guard let profile = profile else { return [] }
        return HealingMilestone.allCases.map { milestone in
            let status = milestone.status(for: profile.daysSinceNoContact, achieved: profile.achievedMilestones.contains(milestone.rawValue))
            return HealingMilestoneModel(
                title: milestone.title,
                subtitle: milestone.subtitle(for: profile.daysSinceNoContact),
                icon: milestone.icon,
                status: status,
                daysRequired: milestone.daysRequired
            )
        }
    }

    private var momentsToCelebrate: [Celebration] {
        guard let profile = profile else { return [] }
        var celebrations: [Celebration] = []
        
        // Calculate current streak using improved method
        let streak = profile.getCurrentStreak()

        // Time-based achievements (Days)
        let timeAchievements = [
            (1, "First Step", "Your journey begins", "figure.walk"),
            (3, "Three Day Hero", "Building momentum", "3.circle.fill"),
            (7, "Week Warrior", "Seven days strong", "calendar"),
            (14, "Fortnight Fighter", "Two weeks of courage", "14.circle.fill"),
            (21, "Three Week Wonder", "21 days of growth", "star.circle"),
            (30, "Monthly Master", "One month milestone", "crown.fill"),
            (60, "Two Month Titan", "60 days of strength", "diamond.fill"),
            (90, "Quarter Year Queen", "90 days of transformation", "sparkles"),
            (180, "Half Year Hero", "Six months of healing", "trophy.fill"),
            (365, "Year of Triumph", "365 days of victory", "star.circle.fill")
        ]
        
        for (days, title, subtitle, icon) in timeAchievements {
            let achievementId = "time_\(days)_days"
            let isUnlocked = shouldUnlockAchievement(
                profile: profile,
                achievementId: achievementId,
                requirement: days,
                currentValue: profile.daysSinceNoContact
            )
            
            if isUnlocked {
                profile.unlockAchievement(achievementId: achievementId)
            }
            
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: profile.unlockedAchievementIds.contains(achievementId),
                category: .timeBasedDays,
                requirement: days
            ))
        }

        // Streak-based achievements
        let streakAchievements = [
            (3, "Streak Starter", "3 days in a row", "flame.fill"),
            (7, "Streak Warrior", "7 day streak", "flame.circle.fill"),
            (14, "Streak Master", "14 day streak", "flame.circle"),
            (30, "Streak Legend", "30 day streak", "flame")
        ]
        
        for (streakDays, title, subtitle, icon) in streakAchievements {
            let achievementId = "streak_\(streakDays)_days"
            let isUnlocked = shouldUnlockAchievement(
                profile: profile,
                achievementId: achievementId,
                requirement: streakDays,
                currentValue: streak
            )
            
            if isUnlocked {
                profile.unlockAchievement(achievementId: achievementId)
            }
            
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: profile.unlockedAchievementIds.contains(achievementId),
                category: .streak,
                requirement: streakDays
            ))
        }
        
        // Journal-based achievements
        let journalAchievements = [
            (1, "First Words", "Your first journal entry", "pencil.circle"),
            (5, "Storyteller", "5 journal entries", "book.closed"),
            (10, "Chronicle Keeper", "10 entries of wisdom", "books.vertical"),
            (25, "Memory Weaver", "25 entries of growth", "text.book.closed"),
            (50, "Journal Master", "50 entries of insight", "book.fill"),
            (100, "Word Wizard", "100 entries of healing", "text.magnifyingglass")
        ]
        
        for (count, title, subtitle, icon) in journalAchievements {
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: profile.journalEntriesCount >= count,
                category: .journaling,
                requirement: count
            ))
        }
        
        // Consistency & Self-Care achievements
        let consistencyAchievements = [
            (0.5, "Getting Started", "50% consistency", "heart.circle"),
            (0.7, "Steady Heart", "70% consistency", "heart.circle.fill"),
            (0.85, "Consistency Champion", "85% consistency", "heart.fill"),
            (0.95, "Perfect Balance", "95% consistency", "heart.text.square.fill")
        ]
        
        for (score, title, subtitle, icon) in consistencyAchievements {
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: profile.consistencyScore >= score,
                category: .consistency,
                requirement: Int(score * 100)
            ))
        }
        
        // Self-care achievements
        let selfCareAchievements = [
            (0.6, "Self-Care Starter", "60% self-care score", "leaf.circle"),
            (0.8, "Self-Love Guardian", "80% self-care mastery", "leaf.circle.fill"),
            (0.9, "Wellness Warrior", "90% self-care excellence", "leaf.fill")
        ]
        
        for (score, title, subtitle, icon) in selfCareAchievements {
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: profile.selfCareScore >= score,
                category: .selfCare,
                requirement: Int(score * 100)
            ))
        }
        
        // Emergency SOS & Crisis Management achievements
        let sosAchievements = [
            (1, "Crisis Survivor", "Used SOS instead of breaking no contact", "shield.fill"),
            (3, "Strength Finder", "3 times you chose healing over hurt", "heart.circle.fill"),
            (5, "Resilience Builder", "5 moments of choosing yourself", "mountain.2.fill"),
            (10, "Crisis Master", "10 times you stayed strong", "crown.fill"),
            (15, "Unbreakable", "15 SOS sessions - incredible strength", "diamond.fill")
        ]
        
        for (count, title, subtitle, icon) in sosAchievements {
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: profile.totalChatSessions >= count,
                category: .emergencySOS,
                requirement: count
            ))
        }
        
        // Emotional language achievements (based on journal sentiment)
        let emotionalAchievements = [
            (profile.hasPositiveLanguagePattern(), "Hope Finder", "Using hopeful language", "sun.max.fill"),
            (profile.hasGratitudePattern(), "Gratitude Master", "Expressing gratitude regularly", "heart.fill"),
            (profile.hasStrengthLanguage(), "Strength Speaker", "Recognizing your power", "bolt.fill"),
            (profile.hasSelfCompassionLanguage(), "Self-Compassion Sage", "Being kind to yourself", "hands.sparkles.fill"),
            (profile.hasGrowthMindsetLanguage(), "Growth Mindset", "Embracing learning", "arrow.up.right.circle.fill")
        ]
        
        for (condition, title, subtitle, icon) in emotionalAchievements {
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: condition,
                category: .emotionalLanguage,
                requirement: 0
            ))
        }
        
        // App engagement achievements
        let engagementAchievements = [
            (3, "Explorer", "3 days of app usage", "map.circle"),
            (7, "Regular User", "7 days of engagement", "calendar.circle"),
            (14, "Committed User", "14 days of growth", "star.circle"),
            (30, "Dedicated User", "30 days of healing", "crown.circle"),
            (60, "Power User", "60 days of transformation", "diamond.circle")
        ]
        
        let activeDays = profile.getActiveDaysCount()
        for (days, title, subtitle, icon) in engagementAchievements {
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: activeDays >= days,
                category: .appEngagement,
                requirement: days
            ))
        }
        
        // Special milestone achievements
        let specialAchievements = [
            (profile.emotionalStabilityScore >= 0.8, "Emotional Master", "80% emotional stability", "brain.head.profile.fill"),
            (profile.daysSinceNoContact >= 30 && profile.journalEntriesCount >= 15, "Balanced Growth", "30 days + 15 journal entries", "scale.3d"),
            (profile.consistencyScore >= 0.8 && profile.selfCareScore >= 0.8, "Harmony Achiever", "80% consistency + self-care", "infinity.circle.fill"),
            (streak >= 14 && profile.journalEntriesCount >= 10, "Dedicated Healer", "14-day streak + 10 entries", "cross.case.fill")
        ]
        
        for (condition, title, subtitle, icon) in specialAchievements {
            celebrations.append(Celebration(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isUnlocked: condition,
                category: .special,
                requirement: 0
            ))
        }
        
        return celebrations.sorted { first, second in
            if first.isUnlocked != second.isUnlocked {
                return first.isUnlocked && !second.isUnlocked
            }
            return first.requirement < second.requirement
        }
    }
    
    // Check if an achievement should be unlocked (prevents mass unlocking)
    private func shouldUnlockAchievement(
        profile: UserProfile,
        achievementId: String,
        requirement: Int,
        currentValue: Int
    ) -> Bool {
        // Don't unlock if already unlocked
        if profile.unlockedAchievementIds.contains(achievementId) {
            return false
        }
        
        // Only unlock if we've met the requirement and it's a reasonable progression
        if currentValue >= requirement {
            // For time-based achievements, only unlock the next logical milestone
            if achievementId.contains("day") {
                let previousMilestones = [1, 3, 7, 14, 21, 30, 60, 90, 180, 365]
                if let currentIndex = previousMilestones.firstIndex(of: requirement) {
                    // Check if previous milestone was unlocked (or if this is the first one)
                    if currentIndex == 0 {
                        return true
                    } else {
                        let previousMilestone = previousMilestones[currentIndex - 1]
                        let previousAchievementId = achievementId.replacingOccurrences(of: "\(requirement)", with: "\(previousMilestone)")
                        return profile.unlockedAchievementIds.contains(previousAchievementId)
                    }
                }
            }
            return true
        }
        
        return false
    }
    
    // Backend logic for calculating current streak - now using improved UserProfile method
    private func calculateCurrentStreak(profile: UserProfile) -> Int {
        return profile.getCurrentStreak()
    }
    

    
    // MARK: - Emotional Landscape Calculation
    // This creates a 7-day emotional stability chart based on:
    // 1. Base stability that improves gradually over time (0.3 starting + 0.01 per day)

    
    // Dynamic daily messages
    private var dailyMessage: (title: String, subtitle: String) {
        guard let profile = profile else { 
            return ("You're Growing Beautifully", "Your seeds of change are taking root. Every moment of healing matters.")
        }
        
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let days = profile.daysSinceNoContact
        
        let messages = [
            ("You're Growing Beautifully", "Your seeds of change are taking root. Every moment of healing matters."),
            ("Strength Flows Through You", "Each day you choose yourself, you become more powerful."),
            ("Your Light Shines Brighter", "The darkness is behind you, and your radiance grows stronger."),
            ("Healing Happens in Layers", "Trust the process. You're exactly where you need to be."),
            ("You Are Becoming Whole", "Every breath you take is a step toward your authentic self."),
            ("Your Heart Is Mending", "Feel the gentle healing happening within you right now."),
            ("Courage Lives in You", "You've already survived the hardest part. You're unstoppable."),
            ("Peace Is Your Birthright", "You deserve all the love and tranquility flowing to you."),
            ("Your Story Is Transforming", "From pain to power, from hurt to healing - you're rewriting everything."),
            ("You Are Enough, Always", "Your worth isn't tied to anyone else. You are complete.")
        ]
        
        // Cycle through messages based on day of year, with bonus messages for milestones
        if days == 7 {
            return ("One Week of Courage", "You've taken the hardest step and kept walking. You're incredible.")
        } else if days == 30 {
            return ("A Month of Strength", "Thirty days of choosing yourself. Look how far you've come.")
        } else if days == 60 {
            return ("Two Months of Growth", "Your transformation is undeniable. You're becoming who you're meant to be.")
        } else if days == 90 {
            return ("Three Months of Power", "A quarter of a year of pure strength. You're unstoppable now.")
        }
        
        let messageIndex = (dayOfYear + days) % messages.count
        return messages[messageIndex]
    }

    var body: some View {
        Group {
            if let profile = profile {
                ZStack {
                    ScrollView {
                        VStack(spacing: 32) {
                            header()
                            
                            growingBeautifullySection(profile: profile)
                            
                            streakSection(profile: profile)
                            
                            healingPathSection()
                            
                            momentsToCelebrateSection()

                            finalMessageSection()
                        }
                        .padding(.top, 48)
                        .padding(.bottom, 120) // Space for floating button
                    }
                    .background(Color(hex: "#FAF7F5"))
                    .edgesIgnoringSafeArea(.all)

                    // Floating SOS Button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { showingChat = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("SOS")
                                        .font(.custom("Nunito", size: 16))
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            } else {
                Text("Loading Progress...")
                    .font(.custom("Nunito", size: 18))
                    .foregroundColor(Color(hex: "#8B8680"))
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatView()
        }
    }

    @ViewBuilder
    private func header() -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Journey")
                        .font(.custom("Nunito", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#8B8680"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text("Your progress and growth")
                        .font(.custom("Nunito", size: 16))
                        .foregroundColor(Color(hex: "#8B8680").opacity(0.7))
                }
                
                Spacer()
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func growingBeautifullySection(profile: UserProfile) -> some View {
        let message = dailyMessage
        
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#C3B1E1").opacity(0.2), Color(hex: "#B8C5B8").opacity(0.2)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle().stroke(Color(hex: "#C3B1E1").opacity(0.2), lineWidth: 1)
                    )
            }
            
            Text(message.title)
                .font(.custom("Nunito-Bold", size: 20))
                .foregroundColor(Color(hex: "#8B8680"))
            
            Text(message.subtitle)
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(hex: "#8B8680").opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack {
                Text("\(profile.daysSinceNoContact)")
                    .font(.custom("Nunito-Regular", size: 30))
                    .foregroundColor(Color(hex: "#C3B1E1"))
                Text("Days of Growth")
                    .font(.custom("Nunito-Regular", size: 12))
                    .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.4))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#C3B1E1").opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func streakSection(profile: UserProfile) -> some View {
        let streak = calculateCurrentStreak(profile: profile)
        let nextStreakMilestone = getNextStreakMilestone(currentStreak: streak)
        
        HStack(spacing: 16) {
            // Current Streak
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color(hex: "#B8C5B8"))
                    Text("Current Streak")
                        .font(.custom("Nunito-Bold", size: 12))
                        .foregroundColor(Color(hex: "#8B8680"))
                }
                
                Text("\(streak)")
                    .font(.custom("Nunito-Bold", size: 24))
                    .foregroundColor(Color(hex: "#B8C5B8"))
                
                Text(streak == 1 ? "day" : "days")
                    .font(.custom("Nunito", size: 10))
                    .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#B8C5B8").opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#B8C5B8").opacity(0.3), lineWidth: 1)
            )
            
            // Next Milestone
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(Color(hex: "#C3B1E1"))
                    Text("Next Goal")
                        .font(.custom("Nunito-Bold", size: 12))
                        .foregroundColor(Color(hex: "#8B8680"))
                }
                
                Text("\(nextStreakMilestone)")
                    .font(.custom("Nunito-Bold", size: 24))
                    .foregroundColor(Color(hex: "#C3B1E1"))
                
                Text("\(nextStreakMilestone - streak) to go")
                    .font(.custom("Nunito", size: 10))
                    .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#C3B1E1").opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#C3B1E1").opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
    
    private func getNextStreakMilestone(currentStreak: Int) -> Int {
        let milestones = [3, 7, 14, 21, 30, 60, 90, 180, 365]
        return milestones.first { $0 > currentStreak } ?? (currentStreak + 30)
    }
    


    @ViewBuilder
    private func healingPathSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Your Healing Path")
                    .font(.custom("Nunito-Bold", size: 14))
                    .foregroundColor(Color(hex: "#8B8680"))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isHealingPathExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(isHealingPathExpanded ? "Show Less" : "View All")
                            .font(.custom("Nunito", size: 12))
                        Image(systemName: isHealingPathExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Color(hex: "#C3B1E1"))
                }
            }
            .padding(.horizontal)
            
            // Timeline-style layout
            VStack(spacing: 0) {
                let milestonesToShow = isHealingPathExpanded ? healingMilestones : Array(healingMilestones.prefix(3))
                
                ForEach(Array(milestonesToShow.enumerated()), id: \.element.id) { index, milestone in
                    HealingMilestoneTimelineRow(
                        milestone: milestone, 
                        isLast: index == milestonesToShow.count - 1
                    )
                }
                
                if !isHealingPathExpanded && healingMilestones.count > 3 {
                    HStack {
                        Circle()
                            .fill(Color(hex: "#8B8680").opacity(0.3))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("•••")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(healingMilestones.count - 3) more milestones")
                                .font(.custom("Nunito-Bold", size: 12))
                                .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
                            Text("Tap 'View All' to see your complete journey")
                                .font(.custom("Nunito", size: 10))
                                .foregroundColor(Color(hex: "#8B8680").opacity(0.5))
                        }
                        .padding()
                        .background(Color(hex: "#8B8680").opacity(0.05))
                        .cornerRadius(12)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func momentsToCelebrateSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMomentsToCelebrateExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "gift.fill")
                    Text("Moments to Celebrate")
                        .font(.custom("Nunito-Bold", size: 14))
                        .foregroundColor(Color(hex: "#8B8680"))
                    
                    Spacer()
                    
                    Image(systemName: isMomentsToCelebrateExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            
            if isMomentsToCelebrateExpanded {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(momentsToCelebrate) { celebration in
                        CelebrationCard(celebration: celebration)
                    }
                }
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                // Show first 6 achievements (3 rows of 2)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(Array(momentsToCelebrate.prefix(6))) { celebration in
                        CelebrationCard(celebration: celebration)
                    }
                }
                .padding(.horizontal)
                
                if momentsToCelebrate.count > 6 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isMomentsToCelebrateExpanded = true
                        }
                    }) {
                        HStack {
                            Text("View All (\(momentsToCelebrate.count))")
                                .font(.custom("Nunito-Bold", size: 12))
                                .foregroundColor(Color(hex: "#C3B1E1"))
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "#C3B1E1"))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "#C3B1E1").opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: "#C3B1E1").opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private func finalMessageSection() -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#8B8680"))
            
            Text("Remember: Healing isn't linear. Every small step forward is a victory worth celebrating. You're exactly where you need to be.")
                .font(.custom("Nunito", size: 12))
                .foregroundColor(Color(hex: "#8B8680").opacity(0.7))
                .lineSpacing(4)
        }
        .padding()
        .background(Color(hex: "#C3B1E1").opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#C3B1E1").opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func floatingActionButton() -> some View {
        Button(action: {}) {
            Image(systemName: "pencil")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(Color(hex: "#B8C5B8"))
                        .shadow(radius: 10)
                )
        }
    }
}

// MARK: - Supporting Models and Views

enum MilestoneStatus {
    case completed
    case inProgress(progress: Double)
    case locked
}

enum HealingMilestone: String, CaseIterable, Identifiable {
    // Early milestones (0-30 days)
    case firstDay = "firstDay"
    case threeDays = "threeDays"
    case firstWeek = "firstWeek"
    case tenDays = "tenDays"
    case twoWeeks = "twoWeeks"
    case threeWeeks = "threeWeeks"
    case oneMonth = "oneMonth"
    
    // Growth phase (30-90 days)
    case sixWeeks = "sixWeeks"
    case twoMonths = "twoMonths"
    case tenWeeks = "tenWeeks"
    case threeMonths = "threeMonths"
    
    // Transformation phase (90-365 days)
    case fourMonths = "fourMonths"
    case fiveMonths = "fiveMonths"
    case sixMonths = "sixMonths"
    case eightMonths = "eightMonths"
    case tenMonths = "tenMonths"
    case oneYear = "oneYear"
    
    // Mastery phase (365+ days)
    case fifteenMonths = "fifteenMonths"
    case eighteenMonths = "eighteenMonths"
    case twoYears = "twoYears"

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .firstDay: return "First Day Victory"
        case .threeDays: return "Three Day Warrior"
        case .firstWeek: return "Week One Champion"
        case .tenDays: return "Ten Day Hero"
        case .twoWeeks: return "Fortnight Fighter"
        case .threeWeeks: return "Three Week Wonder"
        case .oneMonth: return "Monthly Milestone"
        case .sixWeeks: return "Six Week Sage"
        case .twoMonths: return "Two Month Titan"
        case .tenWeeks: return "Ten Week Warrior"
        case .threeMonths: return "Quarter Year Queen"
        case .fourMonths: return "Four Month Phoenix"
        case .fiveMonths: return "Five Month Force"
        case .sixMonths: return "Half Year Hero"
        case .eightMonths: return "Eight Month Eagle"
        case .tenMonths: return "Ten Month Titan"
        case .oneYear: return "Year of Triumph"
        case .fifteenMonths: return "Fifteen Month Master"
        case .eighteenMonths: return "Eighteen Month Legend"
        case .twoYears: return "Two Year Transformer"
        }
    }

    func subtitle(for days: Int) -> String {
        let remaining = max(0, daysRequired - days)
        
        if days >= daysRequired {
            switch self {
            case .firstDay: return "Your journey begins with a single step"
            case .threeDays: return "Building momentum, one day at a time"
            case .firstWeek: return "You survived the hardest week"
            case .tenDays: return "Double digits of strength"
            case .twoWeeks: return "Two weeks of choosing yourself"
            case .threeWeeks: return "Three weeks of pure determination"
            case .oneMonth: return "A full month of transformation"
            case .sixWeeks: return "Six weeks of unwavering courage"
            case .twoMonths: return "Two months of incredible growth"
            case .tenWeeks: return "Ten weeks of consistent healing"
            case .threeMonths: return "A quarter year of strength"
            case .fourMonths: return "Four months of beautiful progress"
            case .fiveMonths: return "Five months of self-discovery"
            case .sixMonths: return "Half a year of transformation"
            case .eightMonths: return "Eight months of resilience"
            case .tenMonths: return "Ten months of incredible growth"
            case .oneYear: return "A full year of triumph"
            case .fifteenMonths: return "Fifteen months of mastery"
            case .eighteenMonths: return "Eighteen months of wisdom"
            case .twoYears: return "Two years of complete transformation"
            }
        } else {
            return remaining == 1 ? "1 day to go!" : "\(remaining) days to unlock"
        }
    }

    var icon: String {
        switch self {
        case .firstDay: return "1.circle.fill"
        case .threeDays: return "3.circle.fill"
        case .firstWeek: return "checkmark.circle.fill"
        case .tenDays: return "10.circle.fill"
        case .twoWeeks: return "14.circle.fill"
        case .threeWeeks: return "21.circle.fill"
        case .oneMonth: return "star.fill"
        case .sixWeeks: return "crown.fill"
        case .twoMonths: return "diamond.fill"
        case .tenWeeks: return "flame.fill"
        case .threeMonths: return "sparkles"
        case .fourMonths: return "4.circle.fill"
        case .fiveMonths: return "5.circle.fill"
        case .sixMonths: return "trophy.fill"
        case .eightMonths: return "8.circle.fill"
        case .tenMonths: return "rosette"
        case .oneYear: return "star.circle.fill"
        case .fifteenMonths: return "medal.fill"
        case .eighteenMonths: return "crown.fill"
        case .twoYears: return "star.square.fill"
        }
    }

    var daysRequired: Int {
        switch self {
        case .firstDay: return 1
        case .threeDays: return 3
        case .firstWeek: return 7
        case .tenDays: return 10
        case .twoWeeks: return 14
        case .threeWeeks: return 21
        case .oneMonth: return 30
        case .sixWeeks: return 42
        case .twoMonths: return 60
        case .tenWeeks: return 70
        case .threeMonths: return 90
        case .fourMonths: return 120
        case .fiveMonths: return 150
        case .sixMonths: return 180
        case .eightMonths: return 240
        case .tenMonths: return 300
        case .oneYear: return 365
        case .fifteenMonths: return 450
        case .eighteenMonths: return 540
        case .twoYears: return 730
        }
    }

    func status(for days: Int, achieved: Bool) -> MilestoneStatus {
        if achieved || days >= daysRequired {
            return .completed
        }
        
        let previousMilestoneDays = HealingMilestone.allCases
            .filter { $0.daysRequired < self.daysRequired }
            .map { $0.daysRequired }
            .max() ?? 0

        if days >= previousMilestoneDays {
            let totalDuration = Double(daysRequired - previousMilestoneDays)
            let currentProgress = Double(days - previousMilestoneDays)
            return .inProgress(progress: min(1.0, currentProgress / totalDuration))
        }
        
        return .locked
    }
}

struct HealingMilestoneModel: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let status: MilestoneStatus
    let daysRequired: Int
}

// New timeline-style milestone row to match image 5
struct HealingMilestoneTimelineRow: View {
    let milestone: HealingMilestoneModel
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: milestone.icon)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(Color(hex: "#8B8680").opacity(0.2))
                        .frame(width: 2, height: 40)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(milestone.title)
                        .font(.custom("Nunito-Bold", size: 14))
                        .foregroundColor(Color(hex: "#8B8680"))
                    
                    Spacer()
                    
                    if case .inProgress(let progress) = milestone.status {
                        Text("\(Int(progress * 100))%")
                            .font(.custom("Nunito-Bold", size: 12))
                            .foregroundColor(statusColor)
                    }
                }
                
                Text(milestone.subtitle)
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
                
                if case .inProgress(let progress) = milestone.status {
                    SwiftUI.ProgressView(value: progress)
                        .tint(statusColor)
                        .scaleEffect(y: 0.8)
                }
            }
            .padding()
            .background(statusBackgroundColor)
            .cornerRadius(12)
            .opacity(milestone.status == .locked ? 0.6 : 1.0)
        }
        .padding(.bottom, isLast ? 0 : 8)
    }
    
    private var statusColor: Color {
        switch milestone.status {
        case .completed:
            return Color(hex: "#B8C5B8")
        case .inProgress:
            return Color(hex: "#C3B1E1")
        case .locked:
            return Color(hex: "#8B8680").opacity(0.4)
        }
    }
    
    private var statusBackgroundColor: Color {
        switch milestone.status {
        case .completed:
            return Color(hex: "#B8C5B8").opacity(0.1)
        case .inProgress:
            return Color(hex: "#C3B1E1").opacity(0.1)
        case .locked:
            return Color(hex: "#8B8680").opacity(0.05)
        }
    }
}

enum CelebrationCategory {
    case timeBasedDays
    case streak
    case journaling
    case consistency
    case selfCare
    case emergencySOS
    case emotionalLanguage
    case appEngagement
    case special
}

struct Celebration: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let isUnlocked: Bool
    let category: CelebrationCategory
    let requirement: Int
}

struct CelebrationCard: View {
    let celebration: Celebration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Image(systemName: celebration.icon)
                        .frame(width: 32, height: 32)
                                            .background(celebration.isUnlocked ? Color(hex: "#C3B1E1").opacity(0.2) : Color(hex: "#8B8680").opacity(0.1))
                    .clipShape(Circle())
                    .foregroundColor(celebration.isUnlocked ? Color(hex: "#C3B1E1") : Color(hex: "#8B8680").opacity(0.4))
                    
                    // Purple ring for unlocked achievements
                    if celebration.isUnlocked {
                        Circle()
                            .stroke(Color(hex: "#C3B1E1"), lineWidth: 2)
                            .frame(width: 36, height: 36)
                            .opacity(0.9)
                    }
                }
                
                Spacer()
                
                if celebration.isUnlocked {
                    // Green checkmark for unlocked
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#4CAF50"))
                } else {
                    // Lock for locked achievements
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#8B8680").opacity(0.4))
                }
            }
            
            HStack(spacing: 6) {
                Text(celebration.title)
                    .font(.custom("Nunito-Bold", size: 12))
                    .foregroundColor(celebration.isUnlocked ? Color(hex: "#8B8680") : Color(hex: "#8B8680").opacity(0.5))
                
                // Sparkle for unlocked achievements
                if celebration.isUnlocked {
                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#C3B1E1"))
                }
            }
            
            Text(celebration.subtitle)
                .font(.custom("Nunito", size: 12))
                .foregroundColor(celebration.isUnlocked ? Color(hex: "#8B8680").opacity(0.6) : Color(hex: "#8B8680").opacity(0.4))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(celebration.isUnlocked ? Color(hex: "#C3B1E1").opacity(0.15) : Color(hex: "#8B8680").opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(celebration.isUnlocked ? Color(hex: "#C3B1E1").opacity(0.4) : Color(hex: "#8B8680").opacity(0.2), lineWidth: celebration.isUnlocked ? 1.5 : 1)
        )
        .opacity(celebration.isUnlocked ? 1.0 : 0.7)
        .scaleEffect(celebration.isUnlocked ? 1.0 : 0.98)
    }
}

struct IndicatorBar: View {
    let label: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(hex: "#8B8680").opacity(0.7))
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(.custom("Nunito-Bold", size: 12))
                    .foregroundColor(color)
            }
            SwiftUI.ProgressView(value: percentage)
                .tint(color)
        }
    }
}

// MARK: - Achievement Animation Components

struct AchievementOverlay: View {
    let achievement: Celebration
    let onDismiss: () -> Void
    let userProfile: UserProfile?
    
    @State private var showCard = false
    @State private var showParticles = false
    @State private var iconPulse = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            // Semi-transparent dark background to highlight popup
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Always allow dismiss by tapping outside
                    onDismiss()
                }
            
            // Gentle particles
            if showParticles {
                ParticleSystem(achievement: achievement)
            }
            
            // Achievement card
            if showCard {
                AchievementCard(
                    achievement: achievement,
                    showButton: showButton,
                    iconPulse: iconPulse,
                    onDismiss: onDismiss,
                    userProfile: userProfile
                )
                .scaleEffect(iconPulse ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: iconPulse)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // 0.3s: Particles begin
        withAnimation(.easeOut(duration: 0.8)) {
            showParticles = true
        }
        
        // 0.8s: Card slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(dampingFraction: 0.8)) {
                showCard = true
            }
        }
        
        // 1.2s: Icon begins pulsing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            iconPulse = true
        }
        
        // 2.8s: Button appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeIn(duration: 0.5)) {
                showButton = true
            }
        }
        
        // 8s: Auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            if showButton {
                onDismiss()
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Celebration
    let showButton: Bool
    let iconPulse: Bool
    let onDismiss: () -> Void
    let userProfile: UserProfile?
    
    @State private var showContent = false
    @State private var showProgress = false
    @State private var showButtons = false
    
    var body: some View {
        VStack(spacing: 24) {
            // X button in top right
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "#8B8680").opacity(0.1))
                        .clipShape(Circle())
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.3).delay(0.5), value: showContent)
            }
            .padding(.top, -8)
            
            // Achievement badge/category
            if showContent {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(categoryColor)
                    Text(achievementBadgeText)
                        .font(.custom("Nunito-Bold", size: 14))
                        .foregroundColor(categoryColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(categoryColor.opacity(0.1))
                .cornerRadius(20)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Large centered icon with glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                categoryColor.opacity(0.3),
                                categoryColor.opacity(0.15),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .opacity(iconPulse ? 1.0 : 0.7)
                    .scaleEffect(iconPulse ? 1.05 : 1.0)
                
                // Main circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(categoryColor.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: categoryColor.opacity(0.1), radius: 8, x: 0, y: 4)
                
                Image(systemName: safeAchievementIcon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(categoryColor)
            }
            
            // Achievement title and description
            if showContent {
                VStack(spacing: 8) {
                    Text(achievement.title)
                        .font(.custom("Nunito-Bold", size: 22))
                        .foregroundColor(Color(hex: "#8B8680"))
                        .multilineTextAlignment(.center)
                    
                    Text(achievementDescription)
                        .font(.custom("Nunito-Regular", size: 13))
                        .foregroundColor(Color(hex: "#8B8680").opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Sleek progress section
            if showProgress {
                VStack(spacing: 12) {
                    HStack {
                        Text("Healing Journey")
                            .font(.custom("Nunito-Bold", size: 14))
                            .foregroundColor(Color(hex: "#8B8680"))
                        
                        Spacer()
                        
                        Text(currentProgressText)
                            .font(.custom("Nunito-Bold", size: 14))
                            .foregroundColor(categoryColor)
                    }
                    
                    // Sleek progress bar like image 2
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#8B8680").opacity(0.1))
                                    .frame(height: 8)
                                
                                // Progress fill
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                categoryColor,
                                                categoryColor.opacity(0.8)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progressPercentage, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        HStack {
                            Text("Start")
                                .font(.custom("Nunito", size: 12))
                                .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
                            Spacer()
                            Text("Next: \(nextMilestoneText)")
                                .font(.custom("Nunito", size: 12))
                                .foregroundColor(Color(hex: "#8B8680").opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#FAF7F5"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(categoryColor.opacity(0.1), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Single action button
            if showButtons {
                Button(action: {
                    onDismiss()
                }) {
                    Text("Continue Growing")
                        .font(.custom("Nunito-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [categoryColor, categoryColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: categoryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(28)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color(hex: "#8B8680").opacity(0.15), radius: 24, x: 0, y: 12)
        .frame(width: 320, height: 440)
        .padding(.horizontal, 30)
        .onAppear {
            startEnhancedAnimationSequence()
        }
    }
    
    private func startEnhancedAnimationSequence() {
        // 0.2s: Main content appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(dampingFraction: 0.8)) {
                showContent = true
            }
        }
        
        // 0.6s: Progress section slides in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.4)) {
                showProgress = true
            }
        }
        
        // 1.0s: Button appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                showButtons = true
            }
        }
    }
    
    // Gentle celebration messages
    private var celebrationMessage: String {
        switch achievement.category {
        case .timeBasedDays:
            if achievement.requirement >= 365 {
                return "A year of transformation"
            } else if achievement.requirement >= 90 {
                return "Three months of strength"
            } else if achievement.requirement >= 30 {
                return "A month of growth"
            } else if achievement.requirement >= 7 {
                return "A week of courage"
            } else {
                return "Every day matters"
            }
        case .streak:
            return "Consistency is your superpower"
        case .journaling:
            return "Your words are healing"
        case .consistency:
            return "Building healthy habits"
        case .selfCare:
            return "Learning to love yourself"
        case .emergencySOS:
            return "Crisis management mastery"
        case .emotionalLanguage:
            return "Growing emotional intelligence"
        case .appEngagement:
            return "Committed to your journey"
        case .special:
            return "Something truly special"
        }
    }
    
    // Gentle and encouraging subtitles
    private var emotionalSubtitle: String {
        switch achievement.category {
        case .timeBasedDays:
            if achievement.requirement >= 365 {
                return "A full year of choosing yourself. You've completely transformed your life through daily acts of courage and self-love."
            } else if achievement.requirement >= 90 {
                return "Three months of consistent growth. Look at the strength you've built through choosing yourself every single day."
            } else if achievement.requirement >= 30 {
                return "Thirty days of choosing yourself. This milestone represents something beautiful taking root in your life."
            } else if achievement.requirement >= 7 {
                return "A whole week of courage. You took the hardest step and kept going. This foundation will carry you forward."
            } else {
                return "Every single day matters. You're building something incredible, one moment of courage at a time."
            }
        case .streak:
            return "Your consistency is powerful. Every day you show up for yourself, you're building unshakeable inner strength."
        case .journaling:
            return "Your words are healing you. Each entry is a step toward understanding and accepting yourself more deeply."
        case .consistency:
            return "Your dedication is inspiring. This consistency is changing your life in ways you may not even see yet."
        case .selfCare:
            return "You're learning to love yourself. This self-care journey is the most important work you'll ever do."
        case .emergencySOS:
            return "In your moments of crisis, you chose healing over hurt. This strength will carry you through anything life brings."
        case .emotionalLanguage:
            return "Your language patterns show incredible emotional growth. You're developing a healthier relationship with your thoughts."
        case .appEngagement:
            return "Your dedication to daily growth is creating lasting positive change in your life."
        case .special:
            return "You've unlocked something truly special. This shows how far you've come on your healing journey."
        }
    }
    
    // Achievement rarity (number of stars)
    private var achievementRarity: Int {
        switch achievement.category {
        case .timeBasedDays:
            if achievement.requirement >= 365 { return 5 }
            else if achievement.requirement >= 180 { return 4 }
            else if achievement.requirement >= 90 { return 3 }
            else if achievement.requirement >= 30 { return 2 }
            else { return 1 }
        case .streak:
            if achievement.requirement >= 30 { return 4 }
            else if achievement.requirement >= 14 { return 3 }
            else if achievement.requirement >= 7 { return 2 }
            else { return 1 }
        case .journaling:
            if achievement.requirement >= 100 { return 5 }
            else if achievement.requirement >= 50 { return 4 }
            else if achievement.requirement >= 25 { return 3 }
            else if achievement.requirement >= 10 { return 2 }
            else { return 1 }
        case .consistency, .selfCare:
            if achievement.requirement >= 95 { return 5 }
            else if achievement.requirement >= 85 { return 4 }
            else if achievement.requirement >= 70 { return 3 }
            else { return 2 }
        case .emergencySOS:
            if achievement.requirement >= 15 { return 5 }
            else if achievement.requirement >= 10 { return 4 }
            else if achievement.requirement >= 5 { return 3 }
            else if achievement.requirement >= 3 { return 2 }
            else { return 1 }
        case .emotionalLanguage:
            return 3 // Language achievements are medium rarity
        case .appEngagement:
            if achievement.requirement >= 60 { return 5 }
            else if achievement.requirement >= 30 { return 4 }
            else if achievement.requirement >= 14 { return 3 }
            else if achievement.requirement >= 7 { return 2 }
            else { return 1 }
        case .special:
            return 4 // Special achievements are always high rarity
        }
    }
    
    private var categoryColor: Color {
        switch achievement.category {
        case .timeBasedDays:
            return Color(hex: "#C3B1E1") // Purple - brand primary
        case .streak:
            return Color(hex: "#FF6B35") // Orange - energy
        case .journaling:
            return Color(hex: "#B8C5B8") // Sage green - growth
        case .consistency, .selfCare:
            return Color(hex: "#B8C5B8") // Sage green - healing
        case .emergencySOS:
            return Color(hex: "#FF6B35") // Orange - crisis/emergency
        case .emotionalLanguage:
            return Color(hex: "#B8C5B8") // Sage green - emotional growth
        case .appEngagement:
            return Color(hex: "#C3B1E1") // Purple - engagement
        case .special:
            return Color(hex: "#C3B1E1") // Purple - special moments
        }
    }
    
    private var achievementBadgeText: String {
        switch achievement.category {
        case .timeBasedDays:
            return "\(achievement.requirement) Day Milestone"
        case .streak:
            return "Streak Achievement"
        case .journaling:
            return "Writing Achievement"
        case .consistency:
            return "Consistency Achievement"
        case .selfCare:
            return "Self-Care Achievement"
        case .emergencySOS:
            return "Crisis Management Achievement"
        case .emotionalLanguage:
            return "Language Pattern Achievement"
        case .appEngagement:
            return "Engagement Achievement"
        case .special:
            return "Special Achievement"
        }
    }
    
    private var achievementDescription: String {
        switch achievement.category {
        case .timeBasedDays:
            if achievement.requirement == 1 {
                return "Your healing garden is growing beautifully. You've taken the first step of your journey."
            } else if achievement.requirement <= 7 {
                return "Seven days of choosing yourself, seven days of moving forward. You're building something incredible."
            } else if achievement.requirement <= 30 {
                return "Your dedication is inspiring. This consistency is changing your life in ways you may not even see yet."
            } else {
                return "Months of dedication and growth. You've transformed into someone stronger and more resilient."
            }
        case .streak:
            return "Your consistent daily practice is creating lasting change. Each day builds upon the last."
        case .journaling:
            return "Your words have power. Through writing, you're processing, healing, and growing."
        case .consistency, .selfCare:
            return "You're learning to love yourself. This self-care journey is the most important work you'll ever do."
        case .emergencySOS:
            return "When you felt like breaking, you chose to heal instead. This courage is transforming your life."
        case .emotionalLanguage:
            return "Your words reflect your inner transformation. You're developing healthier thought patterns."
        case .appEngagement:
            return "Your dedication to daily growth is creating lasting positive change in your life."
        case .special:
            return "You've unlocked something truly special. This shows how far you've come on your healing journey."
        }
    }
    
    private var nextMilestoneText: String {
        switch achievement.category {
        case .timeBasedDays:
            switch achievement.requirement {
            case 1:
                return "3 days"
            case 3:
                return "7 days"
            case 7:
                return "14 days"
            case 14:
                return "30 days"
            case 30:
                return "60 days"
            case 60:
                return "90 days"
            default:
                return "next goal"
            }
        case .streak:
            return "\(achievement.requirement + 7) day streak"
        case .journaling:
            return "\(achievement.requirement + 10) entries"
        default:
            return "next level"
        }
    }
    
    private var progressPercentage: Double {
        // For unlocked achievements, always show 100%
        if achievement.isUnlocked {
            return 1.0
        }
        
        // For locked achievements, show realistic progress
        return 0.0
    }
    
    private func getPreviousMilestone(current: Int) -> Int {
        let milestones = [0, 1, 3, 7, 14, 21, 30, 60, 90, 180, 365]
        for i in 1..<milestones.count {
            if milestones[i] == current {
                return milestones[i-1]
            }
        }
        return 0
    }
    
    private var inspirationalQuote: String {
        let quotes = [
            "Growth is never by mere chance; it is the result of forces working together.",
            "You are braver than you believe, stronger than you seem, and more loved than you know.",
            "Healing takes time, and asking for help is a courageous step.",
            "Progress, not perfection, is what we should strive for.",
            "Your journey is beautiful, even when it feels difficult.",
            "Every small step forward is still a step in the right direction.",
            "You have been assigned this mountain to show others it can be moved.",
            "The wound is the place where the light enters you.",
            "What lies behind us and what lies before us are tiny matters compared to what lies within us.",
            "You are not broken. You are breaking through."
        ]
        // Use achievement requirement to pick consistent quote
        return quotes[achievement.requirement % quotes.count]
    }
    
    private var currentProgressText: String {
        guard let profile = userProfile else { return "\(achievement.requirement) days" }
        
        switch achievement.category {
        case .timeBasedDays:
            return "\(profile.daysSinceNoContact) days"
        case .streak:
            let currentStreak = calculateCurrentStreak(profile: profile)
            return "\(currentStreak) day streak"
        case .journaling:
            return "\(profile.journalEntriesCount) entries"
        case .consistency:
            return "\(Int(profile.consistencyScore * 100))% consistency"
        case .selfCare:
            return "\(Int(profile.selfCareScore * 100))% self-care"
        case .emergencySOS:
            return "\(profile.totalChatSessions) SOS sessions"
        case .emotionalLanguage:
            return "Language patterns detected"
        case .appEngagement:
            return "\(profile.getActiveDaysCount()) active days"
        case .special:
            return "Unlocked!"
        }
    }
    
    private func calculateCurrentStreak(profile: UserProfile) -> Int {
        // Simplified streak calculation based on consistency
        let baseStreak = min(profile.daysSinceNoContact, Int(profile.consistencyScore * Double(profile.daysSinceNoContact)))
        return max(1, baseStreak)
    }

    private var safeAchievementIcon: String {
        // Ensure all achievements have a valid icon, fallback to category-specific defaults
        if !achievement.icon.isEmpty {
            return achievement.icon
        }
        
        // Fallback icons based on category
        switch achievement.category {
        case .timeBasedDays:
            return "calendar.circle.fill"
        case .streak:
            return "flame.fill"
        case .journaling:
            return "pencil.circle.fill"
        case .consistency:
            return "heart.circle.fill"
        case .selfCare:
            return "leaf.circle.fill"
        case .emergencySOS:
            return "shield.fill"
        case .emotionalLanguage:
            return "brain.head.profile.fill"
        case .appEngagement:
            return "app.circle.fill"
        case .special:
            return "star.circle.fill"
        }
    }
    

}

struct ParticleSystem: View {
    let achievement: Celebration
    
    @State private var particles: [Particle] = []
    @State private var particleTimer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                ParticleView(particle: particle)
            }
        }
        .onAppear {
            generateParticles()
            startParticleAnimation()
        }
        .onDisappear {
            particleTimer?.invalidate()
            particleTimer = nil
        }
    }
    
    private func generateParticles() {
        // More particles for bigger celebrations
        let particleCount = achievement.category == .special ? 25 : 20
        
        particles = (0..<particleCount).map { _ in
            Particle(
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: UIScreen.main.bounds.height + Double.random(in: 50...150),
                type: particleType,
                color: particleColor,
                size: Double.random(in: 6...14)
            )
        }
    }
    
    private func startParticleAnimation() {
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation(.linear(duration: 0.1)) {
                for i in particles.indices {
                    particles[i].y -= particles[i].speed
                    particles[i].x += particles[i].drift
                    particles[i].rotation += particles[i].rotationSpeed
                    
                    // Reset particle when it goes off screen
                    if particles[i].y < -50 {
                        particles[i].y = UIScreen.main.bounds.height + 50
                        particles[i].x = Double.random(in: 0...UIScreen.main.bounds.width)
                    }
                }
            }
        }
        
        // Auto-stop particles after 6 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            particleTimer?.invalidate()
            particleTimer = nil
        }
    }
    
    private var particleType: ParticleType {
        switch achievement.category {
        case .timeBasedDays, .special:
            return .sparkle
        case .streak:
            return .flame
        case .journaling:
            return .leaf
        case .consistency, .selfCare:
            return .heart
        case .emergencySOS:
            return .sparkle
        case .emotionalLanguage:
            return .heart
        case .appEngagement:
            return .sparkle
        }
    }
    
    private var particleColor: Color {
        switch achievement.category {
        case .timeBasedDays, .special:
            return Color(hex: "#C3B1E1")
        case .streak:
            return Color(hex: "#FF6B35")
        case .journaling:
            return Color(hex: "#8B8680")
        case .consistency, .selfCare:
            return Color(hex: "#B8C5B8")
        case .emergencySOS:
            return Color(hex: "#FF6B35")
        case .emotionalLanguage:
            return Color(hex: "#C3B1E1")
        case .appEngagement:
            return Color(hex: "#8B8680")
        }
    }
}

struct Particle {
    let id = UUID()
    var x: Double
    var y: Double
    let type: ParticleType
    let color: Color
    let size: Double
    let speed: Double = Double.random(in: 1...3)
    let drift: Double = Double.random(in: -0.5...0.5)
    var rotation: Double = 0
    let rotationSpeed: Double = Double.random(in: -2...2)
}

enum ParticleType {
    case sparkle, flame, leaf, heart
}

struct ParticleView: View {
    let particle: Particle
    
    var body: some View {
        Group {
            switch particle.type {
            case .sparkle:
                Image(systemName: "sparkle")
            case .flame:
                Image(systemName: "flame.fill")
            case .leaf:
                Image(systemName: "leaf.fill")
            case .heart:
                Image(systemName: "heart.fill")
            }
        }
        .font(.system(size: particle.size))
        .foregroundColor(particle.color.opacity(0.6))
        .rotationEffect(.degrees(particle.rotation))
        .position(x: particle.x, y: particle.y)
        .blur(radius: 0.5)
    }
}

// MARK: - Extensions

extension MilestoneStatus: Equatable {
    static func == (lhs: MilestoneStatus, rhs: MilestoneStatus) -> Bool {
        switch (lhs, rhs) {
        case (.completed, .completed):
            return true
        case (.inProgress(let lhsProgress), .inProgress(let rhsProgress)):
            return lhsProgress == rhsProgress
        case (.locked, .locked):
            return true
        default:
            return false
        }
    }
} 