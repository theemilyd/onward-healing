import SwiftUI

struct PlantSeedView: View {
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("Plant Your Seed")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This seed represents your new beginning. Nurture it, and watch it grow as you heal.")
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Placeholder for seed planting animation/image
            Image(systemName: "leaf.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Spacer()
            
            Button("Begin Your Journey") {
                onComplete()
            }
            .buttonStyle(PillButtonStyle())
        }
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
    }
}


struct PlantSeedView_Previews: PreviewProvider {
    static var previews: some View {
        PlantSeedView(onComplete: {})
    }
} 