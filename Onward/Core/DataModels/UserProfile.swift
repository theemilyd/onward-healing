import Foundation
import SwiftData

@Model
final class UserProfile {
    // Basic profile information
    var name: String
    var startDate: Date // When they started their healing journey
    var noContactStartDate: Date // When they went no-contact
    var whyStatement: String
    @Attribute(.externalStorage) var anchorImage: Data?
    
    // Tracking preferences
    var precisionLevel: String // "day", "hour", "minute"
    
    // Relationship context
    var relationshipType: String // "romantic", "friendship", "family", "other"
    var relationshipDuration: String // "less than 6 months", "6 months - 1 year", "1-3 years", "3+ years"
    var reasonForNoContact: String // "mutual decision", "my decision", "their decision", "circumstances"
    var previousNoContactAttempts: Int
    
    // New onboarding fields
    var noContactDecision: String // "personal", "mutual", "their-choice", "circumstances", "prefer-not-share"
    var previousAttempts: String // "first-time", "tried-before", "multiple", "unsure"
    
    // Healing progress
    var gardenSeedDate: Date
    var currentPlantStage: String
    
    // Store arrays as comma-separated strings to avoid CoreData issues
    private var achievedMilestonesString: String
    private var unlockedAchievementIdsString: String
    private var dailyActivityDatesString: String
    
    // AI Chat tracking
    var aiChatSessionsToday: Int
    var lastChatSessionDate: Date
    var totalChatSessions: Int
    
    // App usage analytics (privacy-focused)
    var appOpenedToday: Int
    var journalEntriesCount: Int
    var lastActiveDate: Date
    
    // Achievement tracking to prevent mass unlocking
    var lastAchievementCheckDate: Date
    
    // Settings
    var dailyReminderEnabled: Bool
    var reminderTime: Date
    var weeklyReportsEnabled: Bool
    var anonymousAnalyticsEnabled: Bool

    // Growth Insights - stored values for caching
    var consistencyScore: Double
    var selfCareScore: Double
    var emotionalStabilityScore: Double
    
    // Computed properties for array access
    var achievedMilestones: [String] {
        get {
            achievedMilestonesString.isEmpty ? [] : achievedMilestonesString.components(separatedBy: ",")
        }
        set {
            achievedMilestonesString = newValue.joined(separator: ",")
        }
    }
    
    var unlockedAchievementIds: [String] {
        get {
            unlockedAchievementIdsString.isEmpty ? [] : unlockedAchievementIdsString.components(separatedBy: ",")
        }
        set {
            unlockedAchievementIdsString = newValue.joined(separator: ",")
        }
    }
    
    var dailyActivityDates: [Date] {
        get {
            guard !dailyActivityDatesString.isEmpty else { return [] }
            let formatter = ISO8601DateFormatter()
            return dailyActivityDatesString.components(separatedBy: ",").compactMap { formatter.date(from: $0) }
        }
        set {
            let formatter = ISO8601DateFormatter()
            dailyActivityDatesString = newValue.map { formatter.string(from: $0) }.joined(separator: ",")
        }
    }
    
    init(
        name: String = "",
        startDate: Date = .now,
        noContactStartDate: Date = .now,
        whyStatement: String = "",
        anchorImage: Data? = nil,
        precisionLevel: String = "day",
        relationshipType: String = "",
        relationshipDuration: String = "",
        reasonForNoContact: String = "",
        previousNoContactAttempts: Int = 0,
        noContactDecision: String = "",
        previousAttempts: String = "",
        gardenSeedDate: Date = .now,
        currentPlantStage: String = "Seed",
        aiChatSessionsToday: Int = 0,
        lastChatSessionDate: Date = .now,
        totalChatSessions: Int = 0,
        appOpenedToday: Int = 0,
        journalEntriesCount: Int = 0,
        lastActiveDate: Date = .now,
        lastAchievementCheckDate: Date = .now,
        unlockedAchievementIds: [String] = [],
        dailyActivityDates: [Date] = [],
        dailyReminderEnabled: Bool = true,
        reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
        weeklyReportsEnabled: Bool = true,
        anonymousAnalyticsEnabled: Bool = true,
        achievedMilestones: [String] = [],
        consistencyScore: Double = 0.0,
        selfCareScore: Double = 0.0,
        emotionalStabilityScore: Double = 0.0
    ) {
        self.name = name
        self.startDate = startDate
        self.noContactStartDate = noContactStartDate
        self.whyStatement = whyStatement
        self.anchorImage = anchorImage
        self.precisionLevel = precisionLevel
        self.relationshipType = relationshipType
        self.relationshipDuration = relationshipDuration
        self.reasonForNoContact = reasonForNoContact
        self.previousNoContactAttempts = previousNoContactAttempts
        self.noContactDecision = noContactDecision
        self.previousAttempts = previousAttempts
        self.gardenSeedDate = gardenSeedDate
        self.currentPlantStage = currentPlantStage
        self.aiChatSessionsToday = aiChatSessionsToday
        self.lastChatSessionDate = lastChatSessionDate
        self.totalChatSessions = totalChatSessions
        self.appOpenedToday = appOpenedToday
        self.journalEntriesCount = journalEntriesCount
        self.lastActiveDate = lastActiveDate
        self.lastAchievementCheckDate = lastAchievementCheckDate
        self.dailyReminderEnabled = dailyReminderEnabled
        self.reminderTime = reminderTime
        self.weeklyReportsEnabled = weeklyReportsEnabled
        self.anonymousAnalyticsEnabled = anonymousAnalyticsEnabled
        self.consistencyScore = consistencyScore
        self.selfCareScore = selfCareScore
        self.emotionalStabilityScore = emotionalStabilityScore
        
        // Initialize string representations of arrays
        self.achievedMilestonesString = achievedMilestones.joined(separator: ",")
        self.unlockedAchievementIdsString = unlockedAchievementIds.joined(separator: ",")
        let formatter = ISO8601DateFormatter()
        self.dailyActivityDatesString = dailyActivityDates.map { formatter.string(from: $0) }.joined(separator: ",")
    }
    
    // Computed properties for convenience
    var daysSinceNoContact: Int {
        Calendar.current.dateComponents([.day], from: noContactStartDate, to: Date()).day ?? 0
    }
    
    var weeksSinceNoContact: Int {
        Calendar.current.dateComponents([.weekOfYear], from: noContactStartDate, to: Date()).weekOfYear ?? 0
    }
    
    var monthsSinceNoContact: Int {
        Calendar.current.dateComponents([.month], from: noContactStartDate, to: Date()).month ?? 0
    }
    
    // Enhanced duration calculations based on precision level
    var hoursSinceNoContact: Int {
        Calendar.current.dateComponents([.hour], from: noContactStartDate, to: Date()).hour ?? 0
    }
    
    var minutesSinceNoContact: Int {
        Calendar.current.dateComponents([.minute], from: noContactStartDate, to: Date()).minute ?? 0
    }
    
    var totalHoursSinceNoContact: Int {
        let totalSeconds = Date().timeIntervalSince(noContactStartDate)
        return Int(totalSeconds / 3600)
    }
    
    var totalMinutesSinceNoContact: Int {
        let totalSeconds = Date().timeIntervalSince(noContactStartDate)
        return Int(totalSeconds / 60)
    }
    
    // Duration components for detailed display
    var durationComponents: DateComponents {
        Calendar.current.dateComponents([.day, .hour, .minute, .second], from: noContactStartDate, to: Date())
    }
    
    // MARK: - Real Backend Logic for Growth Insights
    // These scores are calculated in real-time based on user behavior and provide
    // meaningful feedback about their healing journey progress
    
    // Update consistency score based on current data
    func updateConsistencyScore() {
        let days = max(1, daysSinceNoContact) // Avoid division by zero
        
        // More realistic journal consistency calculation
        let journalRate = Double(journalEntriesCount) / Double(days)
        let journalConsistency = min(0.4, journalRate * 3.0) // Scale up for realistic values
        
        // App usage consistency based on activity days rather than total sessions
        let activeDays = getActiveDaysCount()
        let activityRate = Double(activeDays) / Double(days)
        let appUsageConsistency = min(0.3, activityRate * 0.5)
        
        // Time-based bonus for persistence (starts low, grows over time)
        let timeBonus = min(0.3, sqrt(Double(days)) / 30.0 * 0.3)
        
        consistencyScore = min(1.0, journalConsistency + appUsageConsistency + timeBonus)
    }
    
    // Update self-care score based on current data
    func updateSelfCareScore() {
        let days = max(1, daysSinceNoContact)
        
        // More realistic app engagement calculation
        let sessionRate = Double(totalChatSessions) / Double(days)
        let appEngagement = min(0.4, sessionRate * 2.0) // More generous scaling
        
        // Journal writing as self-care - more realistic calculation
        let journalRate = Double(journalEntriesCount) / Double(days)
        let journalSelfCare = min(0.3, journalRate * 5.0) // More generous for journaling
        
        // Achievement progress bonus
        let totalPossibleAchievements = 20.0 // Realistic number of basic achievements
        let achievementRate = Double(unlockedAchievementIds.count) / totalPossibleAchievements
        let milestoneBonus = min(0.3, achievementRate * 0.4)
        
        selfCareScore = min(1.0, appEngagement + journalSelfCare + milestoneBonus)
    }
    
    // Update emotional stability score based on current data
    func updateEmotionalStabilityScore() {
        let days = max(1, daysSinceNoContact)
        
        // Base stability improves gradually over time (0-0.5)
        let timeStability = min(0.5, 0.3 + (Double(days) * 0.005))
        
        // Consistency bonus (0-0.25)
        let consistencyBonus = consistencyScore * 0.25
        
        // Self-care bonus (0-0.25)
        let selfCareBonus = selfCareScore * 0.25
        
        emotionalStabilityScore = min(1.0, timeStability + consistencyBonus + selfCareBonus)
    }
    
    // MARK: - App Engagement Tracking
    
    // Count of active days (days when user opened app or made journal entries)
    func getActiveDaysCount() -> Int {
        // Use actual tracked activity dates for more accurate calculation
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -daysSinceNoContact, to: Date()) ?? noContactStartDate
        
        // Count unique days since no-contact start date
        let activeDaysInPeriod = dailyActivityDates.filter { activityDate in
            activityDate >= cutoffDate && activityDate <= Date()
        }
        
        return activeDaysInPeriod.count
    }
    
    // MARK: - Emotional Language Pattern Detection
    
    // These would analyze journal entries for positive language patterns
    // For MVP, using simplified logic based on user engagement
    
    func hasPositiveLanguagePattern() -> Bool {
        // Users who journal regularly tend to develop more positive language
        return journalEntriesCount >= 5 && consistencyScore >= 0.6
    }
    
    func hasGratitudePattern() -> Bool {
        // Gratitude emerges with consistent journaling and self-care
        return journalEntriesCount >= 10 && selfCareScore >= 0.7
    }
    
    func hasStrengthLanguage() -> Bool {
        // Strength language develops over time with healing
        return daysSinceNoContact >= 14 && emotionalStabilityScore >= 0.7
    }
    
    func hasSelfCompassionLanguage() -> Bool {
        // Self-compassion grows with journaling and emotional stability
        return journalEntriesCount >= 8 && emotionalStabilityScore >= 0.6
    }
    
    func hasGrowthMindsetLanguage() -> Bool {
        // Growth mindset emerges with consistent app engagement
        return getActiveDaysCount() >= 7 && consistencyScore >= 0.8
    }
    
    // MARK: - Achievement and Streak Management
    
    // Track daily activity for better streak calculation
    func recordDailyActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        var currentDates = dailyActivityDates
        if !currentDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            currentDates.append(today)
            // Keep only last 90 days for performance
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: today) ?? today
            currentDates = currentDates.filter { $0 >= cutoffDate }
            dailyActivityDates = currentDates
        }
    }
    
    // Calculate actual streak based on consecutive active days
    func getCurrentStreak() -> Int {
        let currentDates = dailyActivityDates
        guard !currentDates.isEmpty else { return 0 }
        
        let sortedDates = currentDates.sorted(by: >)
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        var streak = 0
        var currentDate = today
        
        // Check if user was active today or yesterday (allow for some flexibility)
        if sortedDates.contains(today) {
            streak = 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        } else if sortedDates.contains(yesterday) {
            streak = 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: yesterday)!
        } else {
            return 0
        }
        
        // Count consecutive days backwards
        while sortedDates.contains(currentDate) {
            streak += 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return max(0, streak - 1) // Subtract 1 because we counted the starting day twice
    }
    
    // Unlock achievement helper
    func unlockAchievement(achievementId: String) {
        var currentIds = unlockedAchievementIds
        if !currentIds.contains(achievementId) {
            currentIds.append(achievementId)
            unlockedAchievementIds = currentIds
        }
    }
} 