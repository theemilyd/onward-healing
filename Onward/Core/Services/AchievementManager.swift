import SwiftUI
import SwiftData

@MainActor
class AchievementManager: ObservableObject {
    @Published var showAchievementPopup = false
    @Published var currentAchievement: Celebration?
    @Published var achievementQueue: [Celebration] = []
    @Published var isShowingAchievement = false
    
    private var modelContext: ModelContext?
    
    init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // Check for new achievements and queue them for display
    func checkForNewAchievements(profile: UserProfile) {
        let newAchievements = getNewlyUnlockedAchievements(profile: profile)
        
        if !newAchievements.isEmpty && !isShowingAchievement {
            achievementQueue.append(contentsOf: newAchievements)
            showNextAchievement()
        }
    }
    
    private func getNewlyUnlockedAchievements(profile: UserProfile) -> [Celebration] {
        var celebrations: [Celebration] = []
        let streak = profile.getCurrentStreak()
        
        // Time-based achievements
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
            
            if isUnlocked && !profile.unlockedAchievementIds.contains(achievementId) {
                profile.unlockAchievement(achievementId: achievementId)
                
                // Check if we've already shown this achievement
                let shownIds = UserDefaults.standard.stringArray(forKey: "shownAchievements") ?? []
                if !shownIds.contains(achievementId) {
                    celebrations.append(Celebration(
                        title: title,
                        subtitle: subtitle,
                        icon: icon,
                        isUnlocked: true,
                        category: .timeBasedDays,
                        requirement: days
                    ))
                }
            }
        }
        
        // Streak achievements
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
            
            if isUnlocked && !profile.unlockedAchievementIds.contains(achievementId) {
                profile.unlockAchievement(achievementId: achievementId)
                
                let shownIds = UserDefaults.standard.stringArray(forKey: "shownAchievements") ?? []
                if !shownIds.contains(achievementId) {
                    celebrations.append(Celebration(
                        title: title,
                        subtitle: subtitle,
                        icon: icon,
                        isUnlocked: true,
                        category: .streak,
                        requirement: streakDays
                    ))
                }
            }
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
            let achievementId = "journal_\(count)_entries"
            if profile.journalEntriesCount >= count && !profile.unlockedAchievementIds.contains(achievementId) {
                profile.unlockAchievement(achievementId: achievementId)
                
                let shownIds = UserDefaults.standard.stringArray(forKey: "shownAchievements") ?? []
                if !shownIds.contains(achievementId) {
                    celebrations.append(Celebration(
                        title: title,
                        subtitle: subtitle,
                        icon: icon,
                        isUnlocked: true,
                        category: .journaling,
                        requirement: count
                    ))
                }
            }
        }
        
        // Save context if we made changes
        if !celebrations.isEmpty {
            try? modelContext?.save()
        }
        
        return celebrations
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
    
    private func showNextAchievement() {
        guard !achievementQueue.isEmpty, !isShowingAchievement else { return }
        
        let achievement = achievementQueue.removeFirst()
        currentAchievement = achievement
        isShowingAchievement = true
        
        withAnimation(.easeOut(duration: 0.3)) {
            showAchievementPopup = true
        }
    }
    
    func dismissAchievement() {
        guard let achievement = currentAchievement else { return }
        
        // Mark achievement as shown
        if getCurrentProfile() != nil {
            var shownIds = UserDefaults.standard.stringArray(forKey: "shownAchievements") ?? []
            let achievementId = getAchievementId(for: achievement)
            if !shownIds.contains(achievementId) {
                shownIds.append(achievementId)
                UserDefaults.standard.set(shownIds, forKey: "shownAchievements")
            }
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            showAchievementPopup = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentAchievement = nil
            self.isShowingAchievement = false
            
            // Show next achievement if any
            if !self.achievementQueue.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showNextAchievement()
                }
            }
        }
    }
    
    private func getCurrentProfile() -> UserProfile? {
        guard let modelContext = modelContext else { return nil }
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try? modelContext.fetch(descriptor)
        return profiles?.first
    }
    
    private func getAchievementId(for achievement: Celebration) -> String {
        switch achievement.category {
        case .timeBasedDays:
            return "time_\(achievement.requirement)_days"
        case .streak:
            return "streak_\(achievement.requirement)_days"
        case .journaling:
            return "journal_\(achievement.requirement)_entries"
        case .consistency:
            return "consistency_\(achievement.requirement)_percent"
        case .selfCare:
            return "selfcare_\(achievement.requirement)_percent"
        case .emergencySOS:
            return "sos_\(achievement.requirement)_sessions"
        case .emotionalLanguage:
            return "emotional_\(achievement.title.lowercased().replacingOccurrences(of: " ", with: "_"))"
        case .appEngagement:
            return "engagement_\(achievement.requirement)_days"
        case .special:
            return "special_\(achievement.title.lowercased().replacingOccurrences(of: " ", with: "_"))"
        }
    }
} 