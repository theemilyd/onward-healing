import SwiftUI
import SwiftData

struct HealingGardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }
    
    @State private var plantScale: CGFloat = 1.0
    @State private var showLoveAnimation = false
    @State private var plantLoves = 0
    @State private var showHearts = false
    @State private var showingChat = false
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            if let profile = profile {
                ScrollView {
                    VStack(spacing: 32) {
                        HeaderView(profile: profile)
                        InteractivePlantView(profile: profile)
                        GrowthStageCard(profile: profile)
                        TipOfTheDayCard()
                        Spacer(minLength: 100) // Space for floating button
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            } else {
                VStack {
                    Text("No profile found")
                        .font(.custom("Nunito", size: 18))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
            }
            
            // Floating Talk Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingChat = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Talk")
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
            .navigationBarHidden(true)
        .sheet(isPresented: $showingChat) {
            ChatView()
        }
    }
}

struct HealingGardenView_Previews: PreviewProvider {
    static var previews: some View {
        HealingGardenView()
            .modelContainer(for: [UserProfile.self], inMemory: true)
    }
}

// MARK: - Subviews

private extension HealingGardenView {
    
    func HeaderView(profile: UserProfile) -> some View {
        VStack(spacing: 11) {
            Text("Your Garden")
                .font(.custom("Nunito", size: 24))
                .fontWeight(.regular)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            Text("\(daysSinceStart(profile: profile)) days of nurturing growth")
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
        }
        .padding(.top, 43)
        .frame(height: 120)
    }
    
    func InteractivePlantView(profile: UserProfile) -> some View {
        ZStack {
            // Outer glow circle
            Circle()
                .fill(Color.clear)
                .frame(width: 256, height: 256)
                .background(
                    Circle()
                        .fill(Color.clear)
                        .shadow(color: plantStageColor(stage: profile.currentPlantStage).opacity(0.2), radius: 30)
                )
            
            // Main plant circle
            ZStack {
                // Background gradient circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: plantStageColor(stage: profile.currentPlantStage).opacity(0.1), location: 0),
                                .init(color: plantStageColor(stage: profile.currentPlantStage).opacity(0.2), location: 1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 192, height: 192)
                
                // Plant content
                VStack {
                    HStack {
                        // Small decorative circles
                        Circle()
                            .fill(plantStageColor(stage: profile.currentPlantStage).opacity(0.6))
                            .frame(width: 12, height: 12)
                            .offset(x: 32, y: 8)
                        
                        Spacer()
                        
                        Circle()
                            .fill(plantStageColor(stage: profile.currentPlantStage).opacity(0.5))
                            .frame(width: 8, height: 8)
                            .offset(x: -32, y: -4)
                    }
                    
                    // Plant image - changes based on stage
                    Image(systemName: plantStageIcon(stage: profile.currentPlantStage))
                        .font(.system(size: plantSize(stage: profile.currentPlantStage)))
                        .foregroundColor(plantStageColor(stage: profile.currentPlantStage))
                        .scaleEffect(plantScale)
                        .animation(.easeInOut(duration: 0.3), value: plantScale)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                plantScale = 1.2
                                showLoveAnimation = true
                                plantLoves += 1
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    plantScale = 1.0
                                    showLoveAnimation = false
                                }
                            }
                        }
                    
                    Spacer()
                }
                .frame(width: 128, height: 160)
                .padding(.top, 16)
                
                // Love animation hearts
                if showLoveAnimation {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.system(size: 12))
                            .offset(
                                x: CGFloat.random(in: -40...40),
                                y: CGFloat.random(in: -40...40)
                            )
                            .opacity(showLoveAnimation ? 1 : 0)
                            .animation(.easeOut(duration: 1.5).delay(Double(index) * 0.1), value: showLoveAnimation)
                    }
                }
                
                // Shadow at bottom
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1), location: 0),
                                .init(color: Color.clear, location: 1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 160, height: 32)
                    .offset(y: 80)
            }
            .frame(width: 192, height: 192)
        }
        .frame(width: 256, height: 256)
    }
    
    func GrowthStageCard(profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 13) {
                Text("Growth Stage")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                
                Text(profile.currentPlantStage)
                    .font(.custom("Nunito", size: 18))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                // Progress bar - shows progress to next stage
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(9999)
                    
                    Rectangle()
                        .fill(plantStageColor(stage: profile.currentPlantStage))
                        .frame(width: progressBarWidth(profile: profile), height: 8)
                        .cornerRadius(9999)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                Color.white.opacity(0.3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(plantStageColor(stage: profile.currentPlantStage).opacity(0.2), lineWidth: 1)
                    )
            )
            .cornerRadius(16)
            
            Text(growthMessage(stage: profile.currentPlantStage))
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    func TipOfTheDayCard() -> some View {
        VStack(spacing: 16) {
            Text("Tap your plant to give it some love")
                .font(.custom("Nunito", size: 12))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
    
    // Helper functions for dynamic content
    private func daysSinceStart(profile: UserProfile) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: profile.startDate, to: Date())
        return components.day ?? 0
    }
    
    private func plantStageColor(stage: String) -> Color {
        switch stage {
        case "Seed":
            return Color(red: 139/255, green: 134/255, blue: 128/255)
        case "Sprout":
            return Color(red: 184/255, green: 197/255, blue: 184/255)
        case "Sapling":
            return Color(red: 34/255, green: 139/255, blue: 34/255)
        default:
            return Color(red: 184/255, green: 197/255, blue: 184/255)
        }
    }
    
    private func plantStageIcon(stage: String) -> String {
        switch stage {
        case "Seed":
            return "circle.fill"
        case "Sprout":
            return "leaf.fill"
        case "Sapling":
            return "tree.fill"
        default:
            return "leaf.fill"
        }
    }
    
    private func plantSize(stage: String) -> CGFloat {
        switch stage {
        case "Seed":
            return 60
        case "Sprout":
            return 80
        case "Sapling":
            return 100
        default:
            return 80
        }
    }
    
    private func progressBarWidth(profile: UserProfile) -> CGFloat {
        let days = daysSinceStart(profile: profile)
        let stage = profile.currentPlantStage
        
        switch stage {
        case "Seed":
            // Progress from 0 to 7 days (when it becomes sprout)
            let progress = min(CGFloat(days) / 7.0, 1.0)
            return progress * 286 // Full width
        case "Sprout":
            // Progress from 7 to 30 days (when it becomes sapling)
            let daysInStage = max(0, days - 7)
            let progress = min(CGFloat(daysInStage) / 23.0, 1.0)
            return progress * 286
        case "Sapling":
            return 286 // Full progress
        default:
            return 95 // Default partial progress
        }
    }
    
    private func growthMessage(stage: String) -> String {
        switch stage {
        case "Seed":
            return "Your journey has begun. This seed holds all the potential for your healing and growth."
        case "Sprout":
            return "Your sprout is growing beautifully. Each day of healing adds to its strength and resilience."
        case "Sapling":
            return "Look how far you've come! Your sapling stands strong, representing your continued growth and healing."
        default:
            return "Your healing journey continues to flourish with each passing day."
        }
    }
} 