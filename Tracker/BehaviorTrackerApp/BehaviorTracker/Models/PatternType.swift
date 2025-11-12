import Foundation

/// Specific pattern types within each category
enum PatternType: String, CaseIterable, Codable {
    // Behavioral
    case repetitiveBehavior = "Repetitive Behavior"
    case hyperfocusEpisode = "Hyperfocus Episode"
    case taskSwitchingDifficulty = "Task Switching Difficulty"
    case specialInterestDeepDive = "Special Interest Deep Dive"

    // Sensory
    case sensoryOverload = "Sensory Overload"
    case sensorySeekingBehavior = "Sensory Seeking"
    case environmentalTrigger = "Environmental Trigger"
    case eyeglassTintUsage = "Eyeglass Tint Usage"
    case physicalDiscomfortTrigger = "Physical Discomfort"

    // Social/Communication
    case socialInteraction = "Social Interaction"
    case maskingEpisode = "Masking Episode"
    case communicationPreference = "Communication Preference"
    case socialRecoveryTime = "Social Recovery Time"

    // Executive Function
    case decisionFatigue = "Decision Fatigue"
    case timeBlindness = "Time Blindness"
    case planningChallenge = "Planning/Organization Challenge"
    case transitionDifficulty = "Transition Difficulty"

    // Energy/Capacity
    case energyLevel = "Energy Level"
    case burnoutWarning = "Burnout Warning"
    case restRecoveryPeriod = "Rest/Recovery Period"
    case sleepQuality = "Sleep Quality"

    // Emotional Regulation
    case meltdownTrigger = "Meltdown Trigger"
    case shutdownEpisode = "Shutdown Episode"
    case anxietySpike = "Anxiety Spike"
    case emotionalRecoveryTime = "Emotional Recovery Time"
    case overwhelmIndicator = "Overwhelm Indicator"

    // Routine/Structure
    case routineAdherence = "Routine Adherence"
    case flexibilityTolerance = "Flexibility Tolerance"
    case disruptionImpact = "Disruption Impact"

    // Physical
    case movementNeeds = "Movement Needs"
    case posturePreference = "Posture/Positioning"
    case stimmingType = "Stimming Type"

    // Contextual
    case academicWorkPerformance = "Academic/Work Performance"
    case environmentalChange = "Environmental Change"
    case bureaucraticStress = "Bureaucratic Stress"
    case regulatoryActivity = "Regulatory Activity"

    var category: PatternCategory {
        switch self {
        case .repetitiveBehavior, .hyperfocusEpisode, .taskSwitchingDifficulty, .specialInterestDeepDive:
            return .behavioral
        case .sensoryOverload, .sensorySeekingBehavior, .environmentalTrigger, .eyeglassTintUsage, .physicalDiscomfortTrigger:
            return .sensory
        case .socialInteraction, .maskingEpisode, .communicationPreference, .socialRecoveryTime:
            return .socialCommunication
        case .decisionFatigue, .timeBlindness, .planningChallenge, .transitionDifficulty:
            return .executiveFunction
        case .energyLevel, .burnoutWarning, .restRecoveryPeriod, .sleepQuality:
            return .energyCapacity
        case .meltdownTrigger, .shutdownEpisode, .anxietySpike, .emotionalRecoveryTime, .overwhelmIndicator:
            return .emotionalRegulation
        case .routineAdherence, .flexibilityTolerance, .disruptionImpact:
            return .routineStructure
        case .movementNeeds, .posturePreference, .stimmingType:
            return .physical
        case .academicWorkPerformance, .environmentalChange, .bureaucraticStress, .regulatoryActivity:
            return .contextual
        }
    }

    var hasIntensityScale: Bool {
        switch self {
        case .energyLevel, .socialInteraction, .disruptionImpact, .flexibilityTolerance,
             .anxietySpike, .overwhelmIndicator, .burnoutWarning:
            return true
        default:
            return false
        }
    }

    var hasDuration: Bool {
        switch self {
        case .hyperfocusEpisode, .meltdownTrigger, .shutdownEpisode, .socialInteraction,
             .maskingEpisode, .socialRecoveryTime, .emotionalRecoveryTime, .restRecoveryPeriod:
            return true
        default:
            return false
        }
    }
}
