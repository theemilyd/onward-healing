import Foundation
import RevenueCat
import SwiftUI

@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var customerInfo: CustomerInfo?
    @Published var currentOffering: Offering?
    @Published var isSubscriptionActive = false
    @Published var isLoading = false
    @Published var subscriptionType: SubscriptionType = .none
    
    // Product identifiers - these should match your App Store Connect setup
    private let weeklyProductId = RevenueCatConfig.weeklyProductId
    private let yearlyProductId = RevenueCatConfig.yearlyProductId
    
    enum SubscriptionType {
        case none
        case weekly
        case yearly
        case trial
    }
    
    private override init() {
        super.init()
        setupRevenueCat()
    }
    
    private func setupRevenueCat() {
        // Use the API key from configuration
        Purchases.configure(withAPIKey: RevenueCatConfig.apiKey)
        
        // Set up delegate
        Purchases.shared.delegate = self
        
        // Fetch initial customer info
        Task {
            await fetchCustomerInfo()
            await fetchCurrentOffering()
        }
    }
    
    func fetchCustomerInfo() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.customerInfo = customerInfo
                self.updateSubscriptionStatus(customerInfo)
            }
        } catch {
            print("Failed to fetch customer info: \(error)")
        }
    }
    
    func fetchCurrentOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.currentOffering = offerings.current
            }
        } catch {
            print("Failed to fetch offerings: \(error)")
        }
    }
    
    private func updateSubscriptionStatus(_ customerInfo: CustomerInfo) {
        // Check if user has active subscription
        isSubscriptionActive = customerInfo.entitlements.active.isEmpty == false
        
        // Debug logging for App Store review
        print("🔍 SUBSCRIPTION DEBUG:")
        print("   - Active entitlements: \(customerInfo.entitlements.active.keys)")
        print("   - Is subscription active: \(isSubscriptionActive)")
        
        // Determine subscription type
        if let activeEntitlement = customerInfo.entitlements.active.first?.value {
            print("   - Active entitlement product: \(activeEntitlement.productIdentifier)")
            print("   - Period type: \(activeEntitlement.periodType)")
            
            if activeEntitlement.productIdentifier == weeklyProductId {
                subscriptionType = .weekly
            } else if activeEntitlement.productIdentifier == yearlyProductId {
                subscriptionType = .yearly
            }
            
            // Check if it's still in trial period
            if activeEntitlement.periodType == .intro || activeEntitlement.periodType == .trial {
                subscriptionType = .trial
                print("   - User is in trial period")
            }
        } else {
            subscriptionType = .none
            print("   - No active entitlements found")
        }
        
        print("   - Final subscription type: \(subscriptionType)")
        print("   - Has active subscription: \(hasActiveSubscription)")
        print("   - Can access unlimited journal: \(canAccessUnlimitedJournal())")
        print("   - Can access all programs: \(canAccessAllPrograms())")
        print("   - Can access complete insights: \(canAccessCompleteInsights())")
        print("   - Can export data: \(canExportData())")
        
        // Force UI update to ensure immediate feature unlock
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        }
    }
    
    func purchaseWeeklySubscription() async -> Bool {
        guard let offering = currentOffering,
              let weeklyPackage = offering.package(identifier: RevenueCatConfig.weeklyPackageId) else {
            print("Weekly package not found")
            return false
        }
        
        return await purchasePackage(weeklyPackage)
    }
    
    func purchaseYearlySubscription() async -> Bool {
        guard let offering = currentOffering,
              let yearlyPackage = offering.package(identifier: RevenueCatConfig.yearlyPackageId) else {
            print("Yearly package not found")
            return false
        }
        
        return await purchasePackage(yearlyPackage)
    }
    
    private func purchasePackage(_ package: Package) async -> Bool {
        isLoading = true
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            
            await MainActor.run {
                self.customerInfo = result.customerInfo
                self.updateSubscriptionStatus(result.customerInfo)
                self.isLoading = false
            }
            
            return !result.userCancelled
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Purchase failed: \(error)")
            return false
        }
    }
    
    func restorePurchases() async -> Bool {
        isLoading = true
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            
            await MainActor.run {
                self.customerInfo = customerInfo
                self.updateSubscriptionStatus(customerInfo)
                self.isLoading = false
            }
            
            return true
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Restore failed: \(error)")
            return false
        }
    }
    
    // MARK: - Free Trial & Paywall Logic
    
    var isInFreeTrial: Bool {
        subscriptionType == .trial
    }
    
    var hasActiveSubscription: Bool {
        isSubscriptionActive && subscriptionType != .none
    }
    
    var shouldShowPaywall: Bool {
        !hasActiveSubscription && !isInFreeTrial
    }
    
    // MARK: - Feature Access Control - CRITICAL FOR APP STORE APPROVAL
    
    func canAccessUnlimitedJournal() -> Bool {
        let hasAccess = hasActiveSubscription || isInFreeTrial
        print("🔍 Journal Access Check: \(hasAccess) (active: \(hasActiveSubscription), trial: \(isInFreeTrial))")
        return hasAccess
    }
    
    func canAccessAllPrograms() -> Bool {
        let hasAccess = hasActiveSubscription || isInFreeTrial
        print("🔍 Programs Access Check: \(hasAccess) (active: \(hasActiveSubscription), trial: \(isInFreeTrial))")
        return hasAccess
    }
    
    func canAccessCompleteInsights() -> Bool {
        let hasAccess = hasActiveSubscription || isInFreeTrial
        print("🔍 Insights Access Check: \(hasAccess) (active: \(hasActiveSubscription), trial: \(isInFreeTrial))")
        return hasAccess
    }
    
    func canExportData() -> Bool {
        let hasAccess = hasActiveSubscription || isInFreeTrial
        print("🔍 Data Export Access Check: \(hasAccess) (active: \(hasActiveSubscription), trial: \(isInFreeTrial))")
        return hasAccess
    }
    
    // MARK: - Journal Entry Limit Logic
    
    func getRemainingJournalEntries() -> Int {
        if canAccessUnlimitedJournal() {
            return Int.max // Unlimited
        }
        
        // For free users, limit to 3 per week
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        // This would need to be connected to your journal data
        // For now, returning a placeholder
        let entriesThisWeek = getJournalEntriesCount(since: startOfWeek)
        return max(0, 3 - entriesThisWeek)
    }
    
    private func getJournalEntriesCount(since date: Date) -> Int {
        // For now, we use the weekly counter from UserDefaults
        // This gets incremented in NewJournalEntryView when entries are saved
        // In a future version, this could query SwiftData directly for more accuracy
        return UserDefaults.standard.integer(forKey: "weekly_journal_count")
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.customerInfo = customerInfo
            self.updateSubscriptionStatus(customerInfo)
        }
    }
}

// MARK: - Subscription Models

struct SubscriptionProduct {
    let id: String
    let title: String
    let subtitle: String
    let price: String
    let period: String
    let badge: String?
    let isRecommended: Bool
}

extension SubscriptionManager {
    var availableProducts: [SubscriptionProduct] {
        guard let offering = currentOffering else { return [] }
        
        var products: [SubscriptionProduct] = []
        
        // Weekly product
        if let weeklyPackage = offering.package(identifier: "weekly") {
            products.append(SubscriptionProduct(
                id: "weekly",
                title: "Weekly Access",
                subtitle: "Flexible commitment",
                price: weeklyPackage.storeProduct.localizedPriceString,
                period: "per week",
                badge: "3 Days Free",
                isRecommended: false
            ))
        }
        
        // Yearly product
        if let yearlyPackage = offering.package(identifier: "yearly") {
            products.append(SubscriptionProduct(
                id: "yearly",
                title: "Yearly Access",
                subtitle: "Complete healing journey",
                price: yearlyPackage.storeProduct.localizedPriceString,
                period: "per year",
                badge: "50% OFF",
                isRecommended: true
            ))
        }
        
        return products
    }
}

// MARK: - Notification Names for Immediate UI Updates
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
} 