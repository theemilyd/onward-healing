import SwiftUI

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(Color.primaryLavender)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
    }
}

// For previewing
struct PillButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Get Started") {
            print("Button tapped!")
        }
        .buttonStyle(PillButtonStyle())
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 