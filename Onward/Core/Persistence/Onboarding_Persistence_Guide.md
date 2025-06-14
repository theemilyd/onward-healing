# Onboarding Data Persistence

This document explains how user data from the onboarding flow is saved using the `PersistenceService`.

## Saving the User Profile

At the end of the onboarding process (specifically, when the user taps the "Begin Your Journey" button on the `PlantSeedView`), the application should gather the data collected from the previous screens:

1.  The `whyStatement` from the `WhyView`.
2.  The `anchorImage` data from the `AnchorImageView`.

With this information, the app will then call the `createProfile` method on an instance of our `PersistenceService`.

### Example Flow:

```swift
// In PlantSeedView (or a coordinator managing the onboarding flow)

// 1. Get the ModelContext from the environment
@Environment(\.modelContext) private var modelContext

// 2. Get the user's input from the previous screens
let userWhyStatement = "To find peace within myself..." // This would be passed from WhyView
let userAnchorImage = anImage.jpegData(compressionQuality: 0.8) // This would be passed from AnchorImageView

// 3. On button tap, create the service and call the function
Button("Begin Your Journey") {
    let persistenceService = PersistenceService(modelContext: modelContext)
    Task {
        await persistenceService.createProfile(
            whyStatement: userWhyStatement,
            anchorImage: userAnchorImage
        )
        
        // After saving, transition to the MainTabView
    }
}
```

This action creates a new `UserProfile` record in the SwiftData database, persisting the user's essential starting information and officially completing the setup process. The existence of this profile will then be used by the app to skip the onboarding flow on subsequent launches. 