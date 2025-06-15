import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0

    @StateObject private var achievementManager = AchievementManager()
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            VStack {
                switch selectedTab {
                case 0:
                    DashboardView(onNavigateToTab: { tabIndex in
                        selectedTab = tabIndex
                    })
                case 1:
                    ProgressPageView()
                case 2:
                    JournalView()
                case 3:
                    ProgramsView()
                default:
            DashboardView()
                }
            }
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabBarButton(
                    title: "Home",
                    icon: "house.fill",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                TabBarButton(
                    title: "Journey",
                    icon: "chart.line.uptrend.xyaxis",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                TabBarButton(
                    title: "Journal",
                    icon: "book.fill",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
                
                TabBarButton(
                    title: "Programs",
                    icon: "leaf.fill",
                    isSelected: selectedTab == 3
                ) {
                    selectedTab = 3
                }
            }
            .frame(height: 80)
            .background(
                Color.white.opacity(0.8)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            achievementManager.setModelContext(modelContext)
            if let profile = profile {
                achievementManager.checkForNewAchievements(profile: profile)
                }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Check for achievements when switching tabs
            if let profile = profile {
                achievementManager.checkForNewAchievements(profile: profile)
            }
        }
        .overlay(
            // Global achievement popup
            Group {
                if achievementManager.showAchievementPopup, let achievement = achievementManager.currentAchievement {
                    GlobalAchievementPopup(
                        achievement: achievement,
                        onDismiss: {
                            achievementManager.dismissAchievement()
                        }
                    )
                }
            }
        )
        .withPaywall()

                }
        }

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(
                        isSelected ? 
                        Color(red: 139/255, green: 134/255, blue: 128/255) :
                        Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5)
                    )
                
                Text(title)
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(
                        isSelected ? 
                        Color(red: 139/255, green: 134/255, blue: 128/255) :
                        Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5)
                    )
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 