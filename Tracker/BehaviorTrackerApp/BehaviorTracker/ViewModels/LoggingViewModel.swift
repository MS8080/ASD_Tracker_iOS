import SwiftUI
import CoreData

class LoggingViewModel: ObservableObject {
    @Published var favoritePatterns: [String] = []
    private let dataController = DataController.shared

    init() {
        loadFavorites()
    }

    func loadFavorites() {
        let preferences = dataController.getUserPreferences()
        favoritePatterns = preferences.favoritePatterns
    }

    func quickLog(patternType: PatternType) {
        let _ = dataController.createPatternEntry(
            patternType: patternType,
            intensity: 3,
            duration: 0,
            contextNotes: nil,
            specificDetails: nil
        )
        dataController.updateStreak()
    }

    func logPattern(
        patternType: PatternType,
        intensity: Int16,
        duration: Int32,
        contextNotes: String?,
        specificDetails: String?,
        isFavorite: Bool
    ) {
        _ = dataController.createPatternEntry(
            patternType: patternType,
            intensity: intensity,
            duration: duration,
            contextNotes: contextNotes,
            specificDetails: specificDetails
        )

        if isFavorite && !favoritePatterns.contains(patternType.rawValue) {
            addToFavorites(patternType: patternType)
        }

        dataController.updateStreak()
    }

    func addToFavorites(patternType: PatternType) {
        let preferences = dataController.getUserPreferences()
        var favorites = preferences.favoritePatterns

        if !favorites.contains(patternType.rawValue) {
            favorites.append(patternType.rawValue)
            preferences.favoritePatterns = favorites
            dataController.save()
            loadFavorites()
        }
    }

    func removeFromFavorites(patternType: PatternType) {
        let preferences = dataController.getUserPreferences()
        var favorites = preferences.favoritePatterns

        if let index = favorites.firstIndex(of: patternType.rawValue) {
            favorites.remove(at: index)
            preferences.favoritePatterns = favorites
            dataController.save()
            loadFavorites()
        }
    }
}
