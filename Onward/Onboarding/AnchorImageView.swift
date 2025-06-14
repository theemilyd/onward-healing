import SwiftUI
import PhotosUI

struct AnchorImageView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var onContinue: (Data?) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose an Anchor Image")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This image should represent peace and strength for you.")
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 200, height: 200)
                        .shadow(radius: 5)
                    
                    if let selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 60, weight: .thin))
                            .foregroundColor(.primaryLavender)
                    }
                }
            }
            
            Spacer()
            
            Button("Continue") {
                onContinue(selectedImageData)
            }
            .buttonStyle(PillButtonStyle())
        }
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
}

struct AnchorImageView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorImageView(onContinue: { _ in })
    }
} 