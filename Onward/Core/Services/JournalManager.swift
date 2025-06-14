import Foundation
import SwiftData

class JournalManager: ObservableObject {
    static let shared = JournalManager()
    
    private init() {}
    
    // MARK: - Session Entry Integration
    
    func addSessionEntry(_ sessionEntry: SessionJournalEntry) {
        // Convert SessionJournalEntry to regular JournalEntry for the existing system
        let content = formatSessionContent(sessionEntry)
        
        // Create a new JournalEntry using the existing model
        let journalEntry = JournalEntry(
            dateCreated: sessionEntry.date,
            contentText: content
        )
        
        // In a real app, you would save this to the SwiftData context
        // For now, we'll use a notification to inform the UI
        NotificationCenter.default.post(
            name: .sessionEntryAdded,
            object: journalEntry
        )
    }
    
    private func formatSessionContent(_ sessionEntry: SessionJournalEntry) -> String {
        var content = "📚 \(sessionEntry.title)\n\n"
        
        // Add exercises
        if !sessionEntry.exercises.isEmpty {
            content += "✍️ Practice Exercises:\n\n"
            for exercise in sessionEntry.exercises {
                content += "• \(exercise.title)\n"
                content += "\(exercise.response)\n\n"
            }
        }
        
        // Add reflections
        if !sessionEntry.reflections.isEmpty {
            content += "🤔 Reflections:\n\n"
            for reflection in sessionEntry.reflections {
                content += "• \(reflection.question)\n"
                content += "\(reflection.response)\n\n"
            }
        }
        
        // Add mood if available
        if let mood = sessionEntry.mood {
            let moodEmoji = moodToEmoji(mood)
            content += "😊 Mood: \(moodEmoji)\n"
        }
        
        return content
    }
    
    private func moodToEmoji(_ mood: Int) -> String {
        switch mood {
        case 1: return "😢 Very Sad"
        case 2: return "😔 Sad"
        case 3: return "😐 Neutral"
        case 4: return "🙂 Happy"
        case 5: return "😊 Very Happy"
        default: return "😐 Neutral"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let sessionEntryAdded = Notification.Name("sessionEntryAdded")
} 