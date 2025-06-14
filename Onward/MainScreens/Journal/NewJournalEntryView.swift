import SwiftUI
import SwiftData
import AVFoundation
import PhotosUI

struct NewJournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @StateObject private var programManager = ProgramManager.shared
    
    @State private var contentText: String = ""
    @State private var selectedMood: String? = nil
    
    // Camera and Photo functionality
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    
    // Voice recording functionality
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var recordingURL: URL?
    @State private var showingVoiceAlert = false
    
    private var wordCount: Int {
        contentText.isEmpty ? 0 : contentText.split(separator: " ").count
    }
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Date
                    DateView()
                    
                    // Today's Gentle Prompt
                    PromptCard()
                    
                    // Mood Selection
                    MoodSection()
                    
                    // Selected Image Display
                    if let selectedImage = selectedImage {
                        ImageDisplaySection(image: selectedImage) {
                            self.selectedImage = nil
                        }
                    }
                    
                    // Main Text Area
                    TextAreaSection()
                    
                    // Bottom Reminder
                    ReminderSection()
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Bottom Action Area
            BottomActionView()
        }
        .background(Color(red: 250/255, green: 247/255, blue: 245/255))
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .alert("Voice Recording", isPresented: $showingVoiceAlert) {
            Button("OK") { }
        } message: {
            Text(isRecording ? "Recording started! Tap the mic again to stop." : "Recording saved! Your voice note has been added to your entry.")
        }
        .onAppear {
            setupAudioSession()
        }
    }
    
    private func saveEntry() {
        guard !contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Create the journal entry content with mood if selected
        var entryContent = contentText
        if let mood = selectedMood {
            entryContent = "Mood: \(mood)\n\n\(contentText)"
        }
        
        // Convert image to data if present
        var imageData: Data? = nil
        if let image = selectedImage {
            imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        // Get audio URL string if present
        var audioURLString: String? = nil
        if let url = recordingURL {
            audioURLString = url.path
        }
        
        let newEntry = JournalEntry(
            contentText: entryContent,
            imageData: imageData,
            audioURL: audioURLString,
            profile: profile
        )
        modelContext.insert(newEntry)
        
        // Save the context
        do {
            try modelContext.save()
            
            // Track journal entry for paywall triggers
            PaywallTrigger.shared.incrementJournalCount()
        } catch {
            print("Failed to save journal entry: \(error)")
        }
        
        dismiss()
    }
    
    // MARK: - Audio Recording Setup
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingURL = audioFilename
            showingVoiceAlert = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        showingVoiceAlert = true
    }
}

// MARK: - Subviews

private extension NewJournalEntryView {
    
    func HeaderView() -> some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Cancel")
                        .font(.custom("Nunito", size: 16))
                        .fontWeight(.medium)
                }
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil.and.scribble")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    
                    Text("New Entry")
                        .font(.custom("Nunito", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                }
                
                Text("Express yourself freely")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
            }
            
            Spacer()
            
            Button("Save") {
                saveEntry()
            }
            .font(.custom("Nunito", size: 16))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.3),
                                Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 195/255, green: 177/255, blue: 225/255),
                                Color(red: 175/255, green: 157/255, blue: 205/255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                        Color.clear : 
                        Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            )
            .disabled(contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .scaleEffect(contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: contentText.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 44)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 252/255, green: 249/255, blue: 247/255),
                    Color(red: 250/255, green: 247/255, blue: 245/255).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
    }
    
    func DateView() -> some View {
        HStack {
            Text(getCurrentDateString())
                .font(.custom("Nunito", size: 16))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
            Spacer()
        }
    }
    
    func PromptCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text("Today's Gentle Prompt")
                    .font(.custom("Nunito", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
                
                Image(systemName: "quote.opening")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.5))
            }
            
            Text(programManager.getTodaysPrompt())
                .font(.custom("Nunito", size: 15))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.85))
                .lineSpacing(6)
                .italic()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.12),
                            Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.06)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3),
                                    Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
    
    func MoodSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text("How are you feeling?")
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MoodButton(
                        title: "Peaceful",
                        iconName: "leaf.fill",
                        isSelected: selectedMood == "Peaceful",
                        action: { selectedMood = "Peaceful" }
                    )
                    
                    MoodButton(
                        title: "Grateful",
                        iconName: "heart.fill",
                        isSelected: selectedMood == "Grateful",
                        action: { selectedMood = "Grateful" }
                    )
                }
                
                HStack(spacing: 12) {
                    MoodButton(
                        title: "Reflective",
                        iconName: "moon.fill",
                        isSelected: selectedMood == "Reflective",
                        action: { selectedMood = "Reflective" }
                    )
                    
                    MoodButton(
                        title: "Hopeful",
                        iconName: "star.fill",
                        isSelected: selectedMood == "Hopeful",
                        action: { selectedMood = "Hopeful" }
                    )
                }
                
                HStack(spacing: 12) {
                    MoodButton(
                        title: "Overwhelmed",
                        iconName: "cloud.fill",
                        isSelected: selectedMood == "Overwhelmed",
                        action: { selectedMood = "Overwhelmed" }
                    )
                    
                    MoodButton(
                        title: "Tender",
                        iconName: "face.smiling.inverse",
                        isSelected: selectedMood == "Tender",
                        action: { selectedMood = "Tender" }
                    )
                }
            }
        }
    }
    
    func TextAreaSection() -> some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topLeading) {
                if contentText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.text.square")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.6))
                            
                            Text("Pour your heart onto these pages...")
                                .font(.custom("Nunito", size: 17))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                        }
                        
                        Text("There's no right or wrong way to express what you're feeling. This is your safe space to be completely authentic.")
                            .font(.custom("Nunito", size: 15))
                            .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.5))
                            .lineSpacing(6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .allowsHitTesting(false)
                }
                
                TextEditor(text: $contentText)
                    .font(.custom("Nunito", size: 16))
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.clear)
                    .frame(minHeight: 320)
                    .scrollContentBackground(.hidden)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 220/255, green: 220/255, blue: 225/255).opacity(0.8),
                                        Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "textformat")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    
                    Text("\(wordCount) words")
                        .font(.custom("Nunito", size: 13))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                }
                
                Spacer()
                
                if wordCount > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                        
                        Text("Ready to save")
                            .font(.custom("Nunito", size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: wordCount > 0)
        }
    }
    
    func ReminderSection() -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                .padding(.top, 2)
            
            Text("Remember: This is your sacred space. Write freely, without judgment. Your thoughts and feelings are valid exactly as they are.")
                .font(.custom("Nunito", size: 14))
                .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                .lineSpacing(4)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    func BottomActionView() -> some View {
        HStack(spacing: 24) {
            Spacer()
            
            // Voice Recording Button
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(
                                    isRecording ? 
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 195/255, green: 177/255, blue: 225/255),
                                            Color(red: 175/255, green: 157/255, blue: 205/255)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: isRecording ? Color.red.opacity(0.3) : Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                        )
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                    
                    Text(isRecording ? "Recording..." : "Voice Note")
                        .font(.custom("Nunito", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                }
            }
            
            // Camera Options Button
            Menu {
                Button(action: { showingCamera = true }) {
                    Label("Take Photo", systemImage: "camera")
                }
                Button(action: { showingImagePicker = true }) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 195/255, green: 177/255, blue: 225/255),
                                            Color(red: 175/255, green: 157/255, blue: 205/255)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.3),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                        )
                    
                    Text("Add Photo")
                        .font(.custom("Nunito", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
        .padding(.top, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 250/255, green: 247/255, blue: 245/255).opacity(0.95),
                    Color(red: 252/255, green: 249/255, blue: 247/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: -1)
        )
    }
    
    func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return "Today, \(formatter.string(from: Date()))"
    }
    
    // MARK: - Image Display Section
    
    func ImageDisplaySection(image: UIImage, onRemove: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "photo.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 195/255, green: 177/255, blue: 225/255))
                
                Text("Attached Photo")
                    .font(.custom("Nunito", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6))
                }
            }
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 220/255, green: 220/255, blue: 225/255), lineWidth: 1)
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Mood Button

private struct MoodButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(
                        isSelected ?
                        Color(red: 195/255, green: 177/255, blue: 225/255) :
                        Color(red: 139/255, green: 134/255, blue: 128/255).opacity(0.6)
                    )
                
                Text(title)
                    .font(.custom("Nunito", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 139/255, green: 134/255, blue: 128/255))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(
                        isSelected ?
                        Color(red: 195/255, green: 177/255, blue: 225/255).opacity(0.15) :
                        Color.white.opacity(0.7)
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                Color(red: 220/255, green: 220/255, blue: 225/255).opacity(0.5),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

struct NewJournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewJournalEntryView()
            .modelContainer(for: [JournalEntry.self], inMemory: true)
    }
} 