import Foundation

// MARK: - Program Models

struct Program: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let duration: String
    let totalDays: Int
    let status: ProgramStatus
    let icon: String
    let category: ProgramCategory
    let sessions: [Session]
    var isSpecialized: Bool = false
    
    var progress: Double {
        let completedCount = sessions.filter { $0.isCompleted }.count
        return totalDays > 0 ? Double(completedCount) / Double(totalDays) : 0
    }
    
    var progressPercentage: Double {
        let completedSessions = sessions.filter { $0.isCompleted }.count
        return Double(completedSessions) / Double(sessions.count)
    }
    
    var statusText: String {
        switch status {
        case .inProgress:
            return "In Progress"
        case .available:
            return "Available"
        case .premium:
            return "Premium"
        case .locked:
            return "Locked"
        case .completed:
            return "Completed"
        }
    }
    
    var buttonText: String {
        switch status {
        case .inProgress:
            return "Continue Program"
        case .available:
            return "Start Program"
        case .premium:
            return "Learn More"
        case .locked:
            return "Unlock"
        case .completed:
            return "Review"
        }
    }
}

enum ProgramStatus: String, Codable, CaseIterable {
    case inProgress = "in_progress"
    case available = "available"
    case premium = "premium"
    case locked = "locked"
    case completed = "completed"
}

enum ProgramCategory: String, Codable, CaseIterable {
    case guided = "guided"
    case specialized = "specialized"
}

// MARK: - Session Models

struct Session: Identifiable, Codable {
    let id: String
    let programId: String
    let dayNumber: Int
    let title: String
    let subtitle: String
    let learningContent: LearningContent
    let practiceContent: PracticeContent
    let isCompleted: Bool
    let completedAt: Date?
    
    var progressText: String {
        return "Day \(dayNumber)"
    }
}

struct LearningContent: Codable {
    let focusTitle: String
    let focusDescription: String
    let sections: [LearningSection]
    let examples: [Example]
}

struct LearningSection: Identifiable, Codable {
    let id: String
    let title: String
    let content: [String]
}

struct Example: Identifiable, Codable {
    let id: String
    let type: ExampleType
    let title: String
    let content: String
    let icon: String
    let color: ExampleColor
}

enum ExampleType: String, Codable {
    case innerCritic = "inner_critic"
    case innerFriend = "inner_friend"
    case positive = "positive"
    case negative = "negative"
}

enum ExampleColor: String, Codable {
    case orange = "orange"
    case green = "green"
    case purple = "purple"
    case blue = "blue"
}

// MARK: - Practice Models

struct PracticeContent: Codable {
    let exercises: [Exercise]
    let reflections: [Reflection]
}

struct Exercise: Identifiable, Codable {
    let id: String
    let title: String
    let placeholder: String
    let type: ExerciseType
    var response: String
    var isCompleted: Bool
    
    mutating func complete(with response: String) {
        self.response = response
        self.isCompleted = !response.isEmpty
    }
}

enum ExerciseType: String, Codable {
    case writing = "writing"
    case comparison = "comparison"
    case reflection = "reflection"
}

struct Reflection: Identifiable, Codable {
    let id: String
    let question: String
    let placeholder: String
    var response: String
    
    mutating func updateResponse(_ response: String) {
        self.response = response
    }
}

// MARK: - Session Progress

struct SessionProgress: Codable {
    let sessionId: String
    let programId: String
    let startedAt: Date
    var completedAt: Date?
    var exercises: [String: String] // exerciseId: response
    var reflections: [String: String] // reflectionId: response
    var selectedMood: Int?
    var isCompleted: Bool
    
    mutating func updateExercise(id: String, response: String) {
        exercises[id] = response
    }
    
    mutating func updateReflection(id: String, response: String) {
        reflections[id] = response
    }
    
    mutating func setMood(_ mood: Int) {
        selectedMood = mood
    }
    
    mutating func complete() {
        isCompleted = true
        completedAt = Date()
    }
}

// MARK: - Journal Entry from Session

struct SessionJournalEntry: Identifiable, Codable {
    let id: String
    let sessionId: String
    let programTitle: String
    let sessionTitle: String
    let date: Date
    let exercises: [ExerciseResponse]
    let reflections: [ReflectionResponse]
    let mood: Int?
    
    var title: String {
        return "\(programTitle): \(sessionTitle)"
    }
    
    var summary: String {
        let exerciseCount = exercises.count
        let reflectionCount = reflections.count
        return "\(exerciseCount) exercises, \(reflectionCount) reflections"
    }
}

struct ExerciseResponse: Identifiable, Codable {
    let id: String
    let title: String
    let response: String
}

struct ReflectionResponse: Identifiable, Codable {
    let id: String
    let question: String
    let response: String
} 