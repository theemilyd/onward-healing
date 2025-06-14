import Foundation
import Combine

enum DayState {
    case today, completed, unlocked, locked
}

class ProgramManager: ObservableObject {
    static let shared = ProgramManager()
    
    @Published var programs: [Program] = []
    @Published var isLoading = false
    
    private let programsKey = "savedPrograms"
    private let progressKey = "currentSessionProgress"
    private let userDefaults = UserDefaults.standard
    
    @Published var currentSessionProgress: SessionProgress?
    
    var currentDay: Int {
        guard let currentProgram = getCurrentProgram() else { return 1 }
        
        if let firstIncomplete = currentProgram.sessions.first(where: { !$0.isCompleted }) {
            return firstIncomplete.dayNumber
        }
        
        // If all sessions are done, the program is complete.
        // The "current day" can be considered the last day.
        return currentProgram.totalDays
    }
    
    private init() {
        loadPrograms()
        loadCurrentProgress()
    }
    
    // MARK: - Program Management
    
    func loadPrograms() {
        isLoading = true
        
        // For now, load from sample data. In production, this would be from API
        if let savedData = userDefaults.data(forKey: programsKey),
           let savedPrograms = try? JSONDecoder().decode([Program].self, from: savedData) {
            self.programs = savedPrograms
        } else {
            // Load sample data on first launch
            self.programs = createSamplePrograms()
            savePrograms()
        }
        
        isLoading = false
    }
    
    private func savePrograms() {
        if let encoded = try? JSONEncoder().encode(programs) {
            userDefaults.set(encoded, forKey: programsKey)
        }
    }
    
    func getProgram(by id: String) -> Program? {
        return programs.first { $0.id == id }
    }
    
    func getGuidedPrograms() -> [Program] {
        return programs.filter { $0.category == .guided }
    }
    
    func getSpecializedPrograms() -> [Program] {
        return programs.filter { $0.category == .specialized }
    }
    
    func getCurrentProgram() -> Program? {
        return programs.first { $0.status == .inProgress }
    }
    
    func getTodaysSession() -> Session? {
        guard let currentProgram = getCurrentProgram() else { return nil }
        return currentProgram.sessions.first { !$0.isCompleted }
    }
    
    func getTodaysSession(for program: Program) -> Session? {
        return program.sessions.first { !$0.isCompleted }
    }
    
    func getSession(for day: Int) -> Session? {
        guard let currentProgram = getCurrentProgram() else {
            // If no program started, return Day 1 session from 30-day program
            let freshStartProgram = programs.first { $0.id == "30-day-fresh-start" }
            return freshStartProgram?.sessions.first { $0.dayNumber == day }
        }
        return currentProgram.sessions.first { $0.dayNumber == day }
    }
    
    func getNextSession(for programId: String) -> Session? {
        guard let program = getProgram(by: programId) else { return nil }
        return program.sessions.first { !$0.isCompleted }
    }
    
    func startProgram(_ programId: String) {
        // Set this program as the current program
        UserDefaults.standard.set(programId, forKey: "currentProgramId")
        
        // Set the start date for daily progression
        UserDefaults.standard.set(Date(), forKey: "programStartDate")
        
        // Update program status to in progress
        if let index = programs.firstIndex(where: { $0.id == programId }) {
            programs[index] = Program(
                id: programs[index].id,
                title: programs[index].title,
                subtitle: programs[index].subtitle,
                description: programs[index].description,
                duration: programs[index].duration,
                totalDays: programs[index].totalDays,
                status: .inProgress,
                icon: programs[index].icon,
                category: programs[index].category,
                sessions: programs[index].sessions,
                isSpecialized: programs[index].isSpecialized
            )
        }
    }
    
    // MARK: - Daily Progression
    
    func checkForNewDay() {
        guard let startDate = UserDefaults.standard.object(forKey: "programStartDate") as? Date else { return }
        
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        
        // If it's been at least one day since the last session was completed,
        // and there are incomplete sessions, make the next session available
        if daysSinceStart > 0 {
            unlockNextSessionIfNeeded()
        }
    }
    
    private func unlockNextSessionIfNeeded() {
        // This could be used to implement daily unlocking of sessions
        // For now, all sessions are available from the start
    }
    
    func getDaysSinceStart() -> Int {
        guard let startDate = UserDefaults.standard.object(forKey: "programStartDate") as? Date else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }
    
    // MARK: - Session Management
    
    func startSession(_ session: Session) {
        currentSessionProgress = SessionProgress(
            sessionId: session.id,
            programId: session.programId,
            startedAt: Date(),
            completedAt: nil,
            exercises: [:],
            reflections: [:],
            selectedMood: nil,
            isCompleted: false
        )
        saveCurrentProgress()
    }
    
    func updateExerciseResponse(exerciseId: String, response: String) {
        currentSessionProgress?.updateExercise(id: exerciseId, response: response)
        saveCurrentProgress()
    }
    
    func updateReflectionResponse(reflectionId: String, response: String) {
        currentSessionProgress?.updateReflection(id: reflectionId, response: response)
        saveCurrentProgress()
    }
    
    func setMood(_ mood: Int) {
        currentSessionProgress?.setMood(mood)
        saveCurrentProgress()
    }
    
    func completeSession() {
        guard var progress = currentSessionProgress else { return }
        
        progress.complete()
        
        // Update program with completed session
        if let programIndex = programs.firstIndex(where: { $0.id == progress.programId }),
           let sessionIndex = programs[programIndex].sessions.firstIndex(where: { $0.id == progress.sessionId }) {
            
            var updatedProgram = programs[programIndex]
            var updatedSessions = updatedProgram.sessions
            var updatedSession = updatedSessions[sessionIndex]
            
            // Mark session as completed
            updatedSession = Session(
                id: updatedSession.id,
                programId: updatedSession.programId,
                dayNumber: updatedSession.dayNumber,
                title: updatedSession.title,
                subtitle: updatedSession.subtitle,
                learningContent: updatedSession.learningContent,
                practiceContent: updatedSession.practiceContent,
                isCompleted: true,
                completedAt: Date()
            )
            
            updatedSessions[sessionIndex] = updatedSession
            updatedProgram = Program(
                id: updatedProgram.id,
                title: updatedProgram.title,
                subtitle: updatedProgram.subtitle,
                description: updatedProgram.description,
                duration: updatedProgram.duration,
                totalDays: updatedProgram.totalDays,
                status: updatedProgram.status,
                icon: updatedProgram.icon,
                category: updatedProgram.category,
                sessions: updatedSessions,
                isSpecialized: updatedProgram.isSpecialized
            )
            
            programs[programIndex] = updatedProgram
            savePrograms()
        }
        
        // Save to journal
        saveSessionToJournal(progress)
        
        // Clear current progress
        currentSessionProgress = nil
        saveCurrentProgress()
    }
    
    private func saveCurrentProgress() {
        if let progress = currentSessionProgress,
           let encoded = try? JSONEncoder().encode(progress) {
            userDefaults.set(encoded, forKey: progressKey)
        } else {
            userDefaults.removeObject(forKey: progressKey)
        }
    }
    
    private func loadCurrentProgress() {
        if let savedData = userDefaults.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode(SessionProgress.self, from: savedData) {
            currentSessionProgress = progress
        }
    }
    
    // MARK: - Journal Integration
    
    private func saveSessionToJournal(_ progress: SessionProgress) {
        guard let program = getProgram(by: progress.programId),
              let session = program.sessions.first(where: { $0.id == progress.sessionId }) else {
            return
        }
        
        let exercises = session.practiceContent.exercises.compactMap { exercise -> ExerciseResponse? in
            guard let response = progress.exercises[exercise.id], !response.isEmpty else { return nil }
            return ExerciseResponse(id: exercise.id, title: exercise.title, response: response)
        }
        
        let reflections = session.practiceContent.reflections.compactMap { reflection -> ReflectionResponse? in
            guard let response = progress.reflections[reflection.id], !response.isEmpty else { return nil }
            return ReflectionResponse(id: reflection.id, question: reflection.question, response: response)
        }
        
        let journalEntry = SessionJournalEntry(
            id: UUID().uuidString,
            sessionId: session.id,
            programTitle: program.title,
            sessionTitle: session.title,
            date: progress.completedAt ?? Date(),
            exercises: exercises,
            reflections: reflections,
            mood: progress.selectedMood
        )
        
        // Save to journal (integrate with existing journal system)
        JournalManager.shared.addSessionEntry(journalEntry)
    }
    
    // MARK: - Sample Data Creation
    
    private func createSamplePrograms() -> [Program] {
        return [
            // 30-Day Fresh Start (In Progress)
            Program(
                id: "30-day-fresh-start",
                title: "30-Day Fresh Start",
                subtitle: "Improve mindset",
                description: "Gentle daily practices to establish healthy routines and immediate coping strategies",
                duration: "2x of 30 days",
                totalDays: 30,
                status: .inProgress,
                icon: "leaf.fill",
                category: .guided,
                sessions: createSampleSessions(for: "30-day-fresh-start", count: 30),
                isSpecialized: false
            ),
            
            // 60-Day Rebuild (Available)
            Program(
                id: "60-day-rebuild",
                title: "60-Day Rebuild",
                subtitle: "",
                description: "Explore deeper healing patterns and rebuild your sense of self with compassion",
                duration: "Unlocks after 30-Day completion",
                totalDays: 60,
                status: .available,
                icon: "arrow.up.right.circle.fill",
                category: .guided,
                sessions: createSampleSessions(for: "60-day-rebuild", count: 60),
                isSpecialized: false
            ),
            
            // 90-Day Transform (Premium)
            Program(
                id: "90-day-transform",
                title: "90-Day Transform",
                subtitle: "Premium Complete",
                description: "Comprehensive personal transformation journey with advanced healing techniques",
                duration: "Includes 1-on-1 coaching sessions",
                totalDays: 90,
                status: .premium,
                icon: "crown.fill",
                category: .guided,
                sessions: createSampleSessions(for: "90-day-transform", count: 90),
                isSpecialized: false
            ),
            
            // Specialized Programs
            Program(
                id: "breakup-recovery",
                title: "Breakup Recovery",
                subtitle: "",
                description: "Healing from romantic relationships",
                duration: "14 days",
                totalDays: 14,
                status: .available,
                icon: "heart.fill",
                category: .specialized,
                sessions: createSampleSessions(for: "breakup-recovery", count: 14),
                isSpecialized: true
            ),
            
            Program(
                id: "family-healing",
                title: "Family Healing",
                subtitle: "",
                description: "Navigating family relationship changes",
                duration: "21 days",
                totalDays: 21,
                status: .available,
                icon: "house.fill",
                category: .specialized,
                sessions: createSampleSessions(for: "family-healing", count: 21),
                isSpecialized: true
            ),
            
            Program(
                id: "divorce-support",
                title: "Divorce Support",
                subtitle: "",
                description: "Support through divorce healing",
                duration: "28 days",
                totalDays: 28,
                status: .available,
                icon: "scale.3d",
                category: .specialized,
                sessions: createSampleSessions(for: "divorce-support", count: 28),
                isSpecialized: true
            ),
            
            Program(
                id: "friendship-closure",
                title: "Friendship Closure",
                subtitle: "",
                description: "Processing friendship endings",
                duration: "10 days",
                totalDays: 10,
                status: .available,
                icon: "person.2.fill",
                category: .specialized,
                sessions: createSampleSessions(for: "friendship-closure", count: 10),
                isSpecialized: true
            )
        ]
    }
    
    private func createSampleSessions(for programId: String, count: Int) -> [Session] {
        var sessions: [Session] = []
        
        for day in 1...count {
            let session = Session(
                id: "\(programId)-day-\(day)",
                programId: programId,
                dayNumber: day,
                title: day == 1 ? "Building Self-Compassion" : "Day \(day) Session",
                subtitle: day == 1 ? "Today's journey toward treating yourself with kindness" : "Continue your healing journey",
                learningContent: createSampleLearningContent(for: day, programId: programId),
                practiceContent: createSamplePracticeContent(for: day, programId: programId),
                isCompleted: false, // Start fresh - no completed sessions
                completedAt: nil
            )
            sessions.append(session)
        }
        
        return sessions
    }
    
    private func createSampleLearningContent(for day: Int, programId: String = "30-day-fresh-start") -> LearningContent {
        return createProgramSpecificContent(for: day, programId: programId)
    }
    
    private func createProgramSpecificContent(for day: Int, programId: String) -> LearningContent {
        switch programId {
        case "30-day-fresh-start":
            return create30DayFreshStartContent(for: day)
        case "60-day-rebuild":
            return create60DayRebuildContent(for: day)
        case "90-day-transform":
            return create90DayTransformContent(for: day)
        case "breakup-recovery":
            return createBreakupRecoveryContent(for: day)
        case "family-healing":
            return createFamilyHealingContent(for: day)
        case "divorce-support":
            return createDivorceSupportContent(for: day)
        case "friendship-closure":
            return createFriendshipClosureContent(for: day)
        default:
            return createDefaultContent(for: day)
        }
    }
    
    private func create30DayFreshStartContent(for day: Int) -> LearningContent {
        switch day {
        case 1:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Learning to speak to yourself with the same kindness you would a good friend. Self-compassion isn't about being perfect—it's about being gentle when you are not.",
                sections: [
                    LearningSection(
                        id: "understanding-\(day)",
                        title: "Understanding Self-Compassion",
                        content: [
                            "Self-compassion has three vital components: being kind to yourself with understanding, remembering that you're part of the human experience, and observing your thoughts without judgment.",
                            "You cannot get angry at yourself or the situation. Sometimes we criticize ourselves for not having the \"perfect\" response."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "inner-critic-\(day)",
                        type: .innerCritic,
                        title: "Inner Critic Says",
                        content: "\"You can't do anything right. You should have known better.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "inner-friend-\(day)",
                        type: .innerFriend,
                        title: "Inner Friend Says",
                        content: "\"It's ok, everyone makes mistakes. You're human and you're doing your best.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 2:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Understanding why no contact is essential for your healing and how to handle the urge to reach out.",
                sections: [
                    LearningSection(
                        id: "no-contact-basics-\(day)",
                        title: "The Science Behind No Contact",
                        content: [
                            "No contact isn't about punishment—it's about creating space for your nervous system to regulate and your mind to gain clarity.",
                            "Every time you reach out or check their social media, you're essentially 'feeding' the neural pathways that keep you attached.",
                            "Think of it like healing a physical wound—you wouldn't keep picking at it. Your heart needs the same protection."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "urge-critic-\(day)",
                        type: .innerCritic,
                        title: "The Urge Says",
                        content: "\"Just one text won't hurt. You need closure. They might be missing you too.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "wisdom-friend-\(day)",
                        type: .innerFriend,
                        title: "Your Wisdom Says",
                        content: "\"I'm protecting my peace right now. Healing requires space, and I'm giving myself that gift.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 3:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Learning to sit with difficult emotions without trying to escape or fix them immediately.",
                sections: [
                    LearningSection(
                        id: "emotional-waves-\(day)",
                        title: "Riding the Emotional Waves",
                        content: [
                            "Emotions are like waves—they rise, peak, and naturally fall if we don't resist them.",
                            "The urge to contact them often comes from trying to escape uncomfortable feelings like loneliness, anger, or sadness.",
                            "Instead of running from these feelings, we can learn to be present with them, knowing they will pass."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "escape-critic-\(day)",
                        type: .innerCritic,
                        title: "Avoidance Says",
                        content: "\"This feeling is too much. You need to do something to make it stop right now.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "presence-friend-\(day)",
                        type: .innerFriend,
                        title: "Presence Says",
                        content: "\"I can handle this feeling. It's temporary, and I'm stronger than I think.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 4:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Creating healthy boundaries and understanding what you can and cannot control in this situation.",
                sections: [
                    LearningSection(
                        id: "boundaries-control-\(day)",
                        title: "Boundaries and Control",
                        content: [
                            "You cannot control their actions, feelings, or whether they reach out to you.",
                            "You CAN control your responses, your environment, and how you spend your energy.",
                            "Healthy boundaries aren't walls—they're gates that you get to open and close consciously."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "control-critic-\(day)",
                        type: .innerCritic,
                        title: "Control Says",
                        content: "\"If you just explain yourself better, you can fix this. You can make them understand.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "boundary-friend-\(day)",
                        type: .innerFriend,
                        title: "Boundaries Say",
                        content: "\"I focus my energy on what I can control—my healing, my growth, my peace.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 5:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Developing a toolkit of healthy coping strategies for when the urge to contact them feels overwhelming.",
                sections: [
                    LearningSection(
                        id: "coping-toolkit-\(day)",
                        title: "Your Emergency Toolkit",
                        content: [
                            "When the urge hits, you need immediate, healthy alternatives that satisfy the same emotional need.",
                            "The urge to contact often masks deeper needs: connection, validation, or comfort.",
                            "By identifying what you really need in that moment, you can meet that need in a healthier way."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "impulse-critic-\(day)",
                        type: .innerCritic,
                        title: "Impulse Says",
                        content: "\"Nothing else will help. Only talking to them will make this feeling go away.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "toolkit-friend-\(day)",
                        type: .innerFriend,
                        title: "Toolkit Says",
                        content: "\"I have many ways to care for myself. Let me try one that truly serves my healing.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 6:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Understanding the difference between loneliness and being alone, and finding peace in solitude.",
                sections: [
                    LearningSection(
                        id: "solitude-vs-loneliness-\(day)",
                        title: "Solitude vs. Loneliness",
                        content: [
                            "Loneliness is feeling disconnected even when surrounded by people. Solitude is choosing to be alone and finding peace in it.",
                            "Learning to enjoy your own company is one of the greatest gifts you can give yourself.",
                            "This time alone isn't empty—it's full of potential for self-discovery and growth."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "lonely-critic-\(day)",
                        type: .innerCritic,
                        title: "Loneliness Says",
                        content: "\"You're all alone. No one understands you. You need them to feel complete.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "solitude-friend-\(day)",
                        type: .innerFriend,
                        title: "Solitude Says",
                        content: "\"I am whole on my own. This quiet time is helping me reconnect with who I really am.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 7:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Celebrating your first week of no contact and recognizing the strength you've already shown.",
                sections: [
                    LearningSection(
                        id: "week-one-milestone-\(day)",
                        title: "Your First Week Victory",
                        content: [
                            "You've made it through seven days—that's seven days of choosing yourself over the familiar pull of old patterns.",
                            "Each day you didn't reach out was an act of self-respect and commitment to your healing.",
                            "Notice what's different: Are you sleeping better? Feeling less anxious? Starting to remember who you are outside of that relationship?"
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "minimize-critic-\(day)",
                        type: .innerCritic,
                        title: "Minimizing Says",
                        content: "\"It's only been a week. That's nothing. You haven't really accomplished anything yet.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "celebration-friend-\(day)",
                        type: .innerFriend,
                        title: "Celebration Says",
                        content: "\"Seven days of choosing my healing is huge. I'm building strength and self-respect every day.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 8:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Rediscovering who you are outside of that relationship and reconnecting with your authentic self.",
                sections: [
                    LearningSection(
                        id: "identity-rediscovery-\(day)",
                        title: "Reclaiming Your Identity",
                        content: [
                            "Relationships can sometimes blur our sense of self. We adapt, compromise, and sometimes lose touch with our own preferences and dreams.",
                            "This time apart is an opportunity to remember what you love, what excites you, and what makes you uniquely you.",
                            "Your identity isn't defined by your relationship status—you are whole and complete on your own."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "lost-critic-\(day)",
                        type: .innerCritic,
                        title: "Lost Self Says",
                        content: "\"You don't even know who you are anymore. You gave up everything for them.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "discovery-friend-\(day)",
                        type: .innerFriend,
                        title: "Discovery Says",
                        content: "\"This is my chance to rediscover all the amazing parts of myself. I'm excited to meet myself again.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 9:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Understanding and processing anger in healthy ways as part of your healing journey.",
                sections: [
                    LearningSection(
                        id: "healthy-anger-\(day)",
                        title: "Anger as Information",
                        content: [
                            "Anger often gets a bad reputation, but it's actually valuable information about our boundaries and values.",
                            "Feeling angry about how you were treated doesn't make you a bad person—it shows you have self-respect.",
                            "The goal isn't to eliminate anger, but to process it in ways that serve your healing rather than keeping you stuck."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "anger-shame-critic-\(day)",
                        type: .innerCritic,
                        title: "Shame Says",
                        content: "\"You shouldn't feel angry. Good people don't hold grudges. Just forgive and move on.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "anger-wisdom-friend-\(day)",
                        type: .innerFriend,
                        title: "Wisdom Says",
                        content: "\"My anger is telling me something important about my boundaries. I can honor it while still choosing peace.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 10:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Navigating social situations and well-meaning friends who might not understand your healing process.",
                sections: [
                    LearningSection(
                        id: "social-navigation-\(day)",
                        title: "Handling Social Pressure",
                        content: [
                            "Friends and family often mean well, but they might not understand why you need space or why you can't 'just get over it.'",
                            "You don't owe anyone an explanation for your healing timeline or your choices about contact.",
                            "It's okay to set boundaries with people who pressure you to reach out or 'forgive and forget' before you're ready."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "pressure-critic-\(day)",
                        type: .innerCritic,
                        title: "Pressure Says",
                        content: "\"Everyone thinks you're being dramatic. Maybe you should just text them and end this.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "boundary-friend-\(day)",
                        type: .innerFriend,
                        title: "Boundaries Say",
                        content: "\"I trust my own healing process. I don't need others' approval to take care of myself.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 11:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Exploring the difference between missing the person and missing the routine or familiarity.",
                sections: [
                    LearningSection(
                        id: "missing-vs-habit-\(day)",
                        title: "Missing Them vs. Missing the Habit",
                        content: [
                            "Sometimes what we think is missing the person is actually missing the routine, the familiarity, or the role they played in our daily life.",
                            "It's normal to miss having someone to text throughout the day, even if those conversations weren't always positive.",
                            "Learning to distinguish between genuine love and attachment to patterns helps clarify your feelings."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "confusion-critic-\(day)",
                        type: .innerCritic,
                        title: "Confusion Says",
                        content: "\"You miss them so much, this proves you made a mistake. You should reach out.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "clarity-friend-\(day)",
                        type: .innerFriend,
                        title: "Clarity Says",
                        content: "\"I can miss the good parts while still knowing this space is what I need right now.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 12:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Building new routines and rituals that support your healing and bring you joy.",
                sections: [
                    LearningSection(
                        id: "new-routines-\(day)",
                        title: "Creating Healing Rituals",
                        content: [
                            "The space left by their absence can be filled with practices that truly nourish you.",
                            "New routines help signal to your brain that this is a new chapter, not just an empty space waiting to be filled.",
                            "Small, consistent acts of self-care become the foundation for a life that feels good from the inside out."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "empty-critic-\(day)",
                        type: .innerCritic,
                        title: "Emptiness Says",
                        content: "\"Nothing you do will fill this void. You're just trying to distract yourself from the truth.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "creation-friend-\(day)",
                        type: .innerFriend,
                        title: "Creation Says",
                        content: "\"I'm building a life that feels good because I choose what fills it. This is empowering.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 13:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Understanding trauma bonding and why it can feel so hard to let go, even when you know you should.",
                sections: [
                    LearningSection(
                        id: "trauma-bonding-\(day)",
                        title: "Understanding Trauma Bonds",
                        content: [
                            "Trauma bonding occurs when intense emotional experiences create strong attachments, even in unhealthy relationships.",
                            "The highs and lows, the uncertainty, and the intermittent reinforcement can create powerful psychological bonds.",
                            "Understanding this isn't about blame—it's about compassion for why your heart might feel confused even when your mind knows better."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "bond-critic-\(day)",
                        type: .innerCritic,
                        title: "Confusion Says",
                        content: "\"If it was really that bad, why do you miss them so much? You must be making it up.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "understanding-friend-\(day)",
                        type: .innerFriend,
                        title: "Understanding Says",
                        content: "\"My feelings are valid and complex. I can have compassion for my heart while still protecting myself.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 14:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Celebrating two weeks of growth and setting intentions for continued healing in your third week.",
                sections: [
                    LearningSection(
                        id: "two-week-milestone-\(day)",
                        title: "Two Weeks of Courage",
                        content: [
                            "Fourteen days of choosing yourself. Fourteen days of building new neural pathways. Fourteen days of proving to yourself that you can do hard things.",
                            "You've navigated urges, processed emotions, and started rebuilding your identity. This is profound work.",
                            "Notice how your relationship with yourself has shifted. You're becoming your own safe harbor."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "minimize-progress-critic-\(day)",
                        type: .innerCritic,
                        title: "Minimizing Says",
                        content: "\"Two weeks isn't that long. You still have so far to go. This is taking forever.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "milestone-friend-\(day)",
                        type: .innerFriend,
                        title: "Milestone Says",
                        content: "\"Two weeks of consistent self-care and boundary-keeping is incredible. I'm proud of my commitment to healing.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 15:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Beginning to understand your relationship patterns and how they developed over time.",
                sections: [
                    LearningSection(
                        id: "relationship-patterns-\(day)",
                        title: "Understanding Your Patterns",
                        content: [
                            "We all have patterns in relationships—ways we connect, communicate, and handle conflict that feel familiar to us.",
                            "These patterns often develop early in life and can be both helpful and limiting in different situations.",
                            "Awareness is the first step to choice. When you understand your patterns, you can decide which ones serve you and which ones you want to change."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "pattern-shame-critic-\(day)",
                        type: .innerCritic,
                        title: "Shame Says",
                        content: "\"You always choose the wrong people. You're broken and you'll never learn.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "pattern-wisdom-friend-\(day)",
                        type: .innerFriend,
                        title: "Wisdom Says",
                        content: "\"My patterns made sense at the time. Now I can learn and choose differently with awareness.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 16:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Exploring your attachment style and how it influences your relationships and healing process.",
                sections: [
                    LearningSection(
                        id: "attachment-styles-\(day)",
                        title: "Understanding Attachment",
                        content: [
                            "Attachment styles are patterns of how we connect with others, formed in our earliest relationships.",
                            "Secure attachment feels safe and trusting. Anxious attachment craves closeness but fears abandonment. Avoidant attachment values independence but struggles with intimacy.",
                            "Understanding your attachment style isn't about labeling yourself—it's about having compassion for your relationship needs and fears."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "attachment-critic-\(day)",
                        type: .innerCritic,
                        title: "Judgment Says",
                        content: "\"You're too needy/too distant. No wonder relationships don't work for you.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "attachment-friend-\(day)",
                        type: .innerFriend,
                        title: "Understanding Says",
                        content: "\"My attachment style developed for good reasons. I can work with it, not against it.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 17:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Recognizing red flags and green flags in relationships to guide future choices.",
                sections: [
                    LearningSection(
                        id: "relationship-flags-\(day)",
                        title: "Red Flags and Green Flags",
                        content: [
                            "Red flags are warning signs of unhealthy dynamics: controlling behavior, disrespect for boundaries, inconsistent communication, or making you feel small.",
                            "Green flags are signs of healthy connection: respect for your autonomy, consistent kindness, healthy conflict resolution, and support for your growth.",
                            "Trust your instincts. If something feels off early on, it's usually worth paying attention to that feeling."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "flags-doubt-critic-\(day)",
                        type: .innerCritic,
                        title: "Doubt Says",
                        content: "\"You're being too picky. Everyone has flaws. You'll end up alone if you have standards.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "flags-wisdom-friend-\(day)",
                        type: .innerFriend,
                        title: "Wisdom Says",
                        content: "\"I deserve healthy love. Having standards protects my peace and opens space for the right person.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 18:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Envisioning your future self and the life you want to create beyond this healing journey.",
                sections: [
                    LearningSection(
                        id: "future-visioning-\(day)",
                        title: "Your Future Self",
                        content: [
                            "Healing isn't just about getting over the past—it's about creating a future that excites you.",
                            "Your future self has learned from this experience, grown stronger, and knows their worth deeply.",
                            "This vision isn't about perfection; it's about becoming someone who trusts themselves and chooses relationships that honor their growth."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "future-fear-critic-\(day)",
                        type: .innerCritic,
                        title: "Fear Says",
                        content: "\"You'll never be different. You'll just repeat the same patterns and get hurt again.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "future-hope-friend-\(day)",
                        type: .innerFriend,
                        title: "Hope Says",
                        content: "\"I'm already changing. Every day of healing is creating a wiser, stronger version of myself.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 19:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Setting boundaries for future relationships based on what you've learned about yourself.",
                sections: [
                    LearningSection(
                        id: "future-boundaries-\(day)",
                        title: "Boundaries for Your Future",
                        content: [
                            "The boundaries you're learning to set now will protect and serve you in all future relationships.",
                            "Healthy boundaries aren't walls—they're guidelines that help you maintain your sense of self while connecting with others.",
                            "People who are right for you will respect your boundaries. Those who don't are showing you they're not your people."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "boundary-fear-critic-\(day)",
                        type: .innerCritic,
                        title: "Fear Says",
                        content: "\"If you have too many boundaries, no one will want to be with you. You'll push everyone away.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "boundary-strength-friend-\(day)",
                        type: .innerFriend,
                        title: "Strength Says",
                        content: "\"My boundaries attract the right people and protect me from the wrong ones. This is wisdom.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 20:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Understanding forgiveness as a gift to yourself, not a requirement or timeline.",
                sections: [
                    LearningSection(
                        id: "forgiveness-understanding-\(day)",
                        title: "Forgiveness on Your Terms",
                        content: [
                            "Forgiveness is often misunderstood. It's not about excusing behavior, forgetting what happened, or rushing to 'move on.'",
                            "True forgiveness is releasing the grip that resentment has on your peace. It's something you do for yourself, when you're ready.",
                            "You can heal and move forward without forgiving. Forgiveness is a choice, not a requirement for your healing."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "forgiveness-pressure-critic-\(day)",
                        type: .innerCritic,
                        title: "Pressure Says",
                        content: "\"Good people forgive. You're holding a grudge. You need to let this go to heal.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "forgiveness-choice-friend-\(day)",
                        type: .innerFriend,
                        title: "Choice Says",
                        content: "\"I'll forgive if and when it serves my peace. My healing doesn't depend on anyone else's timeline.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 21:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Celebrating three weeks of incredible growth and transformation. You've come so far.",
                sections: [
                    LearningSection(
                        id: "three-week-milestone-\(day)",
                        title: "Three Weeks of Transformation",
                        content: [
                            "Twenty-one days. Three weeks of choosing yourself, processing emotions, and building new patterns.",
                            "You've moved through self-compassion, identity rediscovery, anger processing, and future visioning. This is profound personal work.",
                            "Notice how different you feel from Day 1. You're not the same person who started this journey—you're wiser, stronger, and more connected to yourself."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "three-week-doubt-critic-\(day)",
                        type: .innerCritic,
                        title: "Doubt Says",
                        content: "\"Three weeks isn't enough. You still have bad days. You're not really healed yet.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "three-week-celebration-friend-\(day)",
                        type: .innerFriend,
                        title: "Celebration Says",
                        content: "\"Three weeks of consistent growth is amazing. I can see how much I've changed and I'm proud of myself.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 22:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Integrating all you've learned into a new way of being. You're not just healing—you're transforming.",
                sections: [
                    LearningSection(
                        id: "integration-wisdom-\(day)",
                        title: "Integrating Your Wisdom",
                        content: [
                            "Integration means taking all the insights, tools, and growth from this journey and weaving them into your daily life.",
                            "You've learned to be compassionate with yourself, set boundaries, process emotions, and envision your future. These aren't just concepts—they're your new superpowers.",
                            "The goal isn't perfection; it's conscious living. You now have awareness and choice where you once had only reaction."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "integration-overwhelm-critic-\(day)",
                        type: .innerCritic,
                        title: "Overwhelm Says",
                        content: "\"This is too much to remember. You'll forget everything and go back to old patterns.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "integration-confidence-friend-\(day)",
                        type: .innerFriend,
                        title: "Confidence Says",
                        content: "\"I don't need to be perfect. I have tools now, and I trust myself to use them when I need them.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 23:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Understanding that healing isn't linear and preparing for the waves that may still come.",
                sections: [
                    LearningSection(
                        id: "healing-waves-\(day)",
                        title: "Riding the Waves of Healing",
                        content: [
                            "Healing isn't a straight line from pain to peace. There will still be difficult days, moments of missing them, or times when old patterns try to resurface.",
                            "This doesn't mean you're going backward or that your healing isn't real. It means you're human, and healing happens in waves.",
                            "The difference now is that you have tools, awareness, and a stronger foundation to weather these waves without being swept away."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "waves-failure-critic-\(day)",
                        type: .innerCritic,
                        title: "Failure Says",
                        content: "\"You had a bad day, so all this work was pointless. You're back to square one.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "waves-resilience-friend-\(day)",
                        type: .innerFriend,
                        title: "Resilience Says",
                        content: "\"One difficult day doesn't erase my growth. I can feel the wave and know it will pass.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 24:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Building your support system and community for continued growth beyond this program.",
                sections: [
                    LearningSection(
                        id: "support-community-\(day)",
                        title: "Building Your Healing Community",
                        content: [
                            "Healing happens in relationship—not just romantic relationships, but in community with people who see and support your growth.",
                            "Your support system might include friends, family, therapists, support groups, or online communities of people on similar journeys.",
                            "You deserve to be surrounded by people who celebrate your healing, respect your boundaries, and encourage your continued growth."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "community-isolation-critic-\(day)",
                        type: .innerCritic,
                        title: "Isolation Says",
                        content: "\"You don't need anyone. People will just disappoint you. It's safer to stay alone.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "community-connection-friend-\(day)",
                        type: .innerFriend,
                        title: "Connection Says",
                        content: "\"I can choose healthy connections. I deserve support and I can offer support to others too.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 25:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Exploring what it means to be ready for new relationships—romantic and otherwise.",
                sections: [
                    LearningSection(
                        id: "relationship-readiness-\(day)",
                        title: "Readiness for New Connections",
                        content: [
                            "Being ready for new relationships isn't about being 'completely healed' or never thinking about the past. It's about having a solid relationship with yourself.",
                            "You're ready when you can be alone without being lonely, when you have clear boundaries, and when you're choosing connection from wholeness, not neediness.",
                            "The right connections will honor your growth and add to your life rather than completing it."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "readiness-rush-critic-\(day)",
                        type: .innerCritic,
                        title: "Rush Says",
                        content: "\"You need to find someone soon or you'll be alone forever. You're wasting time healing.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "readiness-patience-friend-\(day)",
                        type: .innerFriend,
                        title: "Patience Says",
                        content: "\"I'm building something beautiful within myself. The right connections will come when I'm ready.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 26:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Discovering your new relationship with yourself and how it changes everything.",
                sections: [
                    LearningSection(
                        id: "self-relationship-\(day)",
                        title: "Your New Relationship with Yourself",
                        content: [
                            "The most important relationship you'll ever have is the one with yourself. This journey has been about rebuilding that relationship with intention and love.",
                            "You've learned to speak to yourself with kindness, trust your instincts, honor your needs, and celebrate your growth.",
                            "This new relationship with yourself becomes the foundation for all other relationships. When you love yourself well, you teach others how to love you."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "self-love-selfish-critic-\(day)",
                        type: .innerCritic,
                        title: "Selfish Says",
                        content: "\"Focusing on yourself is selfish. You should be thinking about others, not yourself.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "self-love-foundation-friend-\(day)",
                        type: .innerFriend,
                        title: "Foundation Says",
                        content: "\"Loving myself well allows me to love others better. This is the foundation of all healthy relationships.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 27:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Envisioning your life beyond healing—what does thriving look like for you?",
                sections: [
                    LearningSection(
                        id: "beyond-healing-\(day)",
                        title: "Life Beyond Healing",
                        content: [
                            "There comes a point in every healing journey where you stop identifying primarily as someone who is healing and start identifying as someone who is thriving.",
                            "Your story isn't defined by what happened to you or what you survived. It's defined by who you chose to become and how you used your experiences to grow.",
                            "You're not just recovering from something—you're creating something beautiful and new."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "beyond-identity-critic-\(day)",
                        type: .innerCritic,
                        title: "Identity Says",
                        content: "\"Your pain is all you have. Without your story of struggle, who are you really?\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "beyond-creation-friend-\(day)",
                        type: .innerFriend,
                        title: "Creation Says",
                        content: "\"My experiences shaped me, but they don't define me. I'm creating a life that reflects who I'm becoming.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 28:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Becoming a source of wisdom and support for others who are beginning their healing journey.",
                sections: [
                    LearningSection(
                        id: "wisdom-sharing-\(day)",
                        title: "Sharing Your Wisdom",
                        content: [
                            "One of the most beautiful aspects of healing is how it creates capacity to help others. Your journey has given you wisdom that can light the way for someone else.",
                            "You don't need to be a therapist or coach to make a difference. Sometimes it's as simple as listening without judgment or sharing that healing is possible.",
                            "Your healing ripples out into the world, creating more healing. This is how we change the world—one person, one story, one act of courage at a time."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "wisdom-inadequate-critic-\(day)",
                        type: .innerCritic,
                        title: "Inadequate Says",
                        content: "\"You're not qualified to help anyone. You're still figuring things out yourself.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "wisdom-gift-friend-\(day)",
                        type: .innerFriend,
                        title: "Gift Says",
                        content: "\"My experience has value. I can share my story and support others while continuing to grow.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 29:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Reflecting on your complete transformation and preparing for your graduation tomorrow.",
                sections: [
                    LearningSection(
                        id: "transformation-reflection-\(day)",
                        title: "Your Complete Transformation",
                        content: [
                            "Tomorrow marks the completion of your 30-day journey, but today is for reflection. Look at who you were 29 days ago and who you are now.",
                            "You've developed self-compassion, emotional regulation, boundary-setting skills, pattern awareness, and a vision for your future. This is profound personal transformation.",
                            "Most importantly, you've proven to yourself that you can do hard things, that you can choose yourself, and that you can create change in your life."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "transformation-minimize-critic-\(day)",
                        type: .innerCritic,
                        title: "Minimize Says",
                        content: "\"You haven't really changed that much. This was just a distraction. You're still the same person.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "transformation-recognition-friend-\(day)",
                        type: .innerFriend,
                        title: "Recognition Says",
                        content: "\"I am fundamentally different than I was 29 days ago. I can see it, feel it, and trust it.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        case 30:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Celebrating your graduation and stepping into your new life with confidence, wisdom, and hope.",
                sections: [
                    LearningSection(
                        id: "graduation-celebration-\(day)",
                        title: "Your Graduation Day",
                        content: [
                            "Thirty days. One month. A complete cycle of transformation. You started this journey in pain, and you're ending it with wisdom, strength, and hope.",
                            "You've not just survived—you've thrived. You've not just healed—you've transformed. You've not just learned—you've become.",
                            "This isn't the end of your growth; it's your graduation into a new way of living. You now have the tools, awareness, and self-love to navigate whatever comes next."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "graduation-fear-critic-\(day)",
                        type: .innerCritic,
                        title: "Fear Says",
                        content: "\"What if you can't maintain this growth? What if you need this program forever?\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "graduation-confidence-friend-\(day)",
                        type: .innerFriend,
                        title: "Confidence Says",
                        content: "\"I have everything I need within me. I'm ready for whatever comes next because I trust myself completely.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
            
        default:
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Continue building your foundation for healing and growth in your fresh start journey.",
                sections: [
                    LearningSection(
                        id: "section-\(day)",
                        title: "Day \(day): Fresh Start Foundations",
                        content: ["Today we focus on establishing healthy routines and immediate coping strategies for your healing journey."]
                    )
                ],
                examples: []
            )
        }
    }
    
    private func createBreakupRecoveryContent(for day: Int) -> LearningContent {
        if day == 1 {
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Beginning your journey of healing from a romantic relationship. Today we focus on acknowledging your feelings and starting the process of self-compassion.",
                sections: [
                    LearningSection(
                        id: "breakup-understanding-\(day)",
                        title: "Understanding Breakup Grief",
                        content: [
                            "Breakups involve a genuine loss that requires time to process and heal from.",
                            "It's normal to feel a range of emotions - sadness, anger, confusion, and even relief.",
                            "Healing isn't linear, and it's okay to have good days and difficult days."
                        ]
                    )
                ],
                examples: [
                    Example(
                        id: "breakup-critic-\(day)",
                        type: .innerCritic,
                        title: "Inner Critic Says",
                        content: "\"You should be over this by now. Everyone else moves on faster.\"",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    ),
                    Example(
                        id: "breakup-friend-\(day)",
                        type: .innerFriend,
                        title: "Inner Friend Says",
                        content: "\"Healing takes time, and you're allowed to feel whatever you're feeling right now.\"",
                        icon: "heart.fill",
                        color: .green
                    )
                ]
            )
        } else {
            return LearningContent(
                focusTitle: "Today's Focus",
                focusDescription: "Continuing your breakup recovery journey with compassion and patience.",
                sections: [
                    LearningSection(
                        id: "breakup-section-\(day)",
                        title: "Day \(day): Breakup Recovery",
                        content: ["Today we explore healthy ways to process your emotions and rebuild your sense of self."]
                    )
                ],
                examples: []
            )
        }
    }
    
    private func create60DayRebuildContent(for day: Int) -> LearningContent {
        return LearningContent(
            focusTitle: "Today's Focus",
            focusDescription: "Exploring deeper healing patterns and rebuilding your sense of self with compassion.",
            sections: [
                LearningSection(
                    id: "rebuild-section-\(day)",
                    title: "Day \(day): Rebuilding Foundations",
                    content: ["Today we dive deeper into understanding your patterns and building lasting change."]
                )
            ],
            examples: []
        )
    }
    
    private func create90DayTransformContent(for day: Int) -> LearningContent {
        return LearningContent(
            focusTitle: "Today's Focus",
            focusDescription: "Comprehensive personal transformation with advanced healing techniques.",
            sections: [
                LearningSection(
                    id: "transform-section-\(day)",
                    title: "Day \(day): Transformation Journey",
                    content: ["Today we work on advanced techniques for lasting personal transformation."]
                )
            ],
            examples: []
        )
    }
    
    private func createFamilyHealingContent(for day: Int) -> LearningContent {
        return LearningContent(
            focusTitle: "Today's Focus",
            focusDescription: "Navigating family relationship changes with wisdom and boundaries.",
            sections: [
                LearningSection(
                    id: "family-section-\(day)",
                    title: "Day \(day): Family Healing",
                    content: ["Today we explore healthy boundaries and communication in family relationships."]
                )
            ],
            examples: []
        )
    }
    
    private func createDivorceSupportContent(for day: Int) -> LearningContent {
        return LearningContent(
            focusTitle: "Today's Focus",
            focusDescription: "Support through the divorce process with practical and emotional guidance.",
            sections: [
                LearningSection(
                    id: "divorce-section-\(day)",
                    title: "Day \(day): Divorce Support",
                    content: ["Today we focus on managing the emotional and practical aspects of divorce."]
                )
            ],
            examples: []
        )
    }
    
    private func createFriendshipClosureContent(for day: Int) -> LearningContent {
        return LearningContent(
            focusTitle: "Today's Focus",
            focusDescription: "Processing friendship endings with grace and understanding.",
            sections: [
                LearningSection(
                    id: "friendship-section-\(day)",
                    title: "Day \(day): Friendship Closure",
                    content: ["Today we explore how to process the end of friendships with compassion."]
                )
            ],
            examples: []
        )
    }
    
    private func createDefaultContent(for day: Int) -> LearningContent {
        return LearningContent(
            focusTitle: "Today's Focus",
            focusDescription: "Continue building your foundation for healing and growth.",
            sections: [
                LearningSection(
                    id: "section-\(day)",
                    title: "Day \(day) Learning",
                    content: ["Today's learning content for day \(day)."]
                )
            ],
            examples: []
        )
    }
    
    private func createSamplePracticeContent(for day: Int, programId: String = "30-day-fresh-start") -> PracticeContent {
        if programId == "30-day-fresh-start" {
            return create30DayFreshStartPractice(for: day)
        } else {
            return createDefaultPracticeContent(for: day)
        }
    }
    
    private func create30DayFreshStartPractice(for day: Int) -> PracticeContent {
        switch day {
        case 1:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "inner-critic-identification-\(day)",
                        title: "Think of a recent situation where you were hard on yourself. Write down what your inner critic said to you.",
                        placeholder: "My inner critic said things like...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "inner-friend-reframe-\(day)",
                        title: "Now, rewrite that same situation from the perspective of a caring friend. What would they say to you?",
                        placeholder: "A caring friend would say...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "self-compassion-reflection-\(day)",
                        question: "How does it feel to try to treat yourself with kindness you'd give a friend?",
                        placeholder: "Treating myself with kindness feels...",
                        response: ""
                    ),
                    Reflection(
                        id: "daily-compassion-\(day)",
                        question: "How are you today? What would you like to tell yourself with more compassion?",
                        placeholder: "Today I want to tell myself...",
                        response: ""
                    )
                ]
            )
            
        case 2:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "no-contact-commitment-\(day)",
                        title: "Write down your personal reasons for choosing no contact. What are you protecting by maintaining this boundary?",
                        placeholder: "I'm choosing no contact because...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "urge-plan-\(day)",
                        title: "Create your 'urge action plan.' What will you do the next time you feel like reaching out?",
                        placeholder: "When I feel the urge to contact them, I will...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "no-contact-strength-\(day)",
                        question: "What strength did it take to start no contact? Acknowledge the courage you've already shown.",
                        placeholder: "It took strength to...",
                        response: ""
                    ),
                    Reflection(
                        id: "healing-space-\(day)",
                        question: "How does it feel to give yourself this space to heal?",
                        placeholder: "This space feels...",
                        response: ""
                    )
                ]
            )
            
        case 8:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "identity-rediscovery-\(day)",
                        title: "List 5 things you loved about yourself before this relationship. What made you uniquely you?",
                        placeholder: "Before this relationship, I loved that I was:\n1. \n2. \n3. \n4. \n5. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "interests-exploration-\(day)",
                        title: "What interests or hobbies did you put aside? Choose one to reconnect with this week.",
                        placeholder: "I want to reconnect with...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "authentic-self-\(day)",
                        question: "What parts of your authentic self are you excited to rediscover?",
                        placeholder: "I'm excited to rediscover...",
                        response: ""
                    ),
                    Reflection(
                        id: "identity-growth-\(day)",
                        question: "How has this experience taught you more about who you are and what you value?",
                        placeholder: "This experience has taught me...",
                        response: ""
                    )
                ]
            )
            
        case 9:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "anger-letter-\(day)",
                        title: "Write an anger letter (that you won't send). Express everything you feel without censoring yourself.",
                        placeholder: "I feel angry because...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "anger-wisdom-\(day)",
                        title: "What is your anger trying to tell you about your boundaries or values?",
                        placeholder: "My anger is telling me that...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "anger-acceptance-\(day)",
                        question: "How does it feel to give yourself permission to feel angry?",
                        placeholder: "Allowing myself to feel angry feels...",
                        response: ""
                    ),
                    Reflection(
                        id: "anger-release-\(day)",
                        question: "What healthy ways can you release this anger energy?",
                        placeholder: "I can release anger by...",
                        response: ""
                    )
                ]
            )
            
        case 10:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "social-boundaries-\(day)",
                        title: "Practice responses for people who pressure you about your no-contact choice.",
                        placeholder: "When someone says 'You should just call them,' I can respond: ...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "support-network-\(day)",
                        title: "Identify 3 people who truly support your healing journey without judgment.",
                        placeholder: "People who support my healing:\n1. \n2. \n3. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "social-confidence-\(day)",
                        question: "How confident do you feel in defending your healing choices to others?",
                        placeholder: "I feel... about defending my choices because...",
                        response: ""
                    ),
                    Reflection(
                        id: "support-gratitude-\(day)",
                        question: "What are you grateful for in your support system?",
                        placeholder: "I'm grateful for...",
                        response: ""
                    )
                ]
            )
            
        case 11:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "missing-analysis-\(day)",
                        title: "When you miss them, write down specifically what you miss. Is it the person or the routine?",
                        placeholder: "When I miss them, I specifically miss:\n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "routine-replacement-\(day)",
                        title: "For each routine you miss, create a new, healthier version that serves you.",
                        placeholder: "Instead of texting them good morning, I will...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "missing-clarity-\(day)",
                        question: "What's the difference between missing them and missing the familiarity?",
                        placeholder: "Missing them feels like... while missing familiarity feels like...",
                        response: ""
                    ),
                    Reflection(
                        id: "new-patterns-\(day)",
                        question: "How do your new routines make you feel compared to the old ones?",
                        placeholder: "My new routines make me feel...",
                        response: ""
                    )
                ]
            )
            
        case 12:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "morning-ritual-\(day)",
                        title: "Design a morning ritual that makes you feel grounded and loved. What would nurture you?",
                        placeholder: "My ideal morning ritual includes:\n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "evening-ritual-\(day)",
                        title: "Create an evening ritual that helps you process the day and prepare for rest.",
                        placeholder: "My evening ritual will include:\n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "ritual-meaning-\(day)",
                        question: "What do these new rituals represent for you in your healing journey?",
                        placeholder: "These rituals represent...",
                        response: ""
                    ),
                    Reflection(
                        id: "self-care-commitment-\(day)",
                        question: "How does it feel to prioritize caring for yourself in this way?",
                        placeholder: "Prioritizing self-care feels...",
                        response: ""
                    )
                ]
            )
            
        case 13:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "bond-recognition-\(day)",
                        title: "Identify patterns in your relationship that might have created strong emotional bonds.",
                        placeholder: "Patterns that created strong bonds:\n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "compassion-letter-\(day)",
                        title: "Write a compassionate letter to yourself about why it's hard to let go.",
                        placeholder: "Dear Self, it's understandable that letting go is hard because...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "bond-understanding-\(day)",
                        question: "How does understanding trauma bonding change how you view your feelings?",
                        placeholder: "Understanding trauma bonding helps me see...",
                        response: ""
                    ),
                    Reflection(
                        id: "healing-patience-\(day)",
                        question: "What would you tell a friend who was struggling with similar feelings?",
                        placeholder: "I would tell a friend...",
                        response: ""
                    )
                ]
            )
            
        case 14:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "two-week-wins-\(day)",
                        title: "List all the ways you've grown in these two weeks. Celebrate every small victory.",
                        placeholder: "In two weeks, I've grown by:\n• \n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "week-three-intentions-\(day)",
                        title: "Set 3 intentions for your third week of healing. What do you want to focus on?",
                        placeholder: "In week three, I intend to:\n1. \n2. \n3. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "progress-pride-\(day)",
                        question: "What are you most proud of accomplishing in these two weeks?",
                        placeholder: "I'm most proud of...",
                        response: ""
                    ),
                    Reflection(
                        id: "future-vision-\(day)",
                        question: "How do you envision yourself feeling at the end of 30 days?",
                        placeholder: "At the end of 30 days, I see myself...",
                        response: ""
                    )
                ]
            )
            
        case 15:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "pattern-identification-\(day)",
                        title: "Identify 3 patterns you notice in your past relationships (communication, conflict, attachment, etc.).",
                        placeholder: "Patterns I notice:\n1. \n2. \n3. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "pattern-origins-\(day)",
                        title: "For each pattern, explore where it might have come from. What was it trying to protect or achieve?",
                        placeholder: "This pattern developed because...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "pattern-compassion-\(day)",
                        question: "How can you have compassion for yourself for developing these patterns?",
                        placeholder: "I can have compassion because...",
                        response: ""
                    ),
                    Reflection(
                        id: "pattern-choice-\(day)",
                        question: "Which patterns serve you and which would you like to change?",
                        placeholder: "I want to keep... and change...",
                        response: ""
                    )
                ]
            )
            
        case 16:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "attachment-exploration-\(day)",
                        title: "Reflect on your attachment style. Do you tend to be anxious, avoidant, or secure in relationships?",
                        placeholder: "In relationships, I tend to...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "attachment-needs-\(day)",
                        title: "What are your core needs in relationships? (Security, independence, closeness, etc.)",
                        placeholder: "My core relationship needs are:\n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "attachment-acceptance-\(day)",
                        question: "How can you honor your attachment needs while still growing?",
                        placeholder: "I can honor my needs by...",
                        response: ""
                    ),
                    Reflection(
                        id: "attachment-growth-\(day)",
                        question: "What would a more secure version of yourself look like in relationships?",
                        placeholder: "A more secure me would...",
                        response: ""
                    )
                ]
            )
            
        case 17:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "red-flags-list-\(day)",
                        title: "Create your personal red flags list based on your experiences. What are your non-negotiables?",
                        placeholder: "My red flags include:\n• \n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "green-flags-list-\(day)",
                        title: "Create your green flags list. What qualities and behaviors do you want to see?",
                        placeholder: "My green flags include:\n• \n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "standards-confidence-\(day)",
                        question: "How does it feel to clearly define what you will and won't accept?",
                        placeholder: "Having clear standards feels...",
                        response: ""
                    ),
                    Reflection(
                        id: "standards-commitment-\(day)",
                        question: "What will help you stick to these standards when you meet someone new?",
                        placeholder: "I'll stick to my standards by...",
                        response: ""
                    )
                ]
            )
            
        case 18:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "future-self-vision-\(day)",
                        title: "Write a detailed description of your future self 1 year from now. How do they think, feel, and act?",
                        placeholder: "One year from now, I am someone who...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "future-relationship-\(day)",
                        title: "Describe the kind of relationship your future self has. What does healthy love look like for you?",
                        placeholder: "In my ideal relationship, we...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "vision-excitement-\(day)",
                        question: "What excites you most about becoming this version of yourself?",
                        placeholder: "I'm most excited about...",
                        response: ""
                    ),
                    Reflection(
                        id: "vision-steps-\(day)",
                        question: "What's one small step you can take today toward this future self?",
                        placeholder: "One step I can take today is...",
                        response: ""
                    )
                ]
            )
            
        case 19:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "future-boundaries-\(day)",
                        title: "Define your relationship boundaries for the future. What will you communicate early on?",
                        placeholder: "My relationship boundaries are:\n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "boundary-communication-\(day)",
                        title: "Practice how you'll communicate these boundaries. Write out kind but clear statements.",
                        placeholder: "I can communicate boundaries by saying...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "boundary-confidence-\(day)",
                        question: "How confident do you feel about maintaining these boundaries?",
                        placeholder: "I feel... about my boundaries because...",
                        response: ""
                    ),
                    Reflection(
                        id: "boundary-attraction-\(day)",
                        question: "How might having clear boundaries actually attract healthier relationships?",
                        placeholder: "Clear boundaries attract healthy people because...",
                        response: ""
                    )
                ]
            )
            
        case 20:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "forgiveness-exploration-\(day)",
                        title: "Explore your feelings about forgiveness. Do you feel pressure to forgive? What would forgiveness mean to you?",
                        placeholder: "When I think about forgiveness, I feel...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "forgiveness-choice-\(day)",
                        title: "Write about forgiveness as a choice you make for yourself, not for anyone else.",
                        placeholder: "If I choose to forgive, it would be because...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "forgiveness-pressure-\(day)",
                        question: "What would you tell someone who felt pressured to forgive before they were ready?",
                        placeholder: "I would tell them...",
                        response: ""
                    ),
                    Reflection(
                        id: "forgiveness-peace-\(day)",
                        question: "What brings you peace right now, regardless of forgiveness?",
                        placeholder: "What brings me peace is...",
                        response: ""
                    )
                ]
            )
            
        case 21:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "three-week-transformation-\(day)",
                        title: "Write a letter to your Day 1 self. What would you tell them about this journey?",
                        placeholder: "Dear Day 1 Me,\n\nI want you to know...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "week-four-goals-\(day)",
                        title: "Set intentions for your final week. What do you want to focus on to complete this transformation?",
                        placeholder: "In my final week, I want to:\n1. \n2. \n3. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "three-week-pride-\(day)",
                        question: "What transformation are you most proud of in these three weeks?",
                        placeholder: "I'm most proud of how I've...",
                        response: ""
                    ),
                    Reflection(
                        id: "three-week-wisdom-\(day)",
                        question: "What's the most important thing you've learned about yourself?",
                        placeholder: "The most important thing I've learned is...",
                        response: ""
                    )
                ]
            )
            
        case 22:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "integration-toolkit-\(day)",
                        title: "Create your personal integration toolkit. List the top 5 tools/insights you want to remember daily.",
                        placeholder: "My daily toolkit includes:\n1. \n2. \n3. \n4. \n5. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "integration-practice-\(day)",
                        title: "Choose one tool from your toolkit and practice using it in a current situation.",
                        placeholder: "I'm applying... to the situation of...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "integration-confidence-\(day)",
                        question: "How confident do you feel about integrating these tools into your daily life?",
                        placeholder: "I feel... about using my tools because...",
                        response: ""
                    ),
                    Reflection(
                        id: "integration-growth-\(day)",
                        question: "What does 'conscious living' mean to you now?",
                        placeholder: "Conscious living means...",
                        response: ""
                    )
                ]
            )
            
        case 23:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "wave-preparation-\(day)",
                        title: "Create a plan for difficult days. What will you do when healing waves hit?",
                        placeholder: "When I have a difficult day, I will:\n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "wave-mantras-\(day)",
                        title: "Write 3 mantras you can use during challenging moments to remind yourself of your growth.",
                        placeholder: "My mantras are:\n1. \n2. \n3. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "wave-acceptance-\(day)",
                        question: "How has your relationship with difficult emotions changed during this journey?",
                        placeholder: "My relationship with difficult emotions has changed because...",
                        response: ""
                    ),
                    Reflection(
                        id: "wave-resilience-\(day)",
                        question: "What evidence do you have that you can weather emotional storms?",
                        placeholder: "I know I can handle storms because...",
                        response: ""
                    )
                ]
            )
            
        case 24:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "support-mapping-\(day)",
                        title: "Map your current support system. Who are your people for different types of support?",
                        placeholder: "For emotional support: ...\nFor practical help: ...\nFor fun and joy: ...\nFor growth and challenge: ...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "support-expansion-\(day)",
                        title: "Identify one way you can expand or strengthen your support system this month.",
                        placeholder: "I can expand my support by...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "support-gratitude-\(day)",
                        question: "Who in your life has supported your healing journey, and how can you express gratitude?",
                        placeholder: "I'm grateful to... for...",
                        response: ""
                    ),
                    Reflection(
                        id: "support-offering-\(day)",
                        question: "How can you be a source of support for others in your community?",
                        placeholder: "I can support others by...",
                        response: ""
                    )
                ]
            )
            
        case 25:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "readiness-assessment-\(day)",
                        title: "Honestly assess your relationship readiness. What areas feel strong and what needs more growth?",
                        placeholder: "I feel ready in these areas: ...\n\nI want to continue growing in: ...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "readiness-standards-\(day)",
                        title: "Define what 'choosing from wholeness' means for you in future relationships.",
                        placeholder: "Choosing from wholeness means...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "readiness-patience-\(day)",
                        question: "How do you feel about the timing of your healing and readiness for new connections?",
                        placeholder: "I feel... about my timing because...",
                        response: ""
                    ),
                    Reflection(
                        id: "readiness-excitement-\(day)",
                        question: "What excites you most about future healthy relationships?",
                        placeholder: "I'm most excited about...",
                        response: ""
                    )
                ]
            )
            
        case 26:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "self-relationship-appreciation-\(day)",
                        title: "Write a love letter to yourself, acknowledging all the ways you've grown and changed.",
                        placeholder: "Dear Self,\n\nI love how you...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "self-relationship-commitment-\(day)",
                        title: "Make commitments to yourself about how you'll continue to nurture this relationship.",
                        placeholder: "I commit to continuing to:\n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "self-love-foundation-\(day)",
                        question: "How has learning to love yourself changed your expectations for how others should treat you?",
                        placeholder: "Learning to love myself has changed my expectations because...",
                        response: ""
                    ),
                    Reflection(
                        id: "self-love-modeling-\(day)",
                        question: "How do you want to model healthy self-love for others in your life?",
                        placeholder: "I want to model self-love by...",
                        response: ""
                    )
                ]
            )
            
        case 27:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "thriving-vision-\(day)",
                        title: "Describe your thriving life in detail. What does a life beyond healing look like for you?",
                        placeholder: "My thriving life includes:\n• \n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "thriving-steps-\(day)",
                        title: "Identify 3 concrete steps you can take this month toward your thriving life vision.",
                        placeholder: "Steps toward thriving:\n1. \n2. \n3. ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "beyond-identity-\(day)",
                        question: "How do you want to be known and remembered beyond your healing story?",
                        placeholder: "I want to be known for...",
                        response: ""
                    ),
                    Reflection(
                        id: "beyond-creation-\(day)",
                        question: "What are you most excited to create in your life moving forward?",
                        placeholder: "I'm most excited to create...",
                        response: ""
                    )
                ]
            )
            
        case 28:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "wisdom-inventory-\(day)",
                        title: "List the key insights and wisdom you've gained that could help someone else on a similar journey.",
                        placeholder: "Wisdom I can share:\n• \n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "wisdom-sharing-plan-\(day)",
                        title: "Identify one way you can share your wisdom or support others (big or small).",
                        placeholder: "I can share my wisdom by...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "wisdom-value-\(day)",
                        question: "How does it feel to recognize that your experience has value and can help others?",
                        placeholder: "Recognizing my value feels...",
                        response: ""
                    ),
                    Reflection(
                        id: "wisdom-ripple-\(day)",
                        question: "How do you hope your healing journey might impact the world around you?",
                        placeholder: "I hope my healing creates...",
                        response: ""
                    )
                ]
            )
            
        case 29:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "transformation-timeline-\(day)",
                        title: "Create a timeline of your transformation. Mark key moments, breakthroughs, and growth points.",
                        placeholder: "My transformation timeline:\nDay 1: ...\nWeek 1: ...\nWeek 2: ...\nWeek 3: ...\nToday: ...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "transformation-evidence-\(day)",
                        title: "List concrete evidence of how you've changed (thoughts, behaviors, reactions, choices).",
                        placeholder: "Evidence of my transformation:\n• \n• \n• \n• \n• ",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "transformation-pride-\(day)",
                        question: "What aspect of your transformation makes you feel most proud and empowered?",
                        placeholder: "I feel most proud of...",
                        response: ""
                    ),
                    Reflection(
                        id: "transformation-trust-\(day)",
                        question: "How has your trust in yourself and your ability to handle life's challenges changed?",
                        placeholder: "My trust in myself has changed because...",
                        response: ""
                    )
                ]
            )
            
        case 30:
            return PracticeContent(
                exercises: [
                    Exercise(
                        id: "graduation-celebration-\(day)",
                        title: "Plan a meaningful way to celebrate your graduation from this program. How will you honor this achievement?",
                        placeholder: "I will celebrate by...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    ),
                    Exercise(
                        id: "graduation-manifesto-\(day)",
                        title: "Write your personal manifesto for moving forward. What do you stand for now?",
                        placeholder: "My manifesto:\nI believe...\nI stand for...\nI commit to...\nI am...",
                        type: .writing,
                        response: "",
                        isCompleted: false
                    )
                ],
                reflections: [
                    Reflection(
                        id: "graduation-gratitude-\(day)",
                        question: "What are you most grateful for about this entire journey?",
                        placeholder: "I'm most grateful for...",
                        response: ""
                    ),
                    Reflection(
                        id: "graduation-future-\(day)",
                        question: "As you graduate from this program, what message do you want to send to your future self?",
                        placeholder: "Dear Future Me...",
                        response: ""
                    )
                ]
            )
            
        default:
            return createDefaultPracticeContent(for: day)
        }
    }
    
    private func createDefaultPracticeContent(for day: Int) -> PracticeContent {
        return PracticeContent(
            exercises: [
                Exercise(
                    id: "daily-exercise-\(day)",
                    title: "Daily reflection exercise for day \(day)",
                    placeholder: "Write your thoughts here...",
                    type: .writing,
                    response: "",
                    isCompleted: false
                )
            ],
            reflections: [
                Reflection(
                    id: "daily-reflection-\(day)",
                    question: "How are you feeling today?",
                    placeholder: "Share your thoughts...",
                    response: ""
                )
            ]
        )
    }
    
    func getState(for day: Int) -> DayState {
        guard getCurrentProgram() != nil else {
            return day == 1 ? .unlocked : .locked
        }

        let isCompleted = day < self.currentDay
        let isToday = day == self.currentDay

        if isToday {
            return .today
        } else if isCompleted {
            return .completed
        } else if day > self.currentDay {
            return .locked
        } else {
            return .unlocked
        }
    }
    
    // MARK: - Daily Prompt Service
    
    func getTodaysPrompt() -> String {
        let prompts = [
            "What is one small thing that brought you comfort today? It could be as simple as a warm cup of tea, a kind word, or a moment of quiet.",
            "Describe a moment today when you felt truly present. What were you doing, and what did you notice around you?",
            "What would you like to tell yourself about the progress you've made recently, no matter how small?",
            "If your past self could see you now, what would surprise them most about your journey?",
            "What is one thing you're grateful for today that you might have overlooked?",
            "How did you show kindness to yourself or others today?",
            "What feeling are you ready to let go of, and what would you like to invite in instead?",
            "Write about a challenge you faced today and how you handled it with grace.",
            "What does peace look like for you in this moment?",
            "Describe something beautiful you noticed today, whether big or small.",
            "What small victory can you celebrate from this week?",
            "What moment today reminded you of your own strength?",
            "What would you tell someone else going through your situation?",
            "What are three things your past self would be proud of?",
            "How are you different now than when you started this journey?"
        ]
        
        // Use current date to ensure same prompt for the whole day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return prompts[dayOfYear % prompts.count]
    }
} 