import SwiftUI

struct WhyView: View {
    @State private var whyStatement: String = ""
    var onContinue: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What is your 'why'?")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Write down your reasons for starting this journey. This will be your anchor.")
                .foregroundColor(.textSecondary)
            
            TextEditor(text: $whyStatement)
                .frame(height: 200)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.primaryLavender.opacity(0.5), lineWidth: 1)
                )
            
            Spacer()
            
            Button("Continue") {
                onContinue(whyStatement)
            }
            .buttonStyle(PillButtonStyle())
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct WhyView_Previews: PreviewProvider {
    static var previews: some View {
        WhyView(onContinue: { _ in })
    }
} 