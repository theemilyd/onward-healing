import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var currentSession: Session?
    @Published var exerciseResponses: [String: String] = [:]
    @Published var reflectionResponses: [String: String] = [:]
    @Published var selectedMood: Int? = nil
    @Published var isSessionInProgress = false
    
    private let programManager = ProgramManager.shared
    
    private init() {}
    
    func startSession(_ session: Session) {
        currentSession = session
        exerciseResponses = [:]
        reflectionResponses = [:]
        selectedMood = nil
        isSessionInProgress = true
        
        // Start session in program manager
        programManager.startSession(session)
    }
    
    func updateExerciseResponse(exerciseId: String, response: String) {
        exerciseResponses[exerciseId] = response
        programManager.updateExerciseResponse(exerciseId: exerciseId, response: response)
    }
    
    func updateReflectionResponse(reflectionId: String, response: String) {
        reflectionResponses[reflectionId] = response
        programManager.updateReflectionResponse(reflectionId: reflectionId, response: response)
    }
    
    func setMood(_ mood: Int) {
        selectedMood = mood
        programManager.setMood(mood)
    }
    
    func completeSession() {
        programManager.completeSession()
        
        // Clear session state
        currentSession = nil
        exerciseResponses = [:]
        reflectionResponses = [:]
        selectedMood = nil
        isSessionInProgress = false
    }
    
    func getExerciseResponse(for exerciseId: String) -> String {
        return exerciseResponses[exerciseId] ?? ""
    }
    
    func getReflectionResponse(for reflectionId: String) -> String {
        return reflectionResponses[reflectionId] ?? ""
    }
    
    var isSessionComplete: Bool {
        guard let session = currentSession else { return false }
        
        // Check if all exercises have responses
        let exercisesComplete = session.practiceContent.exercises.allSatisfy { exercise in
            !getExerciseResponse(for: exercise.id).isEmpty
        }
        
        // Check if all reflections have responses
        let reflectionsComplete = session.practiceContent.reflections.allSatisfy { reflection in
            !getReflectionResponse(for: reflection.id).isEmpty
        }
        
        // Check if mood is selected
        let moodSelected = selectedMood != nil
        
        return exercisesComplete && reflectionsComplete && moodSelected
    }
} 