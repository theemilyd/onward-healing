import Foundation
import SwiftData

class MilestoneManager {
    private let profile: UserProfile

    init(profile: UserProfile) {
        self.profile = profile
    }

    /// Checks for any new, unachieved milestones and updates the profile.
    /// Also updates the plant stage if a relevant milestone is hit.
    /// - Returns: The newly achieved `Milestone` if there is one, otherwise `nil`.
    @MainActor
    func checkAndAwardMilestones() -> Milestone? {
        let startDate = profile.startDate
        
        let elapsed = Date().timeIntervalSince(startDate)
        var newlyAchieved: Milestone?

        for milestone in Milestone.allCases {
            // Check if this milestone is achieved and not already in the user's profile
            if !profile.achievedMilestones.contains(milestone.rawValue) && isMilestoneReached(milestone, elapsed: elapsed) {
                profile.achievedMilestones.append(milestone.rawValue)
                newlyAchieved = milestone // We'll notify the user about this one
                
                // Update plant stage based on the new milestone
                updatePlantStage(for: milestone)
                
                // We only award one milestone per check to not overwhelm the user.
                // The next check will award the next one if applicable.
                break
            }
        }
        
        return newlyAchieved
    }
    
    private func isMilestoneReached(_ milestone: Milestone, elapsed: TimeInterval) -> Bool {
        let secondsInDay = 86400.0
        switch milestone {
        case .oneDay: return elapsed >= secondsInDay
        case .threeDays: return elapsed >= secondsInDay * 3
        case .oneWeek: return elapsed >= secondsInDay * 7
        case .twoWeeks: return elapsed >= secondsInDay * 14
        case .oneMonth: return elapsed >= secondsInDay * 30
        }
    }

    private func updatePlantStage(for milestone: Milestone) {
        switch milestone {
        case .oneWeek:
            if profile.currentPlantStage == "Seed" {
                profile.currentPlantStage = "Sprout"
            }
        case .oneMonth:
             if profile.currentPlantStage == "Sprout" {
                profile.currentPlantStage = "Sapling"
            }
        default:
            // Other milestones don't change the plant stage in this version
            break
        }
    }
} 