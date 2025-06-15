import SwiftUI

struct ProgramsView: View {
    @StateObject private var programManager = ProgramManager.shared
    @State private var showingChat = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
        ZStack {
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    HeaderView()
                    
                    // Today's Focus Section
                    TodaysFocusSection(programManager: programManager)
                    
                    // Daily Sessions Section (Days 1-30)
                    DailySessionsSection(programManager: programManager)
                }
                .padding(.top, 48)
                .padding(.bottom, 120) // Space for floating button and tab bar
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
                            Text("SOS")
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
        .onAppear {
            programManager.checkForNewDay()
        }
        .sheet(isPresented: $showingChat) {
            ChatView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        }
    }
}

// MARK: - Header
private struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Navigation header
            HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
                
                Spacer()
                
                Text("No Contact Tracker")
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
            }
            .padding(.horizontal, 24)
            
            // Title and subtitle
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Programs")
                            .font(.custom("Nunito", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text("Evidence-based healing programs")
                            .font(.custom("Nunito", size: 16))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    }
                    
                    Spacer()
                }
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Today's Focus
private struct TodaysFocusSection: View {
    let programManager: ProgramManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text("Today's Focus")
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
                
                if programManager.getCurrentProgram() != nil {
                    Text("Day \(programManager.currentDay) of 30")
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if let todaysSession = programManager.getTodaysSession() {
                    Text(todaysSession.title)
                        .font(.custom("Nunito", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text(todaysSession.subtitle)
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .lineSpacing(4)
                    
                    NavigationLink(destination: DailySessionLearningView(session: todaysSession)) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .medium))
                            Text("Start Today's Session")
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 195/255, green: 177/255, blue: 225/255),
                                    Color(red: 184/255, green: 197/255, blue: 184/255)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                } else {
                    Text("Start Your Journey")
                        .font(.custom("Nunito", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text("Begin with Day 1 to start your transformation")
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .lineSpacing(4)
                }
            }
        }
        .padding(20)
        .background(
            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.08)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
}

// MARK: - Daily Sessions
private struct DailySessionsSection: View {
    let programManager: ProgramManager
    @State private var showingAllDays = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("30-Day Transformation Journey")
                    .font(.custom("Nunito", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                let daysToShow = showingAllDays ? Array(1...30) : Array(1...3)
                
                ForEach(daysToShow, id: \.self) { day in
                    DayCard(
                        day: day,
                        programManager: programManager
                    )
                }
                
                if !showingAllDays {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingAllDays = true
                        }
                    }) {
                        HStack {
                            Text("View All Days")
                                .font(.custom("Nunito", size: 14))
                                .fontWeight(.medium)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                        )
                    }
                } else {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingAllDays = false
                        }
                    }) {
                        HStack {
                            Text("Show Less")
                                .font(.custom("Nunito", size: 14))
                                .fontWeight(.medium)
                            
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Day Card
private struct DayCard: View {
    let day: Int
    @ObservedObject var programManager: ProgramManager
    
    private var session: Session? {
        programManager.getSession(for: day)
    }
    
    private var state: DayState {
        programManager.getState(for: day)
    }
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack(spacing: 16) {
                // Day number circle
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 48, height: 48)
                    
                    if state == .completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(iconColor)
                    } else {
                        Text("\(day)")
                            .font(.custom("Nunito", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(textColor)
                    }
                }
                
                // Session info
                VStack(alignment: .leading, spacing: 4) {
                    Text(session?.title ?? "Day \(day)")
                        .font(.custom("Nunito", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(titleColor)
                    
                    Text(session?.subtitle ?? "Unlock by completing previous days")
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(subtitleColor)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Status indicator
                if state == .locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3))
                } else if state == .today {
                    Text("Today")
                        .font(.custom("Nunito", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.15))
                        )
                }
            }
            .padding(16)
            .background(
                Color.white
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: state == .today ? 1.5 : 1)
                    )
            )
            .cornerRadius(12)
            .opacity(state == .locked ? 0.6 : 1.0)
        }
        .disabled(state == .locked)
        .simultaneousGesture(TapGesture().onEnded {
            if day == 1 && programManager.getCurrentProgram() == nil {
                programManager.startProgram("30-day-fresh-start")
            }
        })
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let session = session {
            DailySessionLearningView(session: session)
        } else {
            // Empty view for locked states to prevent navigation
            EmptyView()
        }
    }
    
    // MARK: - Styling
    
    private var circleColor: Color {
        switch state {
        case .today:
            return Color(red: 195/255, green: 177/255, blue: 225/255)
        case .completed:
            return Color(red: 235/255, green: 232/255, blue: 238/255) // Subtle purple-gray
        case .unlocked:
            return Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.15)
        case .locked:
            return Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1)
        }
    }
    
    private var textColor: Color {
        switch state {
        case .today:
            return .white
        case .unlocked:
            return Color(red: 195/255, green: 177/255, blue: 225/255)
        default:
            return Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5)
        }
    }
    
    private var iconColor: Color {
        return Color(red: 195/255, green: 177/255, blue: 225/255) // Main purple
    }
    
    private var titleColor: Color {
        state == .locked ? Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5) : Color(red: 139/255, green: 134/255, blue: 128/255)
    }
    
    private var subtitleColor: Color {
        state == .locked ? Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.4) : Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7)
    }
    
    private var borderColor: Color {
        state == .today ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 220/255, green: 220/255, blue: 225/255).opacity(0.4)
    }
}

struct ProgramsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramsView()
    }
} 