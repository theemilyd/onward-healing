import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.dateCreated, order: .reverse) private var entries: [JournalEntry]
    
    @State private var selectedTab = 0
    @State private var showingNewEntry = false
    @State private var showingChat = false
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 250/255, green: 247/255, blue: 245/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HeaderView()
                    
                    // Custom Tab Selector
                    TabSelectorView()
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        EntriesListView()
                            .tag(0)
                        
                        LettersToMyselfView()
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                // Settings button in top-right corner
            VStack {
                    HStack {
                        Spacer()
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                    }
                    Spacer()
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
            .sheet(isPresented: $showingNewEntry) {
                NewJournalEntryView()
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

// MARK: - Subviews

private extension JournalView {
    
    func HeaderView() -> some View {
        VStack(spacing: 29) {
            Text("Journal")
                .font(.custom("Nunito", size: 24))
                .fontWeight(.regular)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .padding(.top, 43)
        }
        .frame(height: 100)
    }
    
    func TabSelectorView() -> some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                Text("Entries")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(selectedTab == 0 ? .white : Color(red: 139/255, green: 134/255, blue: 128/255))
                    .frame(width: 166, height: 44)
                    .background(
                        selectedTab == 0 ? 
                        Color(red: 195/255, green: 177/255, blue: 225/255) :
                        Color.clear
                    )
                    .cornerRadius(9999)
            }
            
            Button(action: { selectedTab = 1 }) {
                Text("Letters to Myself")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(selectedTab == 1 ? .white : Color(red: 139/255, green: 134/255, blue: 128/255))
                    .frame(width: 166, height: 44)
                    .background(
                        selectedTab == 1 ? 
                        Color(red: 195/255, green: 177/255, blue: 225/255) :
                        Color.clear
                    )
                    .cornerRadius(9999)
            }
        }
        .frame(width: 342, height: 54)
        .background(
            Color.white.opacity(0.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
        .cornerRadius(9999)
    }
    
    func EntriesListView() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Today's Prompt Card
                TodaysPromptCard()
                
                // Journal Entries
                if entries.isEmpty {
                    EmptyStateView()
                } else {
                    ForEach(entries) { entry in
                        NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                            JournalEntryRowContent(entry: entry)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    func LettersToMyselfView() -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Letters to Myself")
                .font(.custom("Nunito", size: 24))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            Text("This feature is coming soon!")
                .font(.custom("Nunito", size: 16))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
            
            Spacer()
        }
        .padding(.bottom, 100) // Space for floating button
    }
}

// MARK: - Additional Components

private struct TodaysPromptCard: View {
    @StateObject private var programManager = ProgramManager.shared
    @State private var showingNewEntry = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        
                Text("Today's Prompt")
                            .font(.custom("Nunito", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                    
                    Text(programManager.getTodaysPrompt())
                        .font(.custom("Nunito", size: 13))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .lineLimit(2)
                        .lineSpacing(2)
                }
                
                Spacer()
            }
            
            Button(action: { 
                if PaywallTrigger.shared.checkJournalAccess() {
                    showingNewEntry = true
                }
            }) {
                Text("Start Writing")
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
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
                    .cornerRadius(20)
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
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView()
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.6))
            
            VStack(spacing: 8) {
                Text("Your journey starts here")
                    .font(.custom("Nunito", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Text("Begin by writing your first entry. Every word is a step forward.")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.vertical, 40)
    }
}

private struct JournalEntryRowContent: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatDate(entry.dateCreated))
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                
                Spacer()
                
                if hasSpecialMoment {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 255/255, green: 193/255, blue: 7/255))
                }
                
                HStack(spacing: 4) {
                Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(estimatedReadTime)
                }
                .font(.custom("Nunito", size: 12))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
            }
            
            Text(previewText)
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .lineSpacing(4)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white.opacity(0.8)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 220/255, green: 220/255, blue: 225/255).opacity(0.4), lineWidth: 1)
                )
        )
        .cornerRadius(12)
    }
    
    private var previewText: String {
        let cleanText = entry.contentText
            .replacingOccurrences(of: "Mood: [A-Za-z]+\n\n", with: "", options: .regularExpression)
        return cleanText.count > 120 ? String(cleanText.prefix(120)) + "..." : cleanText
    }
    
    private var hasSpecialMoment: Bool {
        // Simple check for positive words or breakthrough moments
        let positiveWords = ["breakthrough", "peaceful", "grateful", "proud", "strong", "better", "happy", "hopeful"]
        return positiveWords.contains { entry.contentText.lowercased().contains($0) }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }
    
    private var estimatedReadTime: String {
        let wordCount = entry.contentText.split(separator: " ").count
        let readingSpeed = 200 // words per minute
        let minutes = max(1, wordCount / readingSpeed)
        return "\(minutes) min read"
    }
}

// MARK: - Journal Entry Detail View

struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @Environment(\.dismiss) private var dismiss
    @State private var showingImageFullScreen = false
    @State private var showingOptions = false
    @State private var showingEditEntry = false
    @StateObject private var programManager = ProgramManager.shared
    @Query private var profiles: [UserProfile]
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        ZStack {
            // Background gradient matching the design
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 250/255, green: 247/255, blue: 245/255), // cream
                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.05) // dusty-lavender/5
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Entry Date & Time
                        dateTimeView
                        
                        // Mood Display
                        if let mood = extractedMood {
                            moodDisplayView(mood: mood)
                        }
                        
                        // Original Prompt (if available)
                        promptView
                        
                        // Entry Content
                        entryContentView
                        
                        // Entry Statistics
                        entryStatsView
                        
                        // Image display if present
                        if let imageData = entry.imageData,
                           let uiImage = UIImage(data: imageData) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                                    
                                    Text("Photo")
                                        .font(.custom("Inter", size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                    
                                    Spacer()
                                    
                                    Button("View Full") {
                                        showingImageFullScreen = true
                                    }
                                    .font(.custom("Inter", size: 12))
                                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                                }
                                
                                Button(action: { showingImageFullScreen = true }) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxHeight: 200)
                                        .clipped()
                                        .cornerRadius(16)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Audio player if present
                        if entry.audioURL != nil {
                            audioDisplayView
                        }
                        
                        // Bottom spacing
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            
            // Floating Actions
            floatingActionsView
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingOptions) {
            optionsMenuView
        }
        .sheet(isPresented: $showingEditEntry) {
            EditJournalEntryView(entry: entry)
        }
        .fullScreenCover(isPresented: $showingImageFullScreen) {
            if let imageData = entry.imageData,
               let uiImage = UIImage(data: imageData) {
                FullScreenImageView(image: uiImage, isPresented: $showingImageFullScreen)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                    .padding(8)
                    .background(Circle().fill(Color.clear))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "book.open")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text("Your Entry")
                    .font(.custom("Inter", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            Spacer()
            
            Button(action: { showingOptions = true }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                    .padding(8)
                    .background(Circle().fill(Color.clear))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 16)
        .background(
            Color(red: 250/255, green: 247/255, blue: 245/255).opacity(0.9)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1))
                        .offset(y: 16)
                )
        )
    }
    
    // MARK: - New View Components
    
    private var dateTimeView: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(formatDateOnly(entry.dateCreated))
                    .font(.custom("Inter", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Text(formatTimeOnly(entry.dateCreated))
                    .font(.custom("Inter", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
            }
            
            Rectangle()
                .frame(width: 80, height: 2)
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3))
                .cornerRadius(1)
        }
    }
    
    private func moodDisplayView(mood: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: moodIcon(for: mood))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            
            Text(mood)
                .font(.custom("Inter", size: 14))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var promptView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2))
                    .overlay(
                        Image(systemName: "lightbulb")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("That Day's Prompt")
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text(getPromptForDate(entry.dateCreated))
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.8))
                        .lineSpacing(4)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1),
                            Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var entryContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(cleanedContentText)
                .font(.custom("Inter", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var entryStatsView: some View {
        HStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("Words")
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                Text("\(wordCount)")
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            VStack(spacing: 4) {
                Text("Reading time")
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                Text(estimatedReadTime)
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            VStack(spacing: 4) {
                Text("Day")
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                Text("\(profile?.daysSinceNoContact ?? 0)")
                    .font(.custom("Inter", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
        }
    }
    
    private var audioDisplayView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Button(action: {
                    // Play audio
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Voice Note")
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text("Tap to play")
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var floatingActionsView: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Add to favorites
            }) {
                Image(systemName: "heart")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.8))
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            
            Button(action: {
                showingEditEntry = true
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.8))
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.trailing, 24)
        .padding(.bottom, 24)
    }
    
    private var optionsMenuView: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 48, height: 4)
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3))
                .cornerRadius(2)
                .padding(.top, 24)
                .padding(.bottom, 24)
            
            VStack(spacing: 16) {
                Button(action: {
                    showingOptions = false
                    showingEditEntry = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        
                        Text("Edit this entry")
                            .font(.custom("Inter", size: 16))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.clear)
                    )
                }
                
                Button(action: {
                    showingOptions = false
                    // Add to favorites
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "heart")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        
                        Text("Add to favorites")
                            .font(.custom("Inter", size: 16))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.clear)
                    )
                }
                
                Button(action: {
                    showingOptions = false
                    // Export entry
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        
                        Text("Export entry")
                            .font(.custom("Inter", size: 16))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.clear)
                    )
                }
                
                Button(action: {
                    showingOptions = false
                    // Delete entry
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                        
                        Text("Delete entry")
                            .font(.custom("Inter", size: 16))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.clear)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(
            Color(red: 250/255, green: 247/255, blue: 245/255).opacity(0.95)
        )
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    // Helper computed properties
    private var cleanedContentText: String {
        var text = entry.contentText
        
        // Remove mood prefix if present
        if text.hasPrefix("Mood: ") {
            let lines = text.components(separatedBy: "\n")
            if lines.count > 2 {
                text = lines.dropFirst(2).joined(separator: "\n")
            }
        }
        
        // Remove photo and audio attachment indicators
        text = text.replacingOccurrences(of: "\n\n📷 Photo attached to this entry", with: "")
        text = text.replacingOccurrences(of: "\n\n🎤 Voice note recorded for this entry", with: "")
        text = text.replacingOccurrences(of: "📷 Photo attached to this entry", with: "")
        text = text.replacingOccurrences(of: "🎤 Voice note recorded for this entry", with: "")
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var extractedMood: String? {
        let text = entry.contentText
        if text.hasPrefix("Mood: ") {
            let firstLine = text.components(separatedBy: "\n").first ?? ""
            return String(firstLine.dropFirst(6)) // Remove "Mood: " prefix
        }
        return nil
    }
    
    private var wordCount: Int {
        cleanedContentText.split(separator: " ").count
    }
    
    private var estimatedReadTime: String {
        let readingSpeed = 200 // words per minute
        let minutes = max(1, wordCount / readingSpeed)
        return "\(minutes) min read"
    }
    
    private var hasSpecialMoment: Bool {
        // Simple check for positive words or breakthrough moments
        let positiveWords = ["breakthrough", "peaceful", "grateful", "proud", "strong", "better", "happy", "hopeful"]
        return positiveWords.contains { cleanedContentText.lowercased().contains($0) }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm a"
            return formatter.string(from: date)
        }
    }
    
    private func formatDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTimeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "EEEE 'evening', h:mm a"
            return formatter.string(from: date)
        }
    }
    
    private var daysSinceNoContact: Int {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.day], from: entry.dateCreated, to: today)
        return components.day ?? 0
    }
    
    private func moodIcon(for mood: String) -> String {
        switch mood.lowercased() {
        case "peaceful": return "leaf.fill"
        case "grateful": return "heart.fill"
        case "reflective": return "moon.fill"
        case "hopeful": return "star.fill"
        case "overwhelmed": return "cloud.fill"
        case "tender": return "face.smiling.inverse"
        default: return "heart.fill"
        }
    }
    
    private func getPromptForDate(_ date: Date) -> String {
        let prompts = [
            "What is one small thing that brought you comfort today? It could be as simple as a warm cup of tea, a kind word, or a moment of quiet.",
            "Describe a moment today when you felt truly present. What were you doing, and what did you notice around you?",
            "What would you like to tell yourself about the progress you've made recently, no matter how small?",
            "If your past self could see you now, what would surprise them most about your journey?",
            "What is one thing you're grateful for today that you might have overlooked?",
            "How did you show kindness to yourself or others today?",
            "What feeling are you ready to let go of, and what would you like to invite in instead?",
            "Write about a challenge you faced today and how you handled it with grace.",
            "What does peace look like for you in this moment?",
            "Describe something beautiful you noticed today, whether big or small.",
            "What small victory can you celebrate from this week?",
            "What moment today reminded you of your own strength?",
            "What would you tell someone else going through your situation?",
            "What are three things your past self would be proud of?",
            "How are you different now than when you started this journey?"
        ]
        
        // Use the date to ensure consistent prompt for that day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return prompts[dayOfYear % prompts.count]
    }
}

// MARK: - Full Screen Image View

struct FullScreenImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        if scale < 1 {
                                            scale = 1
                                            offset = .zero
                                        } else if scale > 3 {
                                            scale = 3
                                        }
                                    }
                                },
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        if scale <= 1 {
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                    )
                
                Spacer()
            }
        }
    }
}

// MARK: - Edit Journal Entry View

struct EditJournalEntryView: View {
    let entry: JournalEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var contentText: String = ""
    @State private var selectedMood: String? = nil
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Spacer()
                    
                    Text("Edit Entry")
                        .font(.custom("Inter", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Spacer()
                    
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    .fontWeight(.medium)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mood Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How are you feeling?")
                                .font(.custom("Inter", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(["Peaceful", "Grateful", "Reflective", "Hopeful", "Overwhelmed", "Tender"], id: \.self) { mood in
                                    Button(action: {
                                        selectedMood = selectedMood == mood ? nil : mood
                                    }) {
                                        Text(mood)
                                            .font(.custom("Inter", size: 14))
                                            .foregroundColor(selectedMood == mood ? .white : Color(red: 139/255, green: 134/255, blue: 128/255))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(selectedMood == mood ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color.white.opacity(0.7))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Image Section
                        if let selectedImage = selectedImage {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Photo")
                                        .font(.custom("Inter", size: 16))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                    
                                    Spacer()
                                    
                                    Button("Remove") {
                                        self.selectedImage = nil
                                    }
                                    .foregroundColor(.red)
                                }
                                
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                            }
                        } else {
                            HStack(spacing: 16) {
                                Button(action: { showingCamera = true }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Camera")
                                    }
                                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                                    .padding()
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(12)
                                }
                                
                                Button(action: { showingImagePicker = true }) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text("Photos")
                                    }
                                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                                    .padding()
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(12)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Text Area
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your thoughts")
                                .font(.custom("Inter", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            
                            TextEditor(text: $contentText)
                                .font(.custom("Inter", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                .frame(minHeight: 200)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.7))
                                )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .background(Color(red: 250/255, green: 247/255, blue: 245/255))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .onAppear {
            loadEntryData()
        }
    }
    
    private func loadEntryData() {
        // Extract mood from content if it exists
        if entry.contentText.hasPrefix("Mood: ") {
            let lines = entry.contentText.components(separatedBy: "\n")
            if let firstLine = lines.first {
                selectedMood = String(firstLine.dropFirst(6)) // Remove "Mood: " prefix
            }
            // Remove mood line from content
            contentText = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            contentText = entry.contentText
        }
        
        // Load image if it exists
        if let imageData = entry.imageData {
            selectedImage = UIImage(data: imageData)
        }
    }
    
    private func saveChanges() {
        // Update the entry content
        var newContent = contentText
        if let mood = selectedMood {
            newContent = "Mood: \(mood)\n\n\(contentText)"
        }
        
        entry.contentText = newContent
        
        // Update image data
        if let image = selectedImage {
            entry.imageData = image.jpegData(compressionQuality: 0.8)
        } else {
            entry.imageData = nil
        }
        
        // Save to context
        do {
            try modelContext.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
        
        dismiss()
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .modelContainer(for: [JournalEntry.self], inMemory: true)
    }
} 