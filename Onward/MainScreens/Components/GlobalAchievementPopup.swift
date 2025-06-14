import SwiftUI

struct GlobalAchievementPopup: View {
    let achievement: Celebration
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Achievement card
            VStack(spacing: 24) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                    }
                }
                
                // Achievement header
                VStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    
                    Text(achievementBadgeText)
                        .font(.custom("Nunito", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .textCase(.uppercase)
                        .tracking(1)
                }
                
                // Achievement icon and details
                VStack(spacing: 16) {
                    // Icon with glow effect
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        categoryColor.opacity(0.3),
                                        categoryColor.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(categoryColor.opacity(0.3), lineWidth: 2)
                            )
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(categoryColor)
                    }
                    
                    // Achievement title and description
                    VStack(spacing: 12) {
                        Text(achievement.title)
                            .font(.custom("Nunito", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            .multilineTextAlignment(.center)
                        
                                            Text(emotionalSubtitle)
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                    }
                }
                
                // Progress section (like in second image)
                if achievement.category == .timeBasedDays {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Healing Journey")
                                    .font(.custom("Nunito", size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                
                                Text("\(achievement.requirement) days")
                                    .font(.custom("Nunito", size: 12))
                                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Next: \(nextMilestone) days")
                                    .font(.custom("Nunito", size: 12))
                                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                            }
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                                    .frame(width: geometry.size.width, height: 6)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 6)
                        
                        HStack {
                            Text("Start")
                                .font(.custom("Nunito", size: 12))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 8)
                }
                
                // Continue button
                Button(action: onDismiss) {
                    Text("Continue Growing")
                        .font(.custom("Nunito", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                        )
                }
                .padding(.horizontal, 20)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        ))
    }
    
    // Achievement rarity (number of stars)
    private var achievementRarity: Int {
        switch achievement.category {
        case .timeBasedDays:
            if achievement.requirement >= 365 { return 5 }
            else if achievement.requirement >= 180 { return 4 }
            else if achievement.requirement >= 90 { return 3 }
            else if achievement.requirement >= 30 { return 2 }
            else { return 1 }
        case .streak:
            if achievement.requirement >= 30 { return 4 }
            else if achievement.requirement >= 14 { return 3 }
            else if achievement.requirement >= 7 { return 2 }
            else { return 1 }
        case .journaling:
            if achievement.requirement >= 100 { return 5 }
            else if achievement.requirement >= 50 { return 4 }
            else if achievement.requirement >= 25 { return 3 }
            else if achievement.requirement >= 10 { return 2 }
            else { return 1 }
        case .consistency, .selfCare:
            if achievement.requirement >= 95 { return 5 }
            else if achievement.requirement >= 85 { return 4 }
            else if achievement.requirement >= 70 { return 3 }
            else { return 2 }
        case .emergencySOS:
            if achievement.requirement >= 15 { return 5 }
            else if achievement.requirement >= 10 { return 4 }
            else if achievement.requirement >= 5 { return 3 }
            else if achievement.requirement >= 3 { return 2 }
            else { return 1 }
        case .emotionalLanguage:
            return 3 // Language achievements are medium rarity
        case .appEngagement:
            if achievement.requirement >= 60 { return 5 }
            else if achievement.requirement >= 30 { return 4 }
            else if achievement.requirement >= 14 { return 3 }
            else if achievement.requirement >= 7 { return 2 }
            else { return 1 }
        case .special:
            return 4 // Special achievements are always high rarity
        }
    }
    
    private var categoryColor: Color {
        switch achievement.category {
        case .timeBasedDays:
            return Color(red: 195/255, green: 177/255, blue: 225/255) // Purple - brand primary
        case .streak:
            return Color(red: 255/255, green: 107/255, blue: 53/255) // Orange - energy
        case .journaling:
            return Color(red: 184/255, green: 197/255, blue: 184/255) // Sage green - growth
        case .consistency, .selfCare:
            return Color(red: 184/255, green: 197/255, blue: 184/255) // Sage green - healing
        case .emergencySOS:
            return Color(red: 255/255, green: 107/255, blue: 53/255) // Orange - crisis/emergency
        case .emotionalLanguage:
            return Color(red: 184/255, green: 197/255, blue: 184/255) // Sage green - emotional growth
        case .appEngagement:
            return Color(red: 195/255, green: 177/255, blue: 225/255) // Purple - engagement
        case .special:
            return Color(red: 195/255, green: 177/255, blue: 225/255) // Purple - special moments
        }
    }
    
    private var achievementBadgeText: String {
        switch achievement.category {
        case .timeBasedDays:
            return "\(achievement.requirement) Day Milestone"
        case .streak:
            return "Streak Achievement"
        case .journaling:
            return "Writing Achievement"
        case .consistency:
            return "Consistency Achievement"
        case .selfCare:
            return "Self-Care Achievement"
        case .emergencySOS:
            return "Crisis Management Achievement"
        case .emotionalLanguage:
            return "Language Pattern Achievement"
        case .appEngagement:
            return "Engagement Achievement"
        case .special:
            return "Special Achievement"
        }
    }
    
    // Gentle and encouraging subtitles
    private var emotionalSubtitle: String {
        switch achievement.category {
        case .timeBasedDays:
            if achievement.requirement >= 365 {
                return "A full year of choosing yourself. You've completely transformed your life through daily acts of courage and self-love."
            } else if achievement.requirement >= 90 {
                return "Three months of consistent growth. Look at the strength you've built through choosing yourself every single day."
            } else if achievement.requirement >= 30 {
                return "Thirty days of choosing yourself. This milestone represents something beautiful taking root in your life."
            } else if achievement.requirement >= 7 {
                return "A whole week of courage. You took the hardest step and kept going. This foundation will carry you forward."
            } else {
                return "Your healing garden is growing beautifully. You've taken the first step of your journey."
            }
        case .streak:
            return "Your consistency is powerful. Every day you show up for yourself, you're building unshakeable inner strength."
        case .journaling:
            return "Your words are healing you. Each entry is a step toward understanding and accepting yourself more deeply."
        case .consistency:
            return "Your dedication is inspiring. This consistency is changing your life in ways you may not even see yet."
        case .selfCare:
            return "You're learning to love yourself. This self-care journey is the most important work you'll ever do."
        case .emergencySOS:
            return "In your moments of crisis, you chose healing over hurt. This strength will carry you through anything life brings."
        case .emotionalLanguage:
            return "Your language patterns show incredible emotional growth. You're developing a healthier relationship with your thoughts."
        case .appEngagement:
            return "Your commitment to showing up for yourself every day is transforming your life in beautiful ways."
        case .special:
            return "You've unlocked something truly special. This combination of growth shows how far you've come on your healing journey."
        }
    }
    
    private var nextMilestone: Int {
        let milestones = [3, 7, 14, 21, 30, 60, 90, 180, 365]
        return milestones.first { $0 > achievement.requirement } ?? (achievement.requirement + 30)
    }
} 