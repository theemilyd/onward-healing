import SwiftUI
import SwiftData

@main
struct NoContactTrackerApp: App {
    
    let container: ModelContainer
    
    init() {
        // Initialize subscription manager on app launch
        _ = SubscriptionManager.shared
        
        // Validate RevenueCat configuration
        RevenueCatConfig.validateConfiguration()
        
        // Track app session for engagement-based paywall triggers
        PaywallTrigger.shared.trackAppSession()
        
        let schema = Schema([UserProfile.self, JournalEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Could not load persistent store, likely due to a schema migration issue. Error: \(error)")
            
            // Try to delete the old store and create a new one
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            print("Deleted old store file, attempting to create new store...")
            
            do {
                container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("Successfully created new store after deleting old one")
            } catch {
                print("Still failed after deleting old store, falling back to in-memory store. Error: \(error)")
                // If the persistent store still fails to load, create an in-memory store as a fallback.
                do {
                    let inMemoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                    container = try ModelContainer(for: schema, configurations: [inMemoryConfiguration])
                } catch {
                    // If even the in-memory store fails, there is a more fundamental problem.
                    fatalError("Could not create in-memory ModelContainer: \(error)")
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @Query private var profiles: [UserProfile]
    
    private var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    var body: some View {
        if profiles.first != nil && hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingFlowView()
        }
    }
} 