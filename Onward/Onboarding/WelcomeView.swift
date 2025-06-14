import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.primaryLavender.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Placeholder for Logo
                Text("No Contact Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your compassionate companion for navigating the no contact period.")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("Get Started") {
                    onContinue()
                }
                .buttonStyle(PillButtonStyle())
                
                Spacer().frame(height: 50)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(onContinue: {})
    }
} 