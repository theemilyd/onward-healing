import Foundation

struct RevenueCatConfig {
    // MARK: - API Keys
    // Replace these with your actual RevenueCat API keys
    static let apiKey = "appl_HCQcBYssoIhGRmmViUixbaAUqPB"
    
    // MARK: - Product Identifiers
    // These should match your App Store Connect in-app purchase product IDs
    static let weeklyProductId = "onward_weekly_6_99"
    static let yearlyProductId = "onward_yearly_49_99"
    
    // MARK: - Entitlement Identifiers
    // These should match your RevenueCat dashboard entitlement configuration
    static let premiumEntitlementId = "premium"
    
    // MARK: - Package Identifiers
    // These should match your RevenueCat dashboard offering configuration
    static let weeklyPackageId = "weekly"
    static let yearlyPackageId = "yearly"
    
    // MARK: - Configuration Validation
    static var isConfigured: Bool {
        return apiKey != "appl_HCQcBYssoIhGRmmViUixbaAUqPB" && !apiKey.isEmpty
    }
    
    static func validateConfiguration() {
        if !isConfigured {
            print("⚠️ RevenueCat API key not configured! Please update RevenueCatConfig.swift")
        } else {
            print("✅ RevenueCat configuration looks good!")
        }
    }
    
    // MARK: - Setup Instructions
    /*
     To complete the RevenueCat integration:
     
     1. Create a RevenueCat account at https://app.revenuecat.com
     
     2. Create a new app in RevenueCat dashboard
     
     3. Replace 'your_revenuecat_api_key_here' with your actual API key from:
        RevenueCat Dashboard > Your App > API Keys
     
     4. Create products in App Store Connect:
        - Product ID: onward_weekly_6_99
        - Type: Auto-renewable subscription
        - Price: $6.99
        - Duration: 1 week
        - Free trial: 3 days
        
        - Product ID: onward_yearly_49_99
        - Type: Auto-renewable subscription
        - Price: $49.99
        - Duration: 1 year
        - No free trial
     
     5. Configure products in RevenueCat dashboard:
        - Go to Products tab
        - Add both product IDs
        - Create an entitlement called "premium"
        - Attach both products to the "premium" entitlement
     
     6. Create an offering in RevenueCat dashboard:
        - Go to Offerings tab
        - Create packages with identifiers "weekly" and "yearly"
        - Attach the respective products to each package
     
     7. Test with sandbox users in App Store Connect
     
     8. Submit for App Store review with in-app purchases
     */
} 