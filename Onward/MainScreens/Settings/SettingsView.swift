import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }
    
    @State private var showingChat = false
    @State private var showingDatePicker = false
    @State private var showingRelationshipEditor = false
    @State private var showingDataExport = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            if let profile = profile {
                ScrollView {
                    VStack(spacing: 24) {
                        HeaderView()
                        
                        // No-Contact Tracking Section
                        NoContactTrackingSection(profile: profile) {
                            showingDatePicker = true
                        } onEditRelationship: {
                            showingRelationshipEditor = true
                        }
                        
                        // Notifications Section
                        NotificationsSection(profile: profile)
                        
                        // Privacy & Data Section
                        PrivacyDataSection(profile: profile) {
                            showingDataExport = true
                        } onDeleteData: {
                            showingDeleteConfirmation = true
                        }
                        
                        // Support Section
                        SupportSection()
                        
                        // App Information
                        AppInfoSection()
                        
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
        .sheet(isPresented: $showingDatePicker) {
            if let profile = profile {
                NoContactDateEditorView(profile: profile)
            }
        }
        .sheet(isPresented: $showingRelationshipEditor) {
            if let profile = profile {
                RelationshipEditorView(profile: profile)
            }
        }
        .sheet(isPresented: $showingDataExport) {
            if let profile = profile {
                DataExportView(profile: profile)
            }
        }
        .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your data including journal entries, progress, and profile information. This action cannot be undone.")
        }
    }
    
    private func deleteAllData() {
        let service = PersistenceService(modelContext: modelContext)
        Task {
            await service.deleteAllUserData()
        }
    }
}

// MARK: - Section Views

private struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Settings")
                .font(.custom("Nunito", size: 32))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .padding(.top, 60)
            
            Text("Manage your healing journey")
                .font(.custom("Nunito", size: 16))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
        }
    }
}

private struct NoContactTrackingSection: View {
    let profile: UserProfile
    let onEditDate: () -> Void
    let onEditRelationship: () -> Void
    
    var body: some View {
        SettingSectionCard(title: "No-Contact Tracking") {
            VStack(spacing: 16) {
                // Current duration display
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Duration")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                            
                            Text("\(profile.daysSinceNoContact) days")
                                .font(.custom("Nunito", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        }
                        
                        Spacer()
                        
                        Button("Edit Date", action: onEditDate)
                            .font(.custom("Nunito", size: 14))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    }
                    
                    Divider()
                        .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                }
                
                // Relationship context
                VStack(spacing: 12) {
                    HStack {
                        Text("Relationship Context")
                            .font(.custom("Nunito", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Spacer()
                        
                        Button("Edit", action: onEditRelationship)
                            .font(.custom("Nunito", size: 14))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    }
                    
                    VStack(spacing: 8) {
                        ContextRow(label: "Type", value: profile.relationshipType)
                        ContextRow(label: "Duration", value: profile.relationshipDuration)
                        ContextRow(label: "How it ended", value: profile.reasonForNoContact)
                        ContextRow(label: "Previous attempts", value: profile.previousNoContactAttempts == 0 ? "None" : "\(profile.previousNoContactAttempts)")
                    }
                }
            }
        }
    }
}

private struct ContextRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
            
            Spacer()
            
            Text(value.isEmpty ? "Not set" : value)
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
        }
    }
}

private struct NotificationsSection: View {
    let profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        SettingSectionCard(title: "Notifications") {
            VStack(spacing: 16) {
                ToggleRow(
                    title: "Daily Reminders",
                    subtitle: "Gentle check-ins for your journey",
                    isOn: .init(
                        get: { profile.dailyReminderEnabled },
                        set: { newValue in
                            profile.dailyReminderEnabled = newValue
                            try? modelContext.save()
                        }
                    )
                )
                
                if profile.dailyReminderEnabled {
                    Divider()
                        .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reminder Time")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            
                            Text(timeFormatter.string(from: profile.reminderTime))
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        }
                        
                        Spacer()
                        
                        DatePicker(
                            "",
                            selection: .init(
                                get: { profile.reminderTime },
                                set: { newTime in
                                    profile.reminderTime = newTime
                                    try? modelContext.save()
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                }
                
                Divider()
                    .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                
                ToggleRow(
                    title: "Weekly Progress Reports",
                    subtitle: "Summary of your healing journey",
                    isOn: .init(
                        get: { profile.weeklyReportsEnabled },
                        set: { newValue in
                            profile.weeklyReportsEnabled = newValue
                            try? modelContext.save()
                        }
                    )
                )
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

private struct PrivacyDataSection: View {
    let profile: UserProfile
    let onExportData: () -> Void
    let onDeleteData: () -> Void
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        SettingSectionCard(title: "Privacy & Data") {
            VStack(spacing: 16) {
                ToggleRow(
                    title: "Anonymous Analytics",
                    subtitle: "Help improve the app (no personal data)",
                    isOn: .init(
                        get: { profile.anonymousAnalyticsEnabled },
                        set: { newValue in
                            profile.anonymousAnalyticsEnabled = newValue
                            try? modelContext.save()
                        }
                    )
                )
                
                Divider()
                    .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                
                // Data Export
                Button(action: onExportData) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export My Data")
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            
                            Text("Download all your information")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    }
                }
                
                Divider()
                    .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                
                // Delete Data
                Button(action: onDeleteData) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Delete All Data")
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Text("Permanently remove all information")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

private struct SupportSection: View {
    var body: some View {
        SettingSectionCard(title: "Support") {
            VStack(spacing: 16) {
                ActionRow(
                    title: "Crisis Resources",
                    subtitle: "Immediate help when you need it",
                    icon: "heart.text.square",
                    action: { /* Open crisis resources */ }
                )
                
                Divider()
                    .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                
                ActionRow(
                    title: "Contact Support",
                    subtitle: "Get help with the app",
                    icon: "envelope",
                    action: { /* Open email */ }
                )
                
                Divider()
                    .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                
                ActionRow(
                    title: "FAQ",
                    subtitle: "Common questions and answers",
                    icon: "questionmark.circle",
                    action: { /* Open FAQ */ }
                )
            }
        }
    }
}

private struct AppInfoSection: View {
    var body: some View {
        SettingSectionCard(title: "About") {
            VStack(spacing: 16) {
                HStack {
                    Text("Version")
                        .font(.custom("Nunito", size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.custom("Nunito", size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                }
                
                Divider()
                    .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                
                ActionRow(
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    icon: "lock.shield",
                    action: { /* Open privacy policy */ }
                )
                
                Divider()
                    .background(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2))
                
                ActionRow(
                    title: "Terms of Service",
                    subtitle: "Terms and conditions",
                    icon: "doc.text",
                    action: { /* Open terms */ }
                )
            }
        }
    }
}

// MARK: - Helper Views

private struct SettingSectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Nunito", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            VStack(spacing: 0) {
                content
            }
            .padding(.all, 20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
        }
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Text(subtitle)
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(red: 195/255, green: 177/255, blue: 225/255))
        }
    }
}

private struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Nunito", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text(subtitle)
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            }
        }
    }
}

// MARK: - Additional Views (would be separate files)

struct NoContactDateEditorView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date
    
    init(profile: UserProfile) {
        self.profile = profile
        self._selectedDate = State(initialValue: profile.noContactStartDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Edit No-Contact Start Date")
                    .font(.custom("Nunito", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                DatePicker(
                    "No-Contact Start Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                VStack(spacing: 8) {
                    Text("This will be")
                        .font(.custom("Nunito", size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    
                    Text("\(daysSinceDate) days")
                        .font(.custom("Nunito", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profile.noContactStartDate = selectedDate
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var daysSinceDate: Int {
        Calendar.current.dateComponents([.day], from: selectedDate, to: Date()).day ?? 0
    }
}

struct RelationshipEditorView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var relationshipType: String
    @State private var relationshipDuration: String
    @State private var reasonForNoContact: String
    @State private var previousAttempts: Int
    
    init(profile: UserProfile) {
        self.profile = profile
        self._relationshipType = State(initialValue: profile.relationshipType)
        self._relationshipDuration = State(initialValue: profile.relationshipDuration)
        self._reasonForNoContact = State(initialValue: profile.reasonForNoContact)
        self._previousAttempts = State(initialValue: profile.previousNoContactAttempts)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Edit Relationship Context")
                    .font(.custom("Inter", size: 24))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                VStack(spacing: 24) {
                    // Relationship type
                    SettingsContextSection(
                        title: "What kind of relationship was this?",
                        options: [
                            ("romantic", "Romantic Partnership", "heart.fill"),
                            ("friendship", "Close Friendship", "person.2.fill"),
                            ("family", "Family Relationship", "house.fill"),
                            ("other", "Other Meaningful Connection", "circle.grid.2x2.fill")
                        ],
                        selectedValue: $relationshipType
                    )
                    
                    // Duration
                    SettingsContextSection(
                        title: "How long were you connected?",
                        options: [
                            ("weeks", "Recent weeks", ""),
                            ("months", "Several months", ""),
                            ("year", "About a year", ""),
                            ("years", "Multiple years", ""),
                            ("prefer-not", "Prefer not to specify", "")
                        ],
                        selectedValue: $relationshipDuration
                    )
                    
                    // Reason for no contact
                    SettingsContextSection(
                        title: "How did the no-contact begin?",
                        options: [
                            ("personal", "My personal choice", ""),
                            ("mutual", "Mutual decision we made together", ""),
                            ("their-choice", "Their decision to end contact", ""),
                            ("circumstances", "Life circumstances that separated us", ""),
                            ("prefer-not-share", "Prefer not to share", "")
                        ],
                        selectedValue: $reasonForNoContact
                    )
                }
                
                Spacer()
                
                Button("Save Changes") {
                    // Save and dismiss
                    profile.relationshipType = relationshipType
                    profile.relationshipDuration = relationshipDuration
                    profile.reasonForNoContact = reasonForNoContact
                    profile.previousNoContactAttempts = previousAttempts
                    try? modelContext.save()
                    dismiss()
                }
                .font(.custom("Inter", size: 16))
                .fontWeight(.medium)
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
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct DataExportView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var exportedData: [String: Any] = [:]
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Export Your Data")
                    .font(.custom("Nunito", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Text("Your data will be exported in JSON format and can be shared or saved.")
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    .multilineTextAlignment(.center)
                
                if isLoading {
                    ProgressView()
                        .tint(Color(red: 195/255, green: 177/255, blue: 225/255))
                } else if !exportedData.isEmpty {
                    ScrollView {
                        Text("Data exported successfully!")
                            .font(.custom("Nunito", size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        
                        // Summary of exported data
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Export Summary:")
                                .font(.custom("Nunito", size: 16))
                                .fontWeight(.semibold)
                            
                            Text("• Profile information")
                            Text("• \(profile.journalEntriesCount) journal entries")
                            Text("• \(profile.achievedMilestones.count) milestones")
                            Text("• Progress statistics")
        }
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                    )
                } else {
                    Button("Export Data") {
                        exportData()
                    }
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.semibold)
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
                    .cornerRadius(28)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func exportData() {
        isLoading = true
        let service = PersistenceService(modelContext: modelContext)
        
        Task {
            let data = await service.exportUserData()
            await MainActor.run {
                exportedData = data
                isLoading = false
            }
        }
    }
}

#Preview {
        SettingsView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}

// MARK: - Local Context Section Component for Settings

private struct SettingsContextSection: View {
    let title: String
    let options: [(String, String, String)] // value, display, icon
    @Binding var selectedValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Inter", size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            VStack(spacing: 12) {
                ForEach(options, id: \.0) { option in
                    Button(action: {
                        selectedValue = option.0
                    }) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(selectedValue == option.0 ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color.clear)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255), lineWidth: 2)
                                .frame(width: 20, height: 20)
                            
                            HStack(spacing: 12) {
                                if !option.2.isEmpty {
                                    Image(systemName: option.2)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.6))
                                        .frame(width: 20)
                                }
                                
                                Text(option.1)
                                    .font(.custom("Inter", size: 16))
                                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(
                            Color.white.opacity(0.5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                                )
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}


