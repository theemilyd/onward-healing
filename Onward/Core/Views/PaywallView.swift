import SwiftUI

struct PaywallView: View {
    let context: PaywallContext?
    let onDismiss: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedOption: SubscriptionOption = .weekly
    @State private var freeTrialEnabled = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(context: PaywallContext? = nil, onDismiss: (() -> Void)? = nil) {
        self.context = context
        self.onDismiss = onDismiss
    }
    
    enum SubscriptionOption {
        case weekly, yearly
    }
    
    var body: some View {
        ZStack {
            // Cream background
            Color(red: 250/255, green: 247/255, blue: 245/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Title Section
                    titleSection
                    
                    // What You'll Unlock Section
                    featuresSection
                    
                    // Subscription Options
                    subscriptionOptionsSection
                    
                    Spacer(minLength: 120) // Space for bottom CTA
                }
                .padding(.horizontal, 24)
            }
            
            // Bottom CTA
            bottomCTASection
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: { 
                onDismiss?()
                dismiss() 
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.8)))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 184/255, green: 197/255, blue: 184/255))
                Text("Onward")
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            }
            
            Spacer()
            
            Button(action: { 
                onDismiss?()
                dismiss() 
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.8)))
            }
        }
        .padding(.top, 48)
        .padding(.bottom, 24)
    }
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            // Crown icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2),
                                Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
            }
            
            VStack(spacing: 12) {
                Text(context?.title ?? "Unlock Your Complete Healing Journey")
                    .font(.custom("Nunito", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(context?.subtitle ?? "Experience the full power of Onward Premium")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Free Trial Toggle - only enabled for weekly
            HStack(spacing: 12) {
                Text("Free Trial")
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(selectedOption == .weekly ? 1.0 : 0.4))
                
                Button(action: { 
                    if selectedOption == .weekly {
                        freeTrialEnabled.toggle()
                    }
                }) {
                    ZStack {
                        Capsule()
                            .fill((selectedOption == .weekly && freeTrialEnabled) ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3))
                            .frame(width: 48, height: 24)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .offset(x: (selectedOption == .weekly && freeTrialEnabled) ? 12 : -12)
                            .animation(.easeInOut(duration: 0.2), value: selectedOption == .weekly && freeTrialEnabled)
                    }
                }
                .disabled(selectedOption != .weekly)
                .opacity(selectedOption == .weekly ? 1.0 : 0.4)
                
                Text("Enabled")
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor((selectedOption == .weekly && freeTrialEnabled) ? Color(red: 195/255, green: 177/255, blue: 225/255) : Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
            }
        }
        .padding(.bottom, 32)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What You'll Unlock")
                .font(.custom("Nunito", size: 18))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
            
            // Side-by-side feature comparison
            HStack(alignment: .top, spacing: 16) {
                // Always Free Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 184/255, green: 197/255, blue: 184/255))
                        Text("Always Free")
                            .font(.custom("Nunito", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                    
                    VStack(spacing: 10) {
                        CompactFeatureRow(
                            icon: "checkmark",
                            iconColor: Color(red: 184/255, green: 197/255, blue: 184/255),
                            title: "Dashboard Access"
                        )
                        
                        CompactFeatureRow(
                            icon: "checkmark",
                            iconColor: Color(red: 184/255, green: 197/255, blue: 184/255),
                            title: "30-Day Program"
                        )
                        
                        CompactFeatureRow(
                            icon: "checkmark",
                            iconColor: Color(red: 184/255, green: 197/255, blue: 184/255),
                            title: "AI Chat Support"
                        )
                        
                        CompactFeatureRow(
                            icon: "minus",
                            iconColor: Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.4),
                            title: "3 Journal Entries/Week",
                            isLimited: true
                        )
                    }
                    .padding(.leading, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Premium Features Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        Text("Premium Features")
                            .font(.custom("Nunito", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    }
                    
                    VStack(spacing: 10) {
                        CompactFeatureRow(
                            icon: "plus",
                            iconColor: Color(red: 195/255, green: 177/255, blue: 225/255),
                            title: "Unlimited Journaling"
                        )
                        
                        CompactFeatureRow(
                            icon: "plus",
                            iconColor: Color(red: 195/255, green: 177/255, blue: 225/255),
                            title: "All Healing Programs"
                        )
                        
                        CompactFeatureRow(
                            icon: "plus",
                            iconColor: Color(red: 195/255, green: 177/255, blue: 225/255),
                            title: "Complete Insights"
                        )
                        
                        CompactFeatureRow(
                            icon: "plus",
                            iconColor: Color(red: 195/255, green: 177/255, blue: 225/255),
                            title: "Data Export"
                        )
                    }
                    .padding(.leading, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.bottom, 24)
    }
    
    private var subscriptionOptionsSection: some View {
        HStack(spacing: 12) {
            // Weekly Option (Left)
            Button(action: { selectedOption = .weekly }) {
                VStack(spacing: 12) {
                    // Badge
                    Text("3 Days Free")
                        .font(.custom("Nunito", size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
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
                        .clipShape(Capsule())
                    
                    VStack(spacing: 8) {
                        Text("Weekly Access")
                            .font(.custom("Nunito", size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Text("Flexible commitment")
                            .font(.custom("Nunito", size: 10))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("$6.99")
                                .font(.custom("Nunito", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            Text("per week")
                                .font(.custom("Nunito", size: 10))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.9))
                        }
                        Text("After 3-day free trial")
                            .font(.custom("Nunito", size: 9))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    ZStack {
                        Circle()
                            .stroke(
                                selectedOption == .weekly ? 
                                Color(red: 195/255, green: 177/255, blue: 225/255) : 
                                Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 20, height: 20)
                        
                        if selectedOption == .weekly {
                            Circle()
                                .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            selectedOption == .weekly ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.15),
                                    Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1),
                                    Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedOption == .weekly ? 
                                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3) : 
                                    Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2),
                                    lineWidth: selectedOption == .weekly ? 2 : 1
                                )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Yearly Option (Right)
            Button(action: { selectedOption = .yearly }) {
                VStack(spacing: 12) {
                    // Badge
                    Text("Best Value")
                        .font(.custom("Nunito", size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
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
                        .clipShape(Capsule())
                    
                    VStack(spacing: 8) {
                        Text("Yearly Access")
                            .font(.custom("Nunito", size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                        
                        Text("Complete healing journey")
                            .font(.custom("Nunito", size: 10))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("$49.99")
                                .font(.custom("Nunito", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                            Text("per year")
                                .font(.custom("Nunito", size: 10))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.9))
                        }
                        Text("Only $0.96 per week")
                            .font(.custom("Nunito", size: 9))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    ZStack {
                        Circle()
                            .stroke(
                                selectedOption == .yearly ? 
                                Color(red: 195/255, green: 177/255, blue: 225/255) : 
                                Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 20, height: 20)
                        
                        if selectedOption == .yearly {
                            Circle()
                                .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            selectedOption == .yearly ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.15),
                                    Color(red: 184/255, green: 197/255, blue: 184/255).opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.1),
                                    Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedOption == .yearly ? 
                                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3) : 
                                    Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2),
                                    lineWidth: selectedOption == .yearly ? 2 : 1
                                )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.bottom, 24)
    }
    
    private var bottomCTASection: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await handlePurchase()
                    }
                }) {
                    HStack {
                        if subscriptionManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(subscriptionManager.isLoading ? "Processing..." : "Continue")
                            .font(.custom("Nunito", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
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
                    .clipShape(Capsule())
                    .disabled(subscriptionManager.isLoading)
                }
                
                Text("No payment now • Cancel anytime")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                
                HStack(spacing: 16) {
                    Button("Terms of Service") {
                        // Handle terms
                    }
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    
                    Text("•")
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    
                    Button("Privacy Policy") {
                        // Handle privacy
                    }
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    
                    Text("•")
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                    
                    Button("Restore") {
                        Task {
                            await handleRestore()
                        }
                    }
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(
                Color(red: 250/255, green: 247/255, blue: 245/255).opacity(0.95)
                    .background(.ultraThinMaterial)
            )
        }
        .alert("Subscription", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Purchase Handling
    
    private func handlePurchase() async {
        let success: Bool
        
        switch selectedOption {
        case .weekly:
            success = await subscriptionManager.purchaseWeeklySubscription()
        case .yearly:
            success = await subscriptionManager.purchaseYearlySubscription()
        }
        
        if success {
            // Purchase successful, dismiss paywall
            dismiss()
        } else {
            // Show error message
            alertMessage = "Purchase failed. Please try again."
            showingAlert = true
        }
    }
    
    private func handleRestore() async {
        let success = await subscriptionManager.restorePurchases()
        
        if success && subscriptionManager.hasActiveSubscription {
            alertMessage = "Purchases restored successfully!"
            showingAlert = true
            
            // Dismiss after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            alertMessage = "No previous purchases found."
            showingAlert = true
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var isLimited: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 16, height: 16)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Nunito", size: 14))
                    .foregroundColor(isLimited ? Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7) : Color(red: 139/255, green: 134/255, blue: 128/255))
                Text(subtitle)
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

struct CompactFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var isLimited: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.custom("Nunito", size: 12))
                .foregroundColor(isLimited ? Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7) : Color(red: 139/255, green: 134/255, blue: 128/255))
                .lineLimit(1)
            
            Spacer()
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
} 