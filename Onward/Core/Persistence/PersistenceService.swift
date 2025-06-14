import Foundation
import SwiftData

actor PersistenceService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - UserProfile
    
    /// Creates and saves the initial user profile with no-contact tracking. This should be called after onboarding is complete.
    func createProfile(
        noContactStartDate: Date,
        whyStatement: String,
        anchorImage: Data?,
        relationshipType: String,
        relationshipDuration: String,
        reasonForNoContact: String,
        previousAttempts: Int
    ) {
        let profile = UserProfile(
            startDate: Date(),
            noContactStartDate: noContactStartDate,
            whyStatement: whyStatement,
            anchorImage: anchorImage,
            relationshipType: relationshipType,
            relationshipDuration: relationshipDuration,
            reasonForNoContact: reasonForNoContact,
            previousNoContactAttempts: previousAttempts
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }
    
    /// Updates the no-contact start date if user needs to correct it
    func updateNoContactStartDate(_ date: Date) {
        guard let profile = fetchProfile() else { return }
        profile.noContactStartDate = date
        try? modelContext.save()
    }
    
    /// Updates relationship context information
    func updateRelationshipContext(
        type: String,
        duration: String,
        reason: String,
        previousAttempts: Int
    ) {
        guard let profile = fetchProfile() else { return }
        profile.relationshipType = type
        profile.relationshipDuration = duration
        profile.reasonForNoContact = reason
        profile.previousNoContactAttempts = previousAttempts
        try? modelContext.save()
    }
    
    /// Fetches the single user profile. Returns nil if no profile exists.
    func fetchProfile() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try? modelContext.fetch(descriptor)
        return profiles?.first
    }
    
    /// Updates daily app usage metrics and tracks activity for streak calculation
    func trackDailyAppUsage() {
        guard let profile = fetchProfile() else { return }
        
        let calendar = Calendar.current
        if !calendar.isDateInToday(profile.lastActiveDate) {
            profile.appOpenedToday = 1
            profile.lastActiveDate = Date()
            
            // Record daily activity for streak calculation
            profile.recordDailyActivity()
            
            // Update scores when daily activity changes
            profile.updateConsistencyScore()
            profile.updateSelfCareScore()
            profile.updateEmotionalStabilityScore()
        } else {
            profile.appOpenedToday += 1
        }
        
        try? modelContext.save()
    }
    
    // MARK: - JournalEntry

    /// Creates and saves a new journal entry with mood tracking.
    func createJournalEntry(content: String, mood: String? = nil) {
        guard let profile = fetchProfile() else { return }
        let entry = JournalEntry(contentText: content, profile: profile)
        
        // Update journal count in profile
        profile.journalEntriesCount += 1
        
        // Update last active date for consistency tracking
        profile.lastActiveDate = Date()
        
        // Record daily activity for streak calculation
        profile.recordDailyActivity()
        
        // Update scores when journal activity changes
        profile.updateConsistencyScore()
        profile.updateSelfCareScore()
        profile.updateEmotionalStabilityScore()
        
        // Check for achievement unlocks
        checkJournalAchievements(profile: profile)
        
        modelContext.insert(entry)
        try? modelContext.save()
    }
    
    /// Check and unlock journal-based achievements
    private func checkJournalAchievements(profile: UserProfile) {
        let journalMilestones = [1, 5, 10, 25, 50, 100]
        
        for milestone in journalMilestones {
            let achievementId = "journal_\(milestone)_entries"
            if profile.journalEntriesCount >= milestone && 
               !profile.unlockedAchievementIds.contains(achievementId) {
                profile.unlockAchievement(achievementId: achievementId)
            }
        }
    }

    /// Fetches all journal entries, sorted by creation date.
    /// Implements a limit of 15 entries for the free version.
    func fetchJournalEntries() -> [JournalEntry] {
        var descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        descriptor.fetchLimit = 15 // Limit for free version
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Deletes a specific journal entry.
    func deleteJournalEntry(_ entry: JournalEntry) {
        guard let profile = fetchProfile() else { return }
        profile.journalEntriesCount = max(0, profile.journalEntriesCount - 1)
        modelContext.delete(entry)
        try? modelContext.save()
    }
    
    // MARK: - AI Chat Tracking
    
    /// Records a new SOS session (emergency support when user wants to break no contact)
    func recordSOSSession() {
        guard let profile = fetchProfile() else { return }
        
        let calendar = Calendar.current
        if !calendar.isDateInToday(profile.lastChatSessionDate) {
            profile.aiChatSessionsToday = 1
            profile.lastChatSessionDate = Date()
        } else {
            profile.aiChatSessionsToday += 1
        }
        
        profile.totalChatSessions += 1
        
        // Update last active date for engagement tracking
        profile.lastActiveDate = Date()
        
        // Update scores when chat activity changes
        profile.updateSelfCareScore()
        profile.updateEmotionalStabilityScore()
        
        try? modelContext.save()
    }
    
    // MARK: - User Settings
    
    /// Updates notification and privacy settings
    func updateSettings(
        dailyReminder: Bool,
        reminderTime: Date,
        weeklyReports: Bool,
        anonymousAnalytics: Bool
    ) {
        guard let profile = fetchProfile() else { return }
        profile.dailyReminderEnabled = dailyReminder
        profile.reminderTime = reminderTime
        profile.weeklyReportsEnabled = weeklyReports
        profile.anonymousAnalyticsEnabled = anonymousAnalytics
        try? modelContext.save()
    }
    
    // MARK: - Milestones

    /// Marks a milestone as achieved for the current user.
    func awardMilestone(_ milestone: Milestone) {
        guard let profile = fetchProfile() else { return }
        if !profile.achievedMilestones.contains(milestone.rawValue) {
            profile.achievedMilestones.append(milestone.rawValue)
            try? modelContext.save()
        }
    }

    /// Returns all achieved milestones as an array of `Milestone` objects.
    func getAchievedMilestones() -> [Milestone] {
        guard let profile = fetchProfile() else { return [] }
        return profile.achievedMilestones.compactMap { Milestone(rawValue: $0) }
    }
    
    // MARK: - Data Export & Privacy
    
    /// Exports user data for GDPR compliance
    func exportUserData() -> [String: Any] {
        guard let profile = fetchProfile() else { return [:] }
        
        let journalEntries = fetchJournalEntries().map { entry in
            [
                "date": entry.dateCreated,
                "content": entry.contentText,
                "wordCount": entry.contentText.split(separator: " ").count
            ]
        }
        
        return [
            "profile": [
                "startDate": profile.startDate,
                "noContactStartDate": profile.noContactStartDate,
                "relationshipType": profile.relationshipType,
                "relationshipDuration": profile.relationshipDuration,
                "reasonForNoContact": profile.reasonForNoContact,
                "previousAttempts": profile.previousNoContactAttempts,
                "currentPlantStage": profile.currentPlantStage,
                "achievedMilestones": profile.achievedMilestones,
                "totalChatSessions": profile.totalChatSessions,
                "journalEntriesCount": profile.journalEntriesCount
            ],
            "journalEntries": journalEntries,
            "statistics": [
                "daysSinceNoContact": profile.daysSinceNoContact,
                "weeksSinceNoContact": profile.weeksSinceNoContact,
                "monthsSinceNoContact": profile.monthsSinceNoContact
            ]
        ]
    }
    
    /// Deletes all user data for GDPR compliance
    func deleteAllUserData() {
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let journalDescriptor = FetchDescriptor<JournalEntry>()
        
        if let profiles = try? modelContext.fetch(profileDescriptor) {
            profiles.forEach { modelContext.delete($0) }
        }
        
        if let entries = try? modelContext.fetch(journalDescriptor) {
            entries.forEach { modelContext.delete($0) }
        }
        
        try? modelContext.save()
    }
} 