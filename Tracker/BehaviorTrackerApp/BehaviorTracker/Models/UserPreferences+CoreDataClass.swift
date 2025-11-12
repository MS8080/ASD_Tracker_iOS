import Foundation
import CoreData

@objc(UserPreferences)
public class UserPreferences: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var notificationEnabled: Bool
    @NSManaged public var notificationTime: Date?
    @NSManaged public var streakCount: Int32
    @NSManaged private var favoritePatternsString: String?

    public var favoritePatterns: [String] {
        get {
            guard let string = favoritePatternsString, !string.isEmpty else {
                return []
            }
            return string.components(separatedBy: ",")
        }
        set {
            favoritePatternsString = newValue.joined(separator: ",")
        }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        self.notificationEnabled = false
        self.streakCount = 0
        self.favoritePatternsString = ""
    }
}
