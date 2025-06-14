import SwiftUI

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let precisionLevel: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Update No-Contact Start Date")
                        .font(.custom("Nunito", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    
                    Text("Choose when you started your no-contact journey")
                        .font(.custom("Nunito", size: 16))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Date Picker
                DatePicker(
                    "No-Contact Start Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: precisionLevel == "day" ? [.date] : [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Precision info
                HStack {
                    Image(systemName: precisionEmoji())
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    
                    Text("Using \(precisionLevel) precision")
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    Button("Update") {
                        dismiss()
                    }
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(red: 250/255, green: 247/255, blue: 245/255))
            .navigationBarHidden(true)
        }
    }
    
    private func precisionEmoji() -> String {
        switch precisionLevel {
        case "day": return "calendar"
        case "hour": return "clock"
        case "minute": return "timer"
        default: return "calendar"
        }
    }
} 