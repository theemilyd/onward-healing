import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [UserProfile]
    @State private var showingDatePicker = false
    @Environment(\.modelContext) private var modelContext
    
    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            noContactSettingsSection()
        }
        .padding()
    }

    private func noContactSettingsSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("No-Contact Tracking")
                .font(.custom("Nunito", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            if let profile = profile {
                VStack(spacing: 16) {
                    // Current no-contact period display
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Period")
                                .font(.custom("Nunito", size: 14))
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                            
                            Text("\(profile.daysSinceNoContact) days")
                                .font(.custom("Nunito", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        }
                        
                        Spacer()
                        
                        Text("🌱")
                            .font(.system(size: 32))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Time Precision Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tracking Precision")
                            .font(.custom("Nunito", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Text("Choose how precisely you want to track your no-contact duration")
                            .font(.custom("Nunito", size: 14))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        
                        VStack(spacing: 8) {
                            ForEach(["day", "hour", "minute"], id: \.self) { precision in
                                Button(action: {
                                    profile.precisionLevel = precision
                                    try? modelContext.save()
                                }) {
                                    HStack {
                                        Image(systemName: profile.precisionLevel == precision ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(profile.precisionLevel == precision ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(precisionDisplayName(precision))
                                                .font(.custom("Nunito", size: 15))
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                            
                                            Text(precisionDescription(precision))
                                                .font(.custom("Nunito", size: 12))
                                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Text(precisionEmoji(precision))
                                            .font(.system(size: 16))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(profile.precisionLevel == precision ? Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(profile.precisionLevel == precision ? Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3) : Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    
                    // No-Contact Date Management
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Start Date")
                            .font(.custom("Nunito", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Button(action: { showingDatePicker = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("No-Contact Start Date")
                                        .font(.custom("Nunito", size: 14))
                                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                                    
                                    Text(formatDate(profile.noContactStartDate))
                                        .font(.custom("Nunito", size: 16))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "calendar")
                                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.7))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    // Duration Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration Summary")
                            .font(.custom("Nunito", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        
                        HStack(spacing: 20) {
                            durationStat(value: "\(profile.daysSinceNoContact)", label: "Days")
                            durationStat(value: "\(profile.weeksSinceNoContact)", label: "Weeks")
                            durationStat(value: "\(profile.monthsSinceNoContact)", label: "Months")
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(
                selectedDate: Binding(
                    get: { profile?.noContactStartDate ?? Date() },
                    set: { newDate in
                        profile?.noContactStartDate = newDate
                        try? modelContext.save()
                    }
                ),
                precisionLevel: profile?.precisionLevel ?? "day"
            )
        }
    }
    
    private func durationStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Nunito", size: 18))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                .monospacedDigit()
            
            Text(label)
                .font(.custom("Nunito", size: 10))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func precisionDisplayName(_ precision: String) -> String {
        switch precision {
        case "day": return "Day Precision"
        case "hour": return "Hour Precision"
        case "minute": return "Minute Precision"
        default: return precision.capitalized
        }
    }
    
    private func precisionDescription(_ precision: String) -> String {
        switch precision {
        case "day": return "Track by day for a simpler view"
        case "hour": return "Hour precision for more detailed tracking"
        case "minute": return "Exact minute tracking with live updates"
        default: return ""
        }
    }
    
    private func precisionEmoji(_ precision: String) -> String {
        switch precision {
        case "day": return "📅"
        case "hour": return "🕐"
        case "minute": return "⏱️"
        default: return "📊"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if profile?.precisionLevel != "day" {
            formatter.timeStyle = .short
        }
        return formatter.string(from: date)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 