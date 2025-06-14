import Foundation
import SwiftData
import UIKit

@Model
final class JournalEntry {
    var id: UUID
    var dateCreated: Date
    var contentText: String
    var imageData: Data?
    var audioURL: String?
    
    // Although not strictly needed for MVP, this relationship is good practice.
    // It can be nil if we ever want entries not tied to a profile.
    var profile: UserProfile?

    init(
        id: UUID = UUID(),
        dateCreated: Date = .now,
        contentText: String,
        imageData: Data? = nil,
        audioURL: String? = nil,
        profile: UserProfile? = nil
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.contentText = contentText
        self.imageData = imageData
        self.audioURL = audioURL
        self.profile = profile
    }
}

extension JournalEntry {
    static var dummyData: [JournalEntry] = [
        JournalEntry(dateCreated: Date(), contentText: "I managed to take a proper lunch break today and actually enjoyed my meal without rushing. It felt like such a simple but meaningful act of self-care...", profile: nil),
        JournalEntry(dateCreated: Date().addingTimeInterval(-86400), contentText: "Reflecting on the conversation with my friend today. It felt good to be heard and understood without judgment.", profile: nil),
        JournalEntry(dateCreated: Date().addingTimeInterval(-172800), contentText: "Had a breakthrough moment during meditation today. I finally felt that sense of inner quiet I've been searching for.", profile: nil),
        // Test entry with image data
        JournalEntry(
            dateCreated: Date().addingTimeInterval(-259200), 
            contentText: "Mood: Peaceful\n\nToday I took a beautiful photo during my walk. The sunset was absolutely stunning and reminded me of the beauty that still exists in the world.", 
            imageData: createTestImageData(),
            profile: nil
        )
    ]
    
    private static func createTestImageData() -> Data? {
        // Create a simple test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.systemBlue.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillEllipse(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image?.jpegData(compressionQuality: 0.8)
    }
} 