import SwiftUI
import Foundation

// MARK: - Paywall Trigger Reasons
enum PaywallTriggerReason {
    case postOnboarding
    case journalLimit
    case premiumProgram
    case historicalInsights
    case timeBasedEngagement
    case dataExport
    case unlimitedAccess
}

// MARK: - Paywall Context
struct PaywallContext {
    let reason: PaywallTriggerReason
    let title: String
    let subtitle: String
    let primaryFeature: String
    
    static func context(for reason: PaywallTriggerReason) -> PaywallContext {
        switch reason {
        case .postOnboarding:
            return PaywallContext(
                reason: reason,
                title: "Complete Your Healing Journey",
                subtitle: "Unlock unlimited access to accelerate your progress",
                primaryFeature: "Unlimited journal entries & all healing programs"
            )
        case .journalLimit:
            return PaywallContext(
                reason: reason,
                title: "You're on a roll! 🌟",
                subtitle: "Unlock unlimited journaling to keep your momentum going",
                primaryFeature: "Unlimited journal entries"
            )
        case .premiumProgram:
            return PaywallContext(
                reason: reason,
                title: "Ready for Advanced Healing?",
                subtitle: "Access specialized 60-day and 90-day programs",
                primaryFeature: "All healing programs"
            )
        case .historicalInsights:
            return PaywallContext(
                reason: reason,
                title: "Track Your Progress",
                subtitle: "See your complete healing journey with detailed insights",
                primaryFeature: "Complete insights & analytics"
            )
        case .timeBasedEngagement:
            return PaywallContext(
                reason: reason,
                title: "You're Making Great Progress!",
                subtitle: "Unlock everything to maximize your healing journey",
                primaryFeature: "Complete premium experience"
            )
        case .dataExport:
            return PaywallContext(
                reason: reason,
                title: "Export Your Journey",
                subtitle: "Download your complete healing data and insights",
                primaryFeature: "Data export & backup"
            )
        case .unlimitedAccess:
            return PaywallContext(
                reason: reason,
                title: "Unlock Full Potential",
                subtitle: "Get unlimited access to all premium features",
                primaryFeature: "Everything unlimited"
            )
        }
    }
}

// MARK: - Paywall Trigger Manager
@MainActor
class PaywallTrigger: ObservableObject {
    static let shared = PaywallTrigger()
    
    @Published var showPaywall = false
    @Published var currentContext: PaywallContext?
    
    private let subscriptionManager = SubscriptionManager.shared
    
    private init() {}
    
    // MARK: - Main Trigger Methods
    
    /// Check if user should see paywall after onboarding
    func checkPostOnboarding() -> Bool {
        guard !subscriptionManager.hasActiveSubscription else { return false }
        
        let context = PaywallContext.context(for: .postOnboarding)
        showPaywallIfNeeded(context: context)
        return true
    }
    
    /// Check journal access and show paywall if limit reached
    func checkJournalAccess() -> Bool {
        guard !subscriptionManager.hasActiveSubscription else { return true }
        
        let weeklyEntries = getWeeklyJournalCount()
        if weeklyEntries >= 3 {
            let context = PaywallContext.context(for: .journalLimit)
            showPaywallIfNeeded(context: context)
            return false
        }
        return true
    }
    
    /// Check access to premium programs
    func checkProgramAccess(programType: String) -> Bool {
        guard !subscriptionManager.hasActiveSubscription else { return true }
        
        // Allow 30-day Fresh Start program for free users
        if programType.contains("30") || programType.lowercased().contains("fresh") {
            return true
        }
        
        let context = PaywallContext.context(for: .premiumProgram)
        showPaywallIfNeeded(context: context)
        return false
    }
    
    /// Check access to historical insights
    func checkInsightsAccess(requestingHistorical: Bool = false) -> Bool {
        guard !subscriptionManager.hasActiveSubscription else { return true }
        
        if requestingHistorical {
            let context = PaywallContext.context(for: .historicalInsights)
            showPaywallIfNeeded(context: context)
            return false
        }
        return true // Current week insights are free
    }
    
    /// Check for time-based engagement triggers
    func checkEngagementTrigger() {
        guard !subscriptionManager.hasActiveSubscription else { return }
        
        let sessionCount = UserDefaults.standard.integer(forKey: "app_session_count")
        let firstLaunch = UserDefaults.standard.object(forKey: "first_app_launch") as? Date ?? Date()
        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        
        // Trigger after 5 sessions OR 7 days of usage
        if sessionCount >= 5 || daysSinceFirstLaunch >= 7 {
            let hasShownEngagementPaywall = UserDefaults.standard.bool(forKey: "shown_engagement_paywall")
            if !hasShownEngagementPaywall {
                let context = PaywallContext.context(for: .timeBasedEngagement)
                showPaywallIfNeeded(context: context)
                UserDefaults.standard.set(true, forKey: "shown_engagement_paywall")
            }
        }
    }
    
    /// Check data export access
    func checkDataExportAccess() -> Bool {
        guard !subscriptionManager.hasActiveSubscription else { return true }
        
        let context = PaywallContext.context(for: .dataExport)
        showPaywallIfNeeded(context: context)
        return false
    }
    
    // MARK: - Helper Methods
    
    private func showPaywallIfNeeded(context: PaywallContext) {
        currentContext = context
        showPaywall = true
    }
    
    private func getWeeklyJournalCount() -> Int {
        // This should be called with a SwiftData context to count actual entries
        // For now, we'll use UserDefaults as a simple counter that gets incremented
        // when journal entries are created (see NewJournalEntryView.saveEntry())
        // The counter automatically resets weekly in checkAndResetWeeklyCounterIfNeeded()
        return UserDefaults.standard.integer(forKey: "weekly_journal_count")
    }
    
    /// Increment session count for engagement tracking
    func trackAppSession() {
        let currentCount = UserDefaults.standard.integer(forKey: "app_session_count")
        UserDefaults.standard.set(currentCount + 1, forKey: "app_session_count")
        
        // Set first launch date if not set
        if UserDefaults.standard.object(forKey: "first_app_launch") == nil {
            UserDefaults.standard.set(Date(), forKey: "first_app_launch")
        }
        
        // Check engagement trigger
        checkEngagementTrigger()
    }
    
    /// Reset weekly journal count (call this weekly)
    func resetWeeklyJournalCount() {
        UserDefaults.standard.set(0, forKey: "weekly_journal_count")
    }
    
    /// Increment weekly journal count
    func incrementJournalCount() {
        // Check if we need to reset the weekly counter
        checkAndResetWeeklyCounterIfNeeded()
        
        let currentCount = UserDefaults.standard.integer(forKey: "weekly_journal_count")
        UserDefaults.standard.set(currentCount + 1, forKey: "weekly_journal_count")
    }
    
    /// Check if we need to reset the weekly counter (called when incrementing)
    private func checkAndResetWeeklyCounterIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the last reset date
        let lastResetKey = "last_weekly_reset_date"
        let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date ?? Date.distantPast
        
        // Check if we're in a new week
        if !calendar.isDate(lastReset, equalTo: now, toGranularity: .weekOfYear) {
            // Reset the counter for the new week
            UserDefaults.standard.set(0, forKey: "weekly_journal_count")
            UserDefaults.standard.set(now, forKey: lastResetKey)
        }
    }
    
    /// Dismiss current paywall
    func dismissPaywall() {
        showPaywall = false
        currentContext = nil
    }
}

// MARK: - SwiftUI View Modifier
struct PaywallModifier: ViewModifier {
    @StateObject private var paywallTrigger = PaywallTrigger.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $paywallTrigger.showPaywall) {
                if let context = paywallTrigger.currentContext {
                    PaywallView(
                        context: context,
                        onDismiss: {
                            paywallTrigger.dismissPaywall()
                        }
                    )
                }
            }
    }
}

extension View {
    func withPaywall() -> some View {
        modifier(PaywallModifier())
    }
} 